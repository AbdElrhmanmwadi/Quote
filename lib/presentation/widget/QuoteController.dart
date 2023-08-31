import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:quote/core/ApiService.dart';
import 'package:quote/core/SharedPreferences.dart';
import 'package:quote/core/fontStyle.dart';

class QuoteController {
 static Future<void> checkAndShowQuote(context) async {
  final lastShownDate =
      SharedPrefController().getString(key: 'last_shown_date') ?? '';

  final DateTime now = DateTime.now();
  final DateTime lastDate = DateTime.tryParse(lastShownDate) ?? now;

  if (now.difference(lastDate).inDays >= 1) {
    var data = await ApiServies.getRandomQuote();

    await _showQuoteDialog(context, data.content!, data.author!);

    SharedPrefController().setString('last_shown_date', now.toIso8601String());
  }
}
static Future<void> shareQuote(lists,_currentIndex) async {
    if (lists != null &&
        lists!.isNotEmpty &&
        _currentIndex >= 0 &&
        _currentIndex < lists!.length) {
      final quoteContent = lists![_currentIndex].content;
      final quoteAuthor = lists![_currentIndex].author;

      if (quoteContent != null && quoteAuthor != null) {
        final shareText = '$quoteContent - $quoteAuthor';

        try {
          await FlutterShare.share(
            title: 'Check out this quote!',
            text: shareText,
          );
        } catch (e) {
          print('Sharing error: $e');
        }
      }
    }
  }

static Future<void> _showQuoteDialog(
    BuildContext context, String quote, String author) async {
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Container(
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Container(
              width: 100,
              alignment: Alignment.center,
              child: Column(
                children: [
                  Text(
                    'Daily Quote',
                    style: FontStyle.cormorantStyle.copyWith(
                        fontSize: 25,
                        fontFamily: 'Cormorant',
                        fontWeight: FontWeight.w900,
                        color: Colors.red),
                  ),
                  Divider(),
                  Text("' $quote '",
                      style: FontStyle.cormorantStyle.copyWith(
                          fontSize: 20,
                          fontFamily: 'Cormorant',
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[900])),
                  Divider(),
                  Text("$author",
                      style: FontStyle.cormorantStyle.copyWith(
                          fontSize: 20,
                          fontFamily: 'Cormorant',
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[900])),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
  
}