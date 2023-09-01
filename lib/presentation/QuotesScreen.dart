import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:quote/core/ApiService.dart';
import 'package:quote/core/SharedPreferences.dart';

import 'package:quote/domain/quote.dart';
import 'package:quote/domain/tag.dart';
import 'package:quote/presentation/QutesRandomScreen.dart';
import 'package:quote/presentation/bloc/quotes_bloc.dart';
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
  ScrollController _scrollController = ScrollController();

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

  late QuotesBloc _quotesBloc;

  int start = 1;
  int last = 2;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await QuoteController.checkAndShowQuote(context);
    });
    _quotesBloc = QuotesBloc();
    _quotesBloc.add(FetchQuotesEvent(start: start, last: last));
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    if (currentScroll >= (maxScroll * 0.9)) {
      context
          .read<QuotesBloc>()
          .add(FetchQuotesEvent(start: start + 1, last: last + 1));
    }
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
                  onPressed: _toggleFavorite),
              IconButton(
                  icon: Icon(
                    Icons.share,
                    color: Colors.grey[700],
                  ),
                  onPressed: () async {
                    QuoteController.shareQuote(lists, _currentIndex);
                  }),
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
                lists = state.quotes;
                //lists = ApiServies.data ?? state.quotes;

                listTage = ApiServies.tags;
                print(listTage!.length);

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Container(
                    //     color: Colors.white,
                    //     height: 120,
                    //     child: Wrap(
                    //       children: listTage!
                    //           .map((e) => Padding(
                    //                 padding: const EdgeInsets.all(2.0),
                    //                 child: Chip(
                    //                   onDeleted: () {
                    //                     setState(() {
                    //                       listTage!.remove(e);
                    //                     });
                    //                     ;
                    //                   },
                    //                   label: Text('${e.name}'),
                    //                 ),
                    //               ))
                    //           .toList(),
                    //     )),
                    // SizedBox(
                    //   height: 25,
                    // ),
                    Expanded(
                      child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        controller: _scrollController,
                        itemCount: lists!.length,
                        // onPageChanged: (index) {
                        //   setState(() {
                        //     _currentIndex = index;
                        //     _loadFavoriteQuoteStatus();
                        //   });
                        // },
                        itemBuilder: (context, index) {
                          return QuoteWidget(
                            currentIndex: index + 1,
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
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }
}
