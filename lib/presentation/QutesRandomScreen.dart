import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:quote/core/ApiService.dart';
import 'package:quote/core/SharedPreferences.dart';
import 'package:quote/domain/quote.dart';
import 'package:quote/core/fontStyle.dart';
import 'package:quote/presentation/widget/quoteWidget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuotesRandomScreen extends StatefulWidget {
  @override
  _QuotesRandomScreenState createState() => _QuotesRandomScreenState();
}

class _QuotesRandomScreenState extends State<QuotesRandomScreen> {
  PageController _pageController = PageController();
  int _currentIndex = 0;
  bool _isFavorite = false;
  List<Results> lists = []; // Initialize the list
  Results? results;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadDataAndFavoriteStatus();
  }

  Future<void> _loadDataAndFavoriteStatus() async {
    results = await ApiServies.getRandomQuote();
    print(results!.author);

    if (lists.isNotEmpty) {
      lists.removeAt(0); // Remove the old quote
    }
    lists.add(results!); // Add the new quote
    // Set index to the fetched quote

    print('$lists asdasssssssssss');
    _loadFavoriteQuoteStatus();
  }

  Future<void> _loadFavoriteQuoteStatus() async {
    setState(() {
      _isFavorite =
          SharedPrefController().getData(key: _currentIndex.toString());
    });
  }

  void _toggleFavorite() async {
    setState(() {
      _isFavorite = !_isFavorite;
      SharedPrefController().setData(_currentIndex.toString(), _isFavorite);
    });
  }

  Future<void> _shareQuote() async {
    if (lists.isNotEmpty &&
        _currentIndex >= 0 &&
        _currentIndex < lists.length) {
      final quoteContent = lists[_currentIndex].content;
      final quoteAuthor = lists[_currentIndex].author;

      if (quoteContent != null && quoteAuthor != null) {
        final shareText = '$quoteContent - $quoteAuthor';

        try {
          await FlutterShare.share(
            title: 'Check out this quote!',
            text: shareText,
          );
        } catch (e) {
          // Handle sharing error
          print('Sharing error: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: () async {
          results = await ApiServies.getRandomQuote();
          setState(() {
            if (lists.isNotEmpty) {
              lists.removeAt(0); // Remove the old quote
            }
            lists.add(results!);

            _currentIndex = lists.length - 1; // Set index to the fetched quote
          });
        },
        child: Icon(Icons.crisis_alert_outlined),
      ),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: Colors.red,
            ),
            onPressed: _toggleFavorite,
          ),
          IconButton(
            icon: Icon(
              Icons.share,
              color: Colors.grey[700],
            ),
            onPressed: _shareQuote,
          ),
        ],
        title: Text.rich(
          TextSpan(
              text: ';;',
              style: TextStyle(
                  fontFamily: 'Cormorant',
                  fontWeight: FontWeight.w900,
                  fontSize: 30,
                  color: Colors.red),
              children: [
                TextSpan(
                  text: '  Quote',
                  style: TextStyle(
                      fontSize: 25,
                      fontFamily: 'Cormorant',
                      fontWeight: FontWeight.w900,
                      color: Colors.grey[700]),
                )
              ]),
        ),
      ),
      body: lists.isEmpty
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: lists.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                        _loadFavoriteQuoteStatus();
                      });
                    },
                    itemBuilder: (context, index) {
                      return QuoteWidget(
                        currentIndex: _currentIndex,
                        lists: lists,
                        index: index,
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
