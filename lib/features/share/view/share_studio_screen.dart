import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/util/bidi.dart';
import '../../../data/models/quote.dart';

/// A background preset for the shareable quote image.
class _Background {
  const _Background(this.name, this.colors, this.textColor);
  final String name;
  final List<Color> colors;
  final Color textColor;
}

const _backgrounds = <_Background>[
  _Background('Indigo', [Color(0xFF5B5BD6), Color(0xFF8E8EE8)], Colors.white),
  _Background('Sunset', [Color(0xFFFF7E5F), Color(0xFFFEB47B)], Colors.white),
  _Background('Forest', [Color(0xFF134E5E), Color(0xFF71B280)], Colors.white),
  _Background('Night', [Color(0xFF0F2027), Color(0xFF203A43)], Colors.white),
  _Background('Rose', [Color(0xFFEECDA3), Color(0xFFEF629F)], Colors.white),
  _Background('Paper', [Color(0xFFF5F3EE), Color(0xFFE8E2D5)], Color(0xFF2B2B2B)),
  _Background('Ocean', [Color(0xFF2193B0), Color(0xFF6DD5ED)], Colors.white),
  _Background('Ember', [Color(0xFF642B73), Color(0xFFC6426E)], Colors.white),
  _Background('Sand', [Color(0xFF3E2723), Color(0xFF8D6E63)], Color(0xFFF5EFE6)),
  _Background('Mint', [Color(0xFF11998E), Color(0xFF38EF7D)], Colors.white),
  _Background('Slate', [Color(0xFF232526), Color(0xFF414345)], Colors.white),
];

/// Lets the user style a quote (background + font) and share it as an image.
///
/// Replaces the old one-tap "share as image", which always rendered the plain
/// card. Here the user picks a look and we rasterize the live preview.
class ShareStudioScreen extends StatefulWidget {
  const ShareStudioScreen({super.key, required this.quote});

  final Quote quote;

  @override
  State<ShareStudioScreen> createState() => _ShareStudioScreenState();
}

class _ShareStudioScreenState extends State<ShareStudioScreen> {
  final _boundaryKey = GlobalKey();
  int _bgIndex = 0;
  bool _serif = true;
  bool _sharing = false;
  double _fontSize = 24;

  Quote get _quote => widget.quote;

  Future<void> _share() async {
    if (_sharing) return;
    setState(() => _sharing = true);
    try {
      final boundary = _boundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: 3);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) return;
      final bytes = data.buffer.asUint8List();
      final dir = await getTemporaryDirectory();
      final file = await File('${dir.path}/quote_${_quote.id}_$_bgIndex.png')
          .writeAsBytes(bytes, flush: true);
      await Share.shareXFiles([XFile(file.path)], text: _quote.shareText);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not create image')),
      );
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg = _backgrounds[_bgIndex];
    return Scaffold(
      appBar: AppBar(title: const Text('Create image')),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: RepaintBoundary(
                  key: _boundaryKey,
                  child: _Preview(
                    quote: _quote,
                    background: bg,
                    serif: _serif,
                    fontSize: _fontSize,
                  ),
                ),
              ),
            ),
          ),
          _Toolbar(
            backgrounds: _backgrounds,
            selectedIndex: _bgIndex,
            serif: _serif,
            fontSize: _fontSize,
            onBackground: (i) => setState(() => _bgIndex = i),
            onToggleFont: () => setState(() => _serif = !_serif),
            onFontSize: (size) => setState(() => _fontSize = size),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _sharing ? null : _share,
        icon: _sharing
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.share),
        label: const Text('Share'),
      ),
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview({
    required this.quote,
    required this.background,
    required this.serif,
    required this.fontSize,
  });

  final Quote quote;
  final _Background background;
  final bool serif;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    // Arabic can't use the Latin-only serif; fall back to the platform font.
    final arabic = isRtl(quote.content);
    return Container(
      width: 320,
      constraints: const BoxConstraints(minHeight: 320),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: background.colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Directionality(
        textDirection: directionOf(quote.content),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.format_quote_rounded,
                size: 40, color: background.textColor.withValues(alpha: 0.9)),
            const SizedBox(height: 12),
            Text(
              quote.content,
              style: TextStyle(
                fontFamily: !serif
                    ? null
                    : (arabic ? AppTheme.arabicSerifFamily : AppTheme.serifFamily),
                fontSize: fontSize,
                height: arabic ? 1.7 : 1.35,
                fontWeight: FontWeight.w500,
                color: background.textColor,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '— ${quote.author}',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: background.textColor.withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({
    required this.backgrounds,
    required this.selectedIndex,
    required this.serif,
    required this.fontSize,
    required this.onBackground,
    required this.onToggleFont,
    required this.onFontSize,
  });

  final List<_Background> backgrounds;
  final int selectedIndex;
  final bool serif;
  final double fontSize;
  final ValueChanged<int> onBackground;
  final VoidCallback onToggleFont;
  final ValueChanged<double> onFontSize;

  static const _sizes = <String, double>{'S': 20, 'M': 24, 'L': 30};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 56,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: backgrounds.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, i) {
                  final selected = i == selectedIndex;
                  return GestureDetector(
                    onTap: () => onBackground(i),
                    child: Container(
                      width: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: backgrounds[i].colors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outlineVariant,
                          width: selected ? 3 : 1,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                TextButton.icon(
                  onPressed: onToggleFont,
                  icon: const Icon(Icons.font_download_outlined),
                  label: Text(serif ? 'Font: Serif' : 'Font: Sans'),
                ),
                const Spacer(),
                for (final entry in _sizes.entries)
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: ChoiceChip(
                      label: Text(entry.key),
                      selected: fontSize == entry.value,
                      onSelected: (_) => onFontSize(entry.value),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
