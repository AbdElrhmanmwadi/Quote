
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:quote/core/api_service.dart';
import 'package:quote/presentation/screen/Qutes_Random_Screen.dart';
import 'package:quote/presentation/bloc/quote_bloc.dart';
import 'package:quote/presentation/widget/Custom_Search_Delegate.dart';
import 'package:quote/presentation/widget/Quote_Widget.dart';
import 'package:quote/presentation/widget/Quote_Controller.dart';

class QuotesScreen extends StatefulWidget {
  @override
  _QuotesScreenState createState() => _QuotesScreenState();
}

class _QuotesScreenState extends State<QuotesScreen> {
  final ScrollController _scrollController = ScrollController();

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

      Future.delayed(const Duration(seconds: 1), () {
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
        actions: [
          IconButton(
            onPressed: () async {
              showSearch(
                context: context,
                delegate: CustomSearchDelegate(),
              );
            },
            icon: const Icon(
              Icons.search,
              color: Colors.red,
            ),
          ),
        ],
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
                            : quoteWidget(
                                id: state.quotes[index].sId!,
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
              return ErrorWidgets(
                onRetry: () {
                  context.read<QuoteBloc>().add(
                        GetPostsEvent(),
                      );
                },
                errorMessage: state.errorMessage,
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

class ErrorWidgets extends StatefulWidget {
  final String errorMessage;
  final void Function()? onRetry;
  const ErrorWidgets({
    super.key,
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  State<ErrorWidgets> createState() => _ErrorWidgetsState();
}

class _ErrorWidgetsState extends State<ErrorWidgets> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Text(widget.errorMessage),
        ),
        const SizedBox(
          height: 100,
        ),
        MaterialButton(
            color: Colors.red,
            textColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
            onPressed: widget.onRetry,
            child: const Text(
              'Retry',
            ))
      ],
    );
  }
}
