import 'package:flutter/material.dart';
import 'package:quote/core/ApiService.dart';
import 'package:quote/model/quote.dart';
import 'package:quote/presentation/widget/quoteWidget.dart';

class CustomSearchDelegate extends SearchDelegate {
  List<Results>? searchTerms = [];
  
  // first overwrite to
  // clear the search text
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon:const Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon:const Icon(Icons.arrow_back),
    );
  }

  // third overwrite to show query result
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
         
          return Center(
            child: Text('Error: ${snapshot.error}'),
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
              return QuoteWidget(
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

 
  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}
