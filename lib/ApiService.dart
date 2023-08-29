import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:quote/quote.dart';

class ApiServies {
 static Future<List<Results>?> getAllQuote() async {
    Uri url = Uri.parse('https://api.quotable.io/quotes');
    http.Response response = await http.get(url);
    final jsonData = json.decode(response.body);
    List<Results>? listResults = quote.fromJson(jsonData).results;
    print(listResults);
    return listResults;
  }
}
