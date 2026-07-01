import 'package:flutter/widgets.dart';

/// True when [text] starts with a right-to-left script (Arabic/Hebrew), so the
/// UI can flip alignment and direction for mixed English/Arabic content.
///
/// It looks at the first *strong* character: a Latin letter means LTR, an
/// Arabic/Hebrew letter means RTL. Neutral characters (quotes, digits,
/// punctuation, spaces) are skipped so a leading `"` never hides the script.
bool isRtl(String text) {
  for (final rune in text.runes) {
    // Arabic, Arabic Supplement/Extended, and presentation forms + Hebrew.
    if ((rune >= 0x0590 && rune <= 0x08FF) ||
        (rune >= 0xFB1D && rune <= 0xFDFF) ||
        (rune >= 0xFE70 && rune <= 0xFEFF)) {
      return true;
    }
    // A Latin letter reached before any RTL letter → treat as LTR.
    if ((rune >= 0x41 && rune <= 0x5A) || (rune >= 0x61 && rune <= 0x7A)) {
      return false;
    }
  }
  return false;
}

/// The natural text direction for [text].
TextDirection directionOf(String text) =>
    isRtl(text) ? TextDirection.rtl : TextDirection.ltr;
