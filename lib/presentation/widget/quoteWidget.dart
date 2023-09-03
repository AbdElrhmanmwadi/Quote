import 'package:flutter/material.dart';
import 'package:quote/core/SharedPreferences.dart';
import 'package:quote/core/fontStyle.dart';
import 'package:quote/model/quote.dart';
import 'package:quote/presentation/widget/QuoteController.dart';

class QuoteWidget extends StatefulWidget {
  QuoteWidget({
    super.key,
    required int currentIndex,
    required this.lists,
    required this.index,
  }) : _currentIndex = currentIndex;

  final int _currentIndex;
  final List<Results>? lists;
  final int index;

  @override
  State<QuoteWidget> createState() => _QuoteWidgetState();
}

class _QuoteWidgetState extends State<QuoteWidget> {
  bool _isFavorite = false;

  Future<void> _loadFavoriteQuoteStatus() async {
    setState(() {
      _isFavorite =
          SharedPrefController().getData(key: widget._currentIndex.toString());
    });
  }

  void _toggleFavorite() async {
    setState(() {
      _isFavorite = !_isFavorite;
      SharedPrefController()
          .setData(widget._currentIndex.toString(), _isFavorite);
    });
  }

  @override
  void initState() {
    super.initState();
    _loadFavoriteQuoteStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "No.",
              style: FontStyle.cormorantStyle,
              textAlign: TextAlign.end,
            ),
            Text(
              " ______",
              style: FontStyle.cormorantStyle
                  .copyWith(fontWeight: FontWeight.w300, color: Colors.grey),
              textAlign: TextAlign.end,
            ),
            Text(
              "${widget._currentIndex + 1}",
              style: FontStyle.cormorantStyle.copyWith(
                fontSize: 25,
              ),
              textAlign: TextAlign.end,
            ),
            SelectableText(
              widget.lists![widget.index].content!,
              style: FontStyle.cormorantStyle
                  .copyWith(fontWeight: FontWeight.w600, color: Colors.black),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              " ______",
              style: FontStyle.cormorantStyle
                  .copyWith(fontWeight: FontWeight.w300, color: Colors.grey),
              textAlign: TextAlign.end,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  " ${widget.lists![widget.index].author}",
                  style: FontStyle.cormorantStyle.copyWith(
                      fontWeight: FontWeight.w400, color: Colors.black),
                  textAlign: TextAlign.end,
                ),
                Row(
                  children: [
                    IconButton(
                        icon: Icon(
                          _isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: Colors.red,
                        ),
                        onPressed: _toggleFavorite),
                    IconButton(
                        icon: Icon(
                          Icons.share,
                          color: Colors.grey[700],
                        ),
                        onPressed: () async {
                          QuoteController.shareQuote(
                              widget.lists, widget._currentIndex);
                        }),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
