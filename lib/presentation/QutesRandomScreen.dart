import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:quote/model/quote.dart';

import 'package:quote/presentation/widget/QuoteController.dart';
import 'package:quote/presentation/widget/quoteWidget.dart';

import 'bloc/quote_bloc.dart';

class QuotesRandomScreen extends StatefulWidget {
  @override
  _QuotesRandomScreenState createState() => _QuotesRandomScreenState();
}

class _QuotesRandomScreenState extends State<QuotesRandomScreen> {
  final PageController _pageController = PageController();
  final int _currentIndex = 0;

  List<Results> lists = [];
  Results? results;
  late QuoteBloc _quotesBloc;

  @override
  void initState() {
    super.initState();
    _quotesBloc = QuoteBloc();
    _quotesBloc.add(FetchQuotessRandomeEvent());
  }

  bool _rotateIcon = false;
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => _quotesBloc,
        child: Scaffold(
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.red,
            onPressed: () async {
              setState(() {
                _rotateIcon = !_rotateIcon;
              });
              _quotesBloc.add(FetchQuotessRandomeEvent());
            },
            child: AnimatedRotation(
              duration: Duration(milliseconds: 300),
              turns: _rotateIcon == true ? 180 * (3.14159265359 / 180) : 0,
              child: const Icon(Icons.crisis_alert_outlined),
            ),
          ),
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white,
            elevation: 0,
            actions: [
              IconButton(
                icon: Icon(
                  Icons.share,
                  color: Colors.grey[700],
                ),
                onPressed: () async {
                  await QuoteController.shareQuote(lists, _currentIndex);
                },
              ),
            ],
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
              if (state is QuotesLoadedRandomeeState) {
                lists = state.quotess;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: lists.length,
                        onPageChanged: (index) {},
                        itemBuilder: (context, index) {
                          return QuoteWidget(
                            id: lists[index].sId!,
                            currentIndex: _currentIndex,
                            lists: lists,
                            index: index,
                          );
                        },
                      ),
                    ),
                  ],
                );
              } else if (state is QuotesErrorrState) {
                return const Center(
                  child: Text('Failed to fetch quotes.'),
                );
              } else {
                return const Center(
                  child: ProgressIndicator(),
                );
              }
            },
          ),
        ));
  }
}

class ProgressIndicator extends StatelessWidget {
  const ProgressIndicator({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation(Colors.red),
    );
  }
}
