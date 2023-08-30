import 'package:flutter/material.dart';
import 'package:quote/core/SharedPreferences.dart';
import 'package:quote/presentation/QuotesScreen.dart';

void main()async {
  WidgetsFlutterBinding.ensureInitialized();

await SharedPrefController.initialize();
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
