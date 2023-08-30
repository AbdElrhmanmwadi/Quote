import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:quote/core/SharedPreferences.dart';
import 'package:quote/domain/quote.dart';

class ApiServies {
  static List<Results>? data = [];
  static Future<List<Results>?> getAllQuote() async {
    List<Results>? listResults;
    Uri url = Uri.parse('https://api.quotable.io/quotes');
    http.Response response = await http.get(url);
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      listResults = quote.fromJson(jsonData).results;
      data = listResults;
      storeQuotesInSharedPreferences(listResults);
      return data;
    }

    return data;
  }

  static Future<void> storeQuotesInSharedPreferences(
      List<Results>? quotes) async {
    print(11111111111);
    if (quotes != null) {
      final quotesJson = jsonEncode(quotes);

      await SharedPrefController().setString('quotes', quotesJson);
    }
  }

  static Future<List<Results>?> getQuotesFromSharedPreferences() async {
    final quotesJson = SharedPrefController().getString(key: 'quotes');
    if (quotesJson != null) {
      final quotesList = jsonDecode(quotesJson) as List<dynamic>;
      List<Results> quotes =
          quotesList.map((quote) => Results.fromJson(quote)).toList();
      data = quotes;
      return quotes;
    }
    return null;
  }

  static Future<Results> getRandomQuote() async {
    Results? resultsQuote = Results(
        sId: '11',
        author: 'Abed',
        content: 'OOOO',
        tags: [],
        authorSlug: 'YYY',
        length: 100,
        dateAdded: '2023-04-14',
        dateModified: '2023-04-14');
    Uri url = Uri.parse('https://api.quotable.io/random');
    http.Response response = await http.get(url);
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      resultsQuote = Results.fromJson(jsonData);
      print(resultsQuote);

      return resultsQuote;
    }

    return resultsQuote;
  }
}
