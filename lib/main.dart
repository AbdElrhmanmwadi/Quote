import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quote/core/SharedPreferences.dart';
import 'package:quote/presentation/QuotesScreen.dart';
import 'package:quote/presentation/bloc/quote_bloc.dart';
import 'package:quote/presentation/bloc/quotes_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SharedPrefController.initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => QuoteBloc()..add(GetPostsEvent()),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Inspirational Quotes App',
        home: QuotesScreen(),
      ),
    );
  }
}
