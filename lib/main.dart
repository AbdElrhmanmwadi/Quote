import 'package:flutter/material.dart';
import 'package:quote/ApiService.dart';
import 'package:quote/fontStyle.dart';
import 'package:quote/quote.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_share/flutter_share.dart';

void main() {
  runApp(MyApp());
}

class Quote {
  final String text;
  final String author;

  Quote({required this.text, required this.author});
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Inspirational Quotes App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: QuotesScreen(),
    );
  }
}

class QuotesScreen extends StatefulWidget {
  @override
  _QuotesScreenState createState() => _QuotesScreenState();
}

class _QuotesScreenState extends State<QuotesScreen> {
  PageController _pageController = PageController();
  int _currentIndex = 0;
  bool _isFavorite = false;
  List<Results>? lists;
  void list() async {
    lists = await ApiServies.getAllQuote();
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    list();
    _loadFavoriteQuoteStatus();
  }

  Future<void> _loadFavoriteQuoteStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isFavorite = prefs.getBool(_currentIndex.toString()) ?? false;
    });
  }

  void _toggleFavorite() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isFavorite = !_isFavorite;
      prefs.setBool(_currentIndex.toString(), _isFavorite);
    });
  }

  Future<void> _shareQuote() async {
    await FlutterShare.share(
      title: 'Check out this quote!',
      text:
          '${lists![_currentIndex].content} - ${lists![_currentIndex].author}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: lists!.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                  _loadFavoriteQuoteStatus();
                });
              },
              itemBuilder: (context, index) {
                return Container(
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
                        style: FontStyle.cormorantStyle.copyWith(
                            fontWeight: FontWeight.w300, color: Colors.grey),
                        textAlign: TextAlign.end,
                      ),
                      Text(
                        "${_currentIndex}",
                        style: FontStyle.cormorantStyle.copyWith(
                          fontSize: 25,
                        ),
                        textAlign: TextAlign.end,
                      ),
                      SelectableText(
                        lists![index].content!,
                        style: FontStyle.cormorantStyle.copyWith(
                            fontWeight: FontWeight.w600, color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        " ______",
                        style: FontStyle.cormorantStyle.copyWith(
                            fontWeight: FontWeight.w300, color: Colors.grey),
                        textAlign: TextAlign.end,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        " ${lists![index].author}",
                        style: FontStyle.cormorantStyle.copyWith(
                            fontWeight: FontWeight.w600, color: Colors.grey),
                        textAlign: TextAlign.end,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
