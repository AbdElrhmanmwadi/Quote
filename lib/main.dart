import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quote/core/shared_preferences.dart';
import 'package:quote/helper/my_bloc_Observer.dart';
import 'package:quote/presentation/cubit/favorite_cubit.dart';
import 'package:quote/presentation/screen/Quotes_Screen.dart';
import 'package:quote/presentation/bloc/quote_bloc.dart';
import 'package:quote/presentation/screen/tagScreen.dart';

void main() async {
  Bloc.observer = MyBlocObserver();
  WidgetsFlutterBinding.ensureInitialized();

  await SharedPrefController.initialize();
  runApp( const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => QuoteBloc()..add(GetPostsEvent()),
        ),
        BlocProvider(
          create: (context) => FavoriteCubit(),
        ),
      ],
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Inspirational Quotes App',
          home: SharedPrefController().getData(key: 'tag')
              ? QuotesScreen()
              : const TagScreen()),
    );
  }
}
