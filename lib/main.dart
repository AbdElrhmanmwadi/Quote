import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quote/core/SharedPreferences.dart';
import 'package:quote/helper/my_bloc_Observer.dart';
import 'package:quote/presentation/screen/QuotesScreen.dart';
import 'package:quote/presentation/bloc/quote_bloc.dart';
import 'package:quote/presentation/screen/tagScreen.dart';

void main() async {
  Bloc.observer = MyBlocObserver();
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
          home: SharedPrefController().getData(key: 'tag')
              ? QuotesScreen()
              : const TagScreen()),
    );
  }
}

