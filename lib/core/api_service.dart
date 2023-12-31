import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:quote/core/shared_preferences.dart';
import 'package:quote/model/quote.dart';
import 'package:quote/model/search.dart';
import 'package:quote/model/tag.dart';

class ApiServies {
  static List<Results>? data = [];
  static List<Results>? quoteByTag = [];
  static List<Tag> tags = [];
  static Future<List<Results>?> getAllQuote(index) async {
    List<Results>? listResults;
    Uri url = Uri.parse('https://api.quotable.io/quotes?page=$index');
    http.Response response = await http.get(url);
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      listResults = Quote.fromJson(jsonData).results;
      data = listResults;

      return data;
    }

    return data;
  }

  static Future<List<Results>?> getQuoteByTag(tag) async {
    List<Results>? listResults = [];
    Uri url = Uri.parse('https://api.quotable.io/quotes?tags=$tag');
    http.Response response = await http.get(url);
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      listResults = Quote.fromJson(jsonData).results;
      quoteByTag!.addAll(listResults!);

      return quoteByTag;
    }

    return quoteByTag;
  }

// this function use to get all quotes
  static Future<List<Results>> getAllQuotesFromPages(
      int startPage, int endPage) async {
    List<Results> allQuotes = [];

    for (int i = startPage; i <= endPage; i++) {
      List<Results>? quotes = await getAllQuote(i);
      if (quotes != null) {
        allQuotes.addAll(quotes);
      }
    }
    // storeQuotesInSharedPreferences(allQuotes);
    data = allQuotes;

    return allQuotes;
  }

  static Future<void> storeQuotesInSharedPreferences(
      List<Results>? quotes) async {
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

  static Future<Results?> getRandomQuote() async {
    Results? resultsQuote ;
    Uri url = Uri.parse('https://api.quotable.io/random');
    http.Response response = await http.get(url);
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      resultsQuote = Results.fromJson(jsonData);

      return resultsQuote;
    }

    return resultsQuote;
  }

  static Future<List<Tag>> getAllTag() async {
    Uri url = Uri.parse('https://api.quotable.io/tags');
    http.Response response = await http.get(url);
    if (response.statusCode == 200) {
      final jsontage = json.decode(response.body);
      tags = jsontage.map<Tag>((json) => Tag.fromJson(json)).toList();
      return tags;
    }
    return tags;
  }

  static Future<List<Results>?> searchs(searchh) async {
    List<Results>? listSerarh = [];
    Uri url = Uri.parse('https://api.quotable.io/search/quotes?query=$searchh');
    http.Response response = await http.get(url);
    if (response.statusCode == 200) {
      final jsonSearch = json.decode(response.body);
      listSerarh = search.fromJson(jsonSearch).results;
    }
    return listSerarh;
  }
}
