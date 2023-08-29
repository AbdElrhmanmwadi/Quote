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
      storeQuotesInSharedPreferences(listResults);
    }

    return listResults;
  }

  static Future<void> storeQuotesInSharedPreferences(
      List<Results>? quotes) async {
    if (quotes != null) {
      final quotesJson = jsonEncode(quotes);
      await SharedPrefController().setData('quotes', quotesJson);
    }
  }

  // Retrieve listResults from SharedPreferences
  static Future<List<Results>?> getQuotesFromSharedPreferences() async {
    final quotesJson = SharedPrefController().getString(key: 'quotes');
    if (quotesJson != null) {
      final quotesList = jsonDecode(quotesJson) as List<dynamic>;
      final quotes =
          quotesList.map((quote) => Results.fromJson(quote)).toList();
      data = quotes;
      print(data);
      return quotes;
    }
    return null;
  }
}
