import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:quote/core/ApiService.dart';
import 'package:quote/core/SharedPreferences.dart';

import 'package:quote/model/quote.dart';
import 'package:quote/model/tag.dart';
import 'package:quote/presentation/QutesRandomScreen.dart';
import 'package:quote/presentation/bloc/quote_bloc.dart';
import 'package:quote/presentation/widget/QuoteController.dart';
import 'package:quote/presentation/widget/quoteWidget.dart';

class QuotesScreen extends StatefulWidget {
  @override
  _QuotesScreenState createState() => _QuotesScreenState();
}

int _currentIndex = 0;
bool _isFavorite = false;
List<Results>? lists;
List<Tag>? listTage;
Results? resuilt;

class _QuotesScreenState extends State<QuotesScreen> {
  final ScrollController _scrollController = ScrollController();

  // Future<void> _loadFavoriteQuoteStatus() async {
  //   setState(() {
  //     _isFavorite =
  //         SharedPrefController().getData(key: _currentIndex.toString());
  //   });
  // }

  // void _toggleFavorite() async {
  //   setState(() {
  //     _isFavorite = !_isFavorite;
  //     SharedPrefController().setData(_currentIndex.toString(), _isFavorite);
  //   });
  // }

  int page = 2;

  @override
  void initState() {
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await QuoteController.checkAndShowQuote(context);
    });
    super.initState();
  }

  bool isFetching = false;

  void _onScroll() {
    if (isFetching) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;

    if (currentScroll >= (maxScroll * 0.9)) {
      isFetching = true;
      context.read<QuoteBloc>().add(GetPostsEvent());

      Future.delayed(Duration(seconds: 1), () {
        isFetching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: () async {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => QuotesRandomScreen(),
          ));
        },
        child: const Icon(Icons.crisis_alert_outlined),
      ),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
       // actions: [
          // IconButton(
          //     icon: Icon(
          //       _isFavorite ? Icons.favorite : Icons.favorite_border,
          //       color: Colors.red,
          //     ),
          //     onPressed: _toggleFavorite),
          // IconButton(
          //     icon: Icon(
          //       Icons.share,
          //       color: Colors.grey[700],
          //     ),
          //     onPressed: () async {
          //       QuoteController.shareQuote(lists, _currentIndex);
          //     }),
       // ],
        title: Text.rich(
          TextSpan(
              text: ';;',
              style: const TextStyle(
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
      body: BlocBuilder<QuoteBloc, QuotessState>(
        builder: (context, state) {
          switch (state.status) {
            case QouteStatus.loading:
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(4.0),
                  child: SizedBox(
                    height: 30,
                    width: 30,
                    child: CircularProgressIndicator(),
                  ),
                ),
              );
            case QouteStatus.success:
              if (state.quotes.isEmpty) {
                return const Center(
                  child: Text("No Posts"),
                );
              }
              return ListView.builder(
                controller: _scrollController,
                itemCount: state.hasReachedMax
                    ? state.quotes.length
                    : state.quotes.length + 1,
                itemBuilder: (BuildContext context, int index) {
                  return index >= state.quotes.length
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(4.0),
                            child: SizedBox(
                              height: 30,
                              width: 30,
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        )
                      : QuoteWidget(
                          currentIndex: index,
                          lists: state.quotes,
                          index: index,
                        );
                },
              );
            case QouteStatus.error:
              return Center(
                child: Text(state.errorMessage),
              );
          }

        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }
}
