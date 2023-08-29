import 'package:flutter/material.dart';
import 'package:quote/ApiService.dart';
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
      backgroundColor: Colors.red,
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
                return Card(
                  color: Colors.red,
                  elevation: 4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        lists![index].content!,
                        style: TextStyle(fontSize: 20),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10),
                      Text(
                        "- ${lists![index].author}",
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.end,
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(
                              _isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: Colors.red,
                            ),
                            onPressed: _toggleFavorite,
                          ),
                          IconButton(
                            icon: Icon(Icons.share),
                            onPressed: _shareQuote,
                          ),
                        ],
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
