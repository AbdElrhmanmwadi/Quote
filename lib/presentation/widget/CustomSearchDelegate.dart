import 'package:flutter/material.dart';
import 'package:quote/core/ApiService.dart';
import 'package:quote/model/quote.dart';
import 'package:quote/presentation/widget/quoteWidget.dart';

class CustomSearchDelegate extends SearchDelegate {
  List<Results>? searchTerms = [];

  
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<List<Results>?>(
      future: ApiServies.searchs(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.red),
            ),
          );
        } else if (snapshot.hasError) {
          return const Center(
            child: Text('No Internet Connection'),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('Not Found Any Result'),
          );
        } else {
          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final result = snapshot.data![index];
              final content = result.content!;
              final highlightedContent = _highlightSearchTerm(content, query);
              return QuoteWidget(
                IsSearch: true,
                highlightedContent: highlightedContent,
                id: snapshot.data![index].sId!,
                currentIndex: index,
                lists: snapshot.data,
                index: index,
              );
            },
          );
        }
      },
    );
  }


  TextSpan _highlightSearchTerm(String content, String searchTerm) {
    final contentLower = content.toLowerCase();
    final searchTermLower = searchTerm.toLowerCase();
    final spans = <TextSpan>[];
    int start = 0;

    while (start < contentLower.length) {
      final startIndex = contentLower.indexOf(searchTermLower, start);
      if (startIndex == -1) {
        spans.add(TextSpan(text: content.substring(start)));
        break;
      }

      final endIndex = startIndex + searchTermLower.length;
      spans.add(TextSpan(text: content.substring(start, startIndex)));
      spans.add(
        TextSpan(
          text: content.substring(startIndex, endIndex),
          style:const TextStyle(
            backgroundColor: Colors.yellow,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

      start = endIndex;
    }

    return TextSpan(children: spans);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}
