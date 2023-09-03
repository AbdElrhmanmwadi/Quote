import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:quote/core/ApiService.dart';
import 'package:quote/model/quote.dart';
import 'package:quote/presentation/QutesRandomScreen.dart';
import 'package:quote/presentation/bloc/quote_bloc.dart';
import 'package:quote/presentation/widget/QuoteController.dart';
import 'package:quote/presentation/widget/SearchTextForm.dart';
import 'package:quote/presentation/widget/quoteWidget.dart';

class QuotesScreen extends StatefulWidget {
  @override
  _QuotesScreenState createState() => _QuotesScreenState();
}

class _QuotesScreenState extends State<QuotesScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  int page = 2;
  bool isFetching = false;

  @override
  void initState() {
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await QuoteController.checkAndShowQuote(context);
    });

    ApiServies.searchs('home');
    super.initState();
  }

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
        title: Text.rich(
          TextSpan(
            text: ';;',
            style: const TextStyle(
              fontFamily: 'Cormorant',
              fontWeight: FontWeight.w900,
              fontSize: 30,
              color: Colors.red,
            ),
            children: [
              TextSpan(
                text: '  Quote',
                style: TextStyle(
                  fontSize: 25,
                  fontFamily: 'Cormorant',
                  fontWeight: FontWeight.w900,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
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
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.red),
                    ),
                  ),
                ),
              );
            case QouteStatus.success:
              if (state.quotes.isEmpty) {
                return const Center(
                  child: Text("No Posts"),
                );
              }
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SearchTextFormField(
                      controller: _searchController,
                      onChanged: (value) async {
                        await ApiServies.searchs(value);
                      },
                      icon: Icons.search,
                      hintText: 'hintText',
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
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
                                    child: CircularProgressIndicator(
                                      valueColor:
                                          AlwaysStoppedAnimation(Colors.red),
                                    ),
                                  ),
                                ),
                              )
                            : QuoteWidget(
                                currentIndex: index,
                                lists: state.quotes,
                                index: index,
                              );
                      },
                    ),
                  ),
                ],
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
