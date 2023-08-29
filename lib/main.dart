import 'package:flutter/material.dart';
import 'package:quote/core/SharedPreferences.dart';
import 'package:quote/presentation/QuotesScreen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPrefController().init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Inspirational Quotes App',
      home: QuotesScreen(),
    );
  }
}
