import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:quote/core/ApiService.dart';
import 'package:quote/core/SharedPreferences.dart';
import 'package:quote/core/fontStyle.dart';
import 'package:quote/domain/quote.dart';
import 'package:quote/presentation/QutesRandomScreen.dart';
import 'package:quote/presentation/bloc/quotes_bloc.dart';
import 'package:quote/presentation/widget/quoteWidget.dart';

class QuotesScreen extends StatefulWidget {
  @override
  _QuotesScreenState createState() => _QuotesScreenState();
}

PageController _pageController = PageController();
int _currentIndex = 0;
bool _isFavorite = false;
List<Results>? lists;
Results? resuilt;

class _QuotesScreenState extends State<QuotesScreen> {
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
          // Handle sharing error
          print('Sharing error: $e');
        }
      }
    }
  }

  late QuotesBloc _quotesBloc;

  @override
  void initState() {
    super.initState();
    _quotesBloc = QuotesBloc();
    _quotesBloc.add(FetchQuotesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => _quotesBloc,
        child: Scaffold(
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.red,
            onPressed: () async {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => QuotesRandomScreen(),
              ));
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
          body: BlocBuilder<QuotesBloc, QuotesState>(
            builder: (context, state) {
              if (state is QuotesLoadedState) {
                lists = ApiServies.data ?? state.quotes;
                return Column(
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
                          return QuoteWidget(
                            currentIndex: _currentIndex,
                            lists: lists,
                            index: index,
                          );
                        },
                      ),
                    ),
                  ],
                );
              } else if (state is QuotesErrorState) {
                return const Center(
                  child: Text('Failed to fetch quotes.'),
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ));
  }

  @override
  void dispose() {
    _quotesBloc.close();
    super.dispose();
  }
}
