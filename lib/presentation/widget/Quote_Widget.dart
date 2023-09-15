import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quote/core/shared_preferences.dart';
import 'package:quote/core/font_style.dart';
import 'package:quote/model/quote.dart';
import 'package:quote/presentation/cubit/favorite_cubit.dart';
import 'package:quote/presentation/widget/Quote_Controller.dart';

class quoteWidget extends StatelessWidget {
 const quoteWidget({
    super.key,
    required int currentIndex,
    required this.lists,
    required this.index,
    required this.id,
    this.highlightedContent,
    this.isSearch = false,
  }) : _currentIndex = currentIndex;
  final bool isSearch;
  final TextSpan? highlightedContent;
  final int _currentIndex;
  final List<Results>? lists;
  final int index;
  final String id;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "No.",
              style: FontStyle.cormorantStyle,
              textAlign: TextAlign.end,
            ),
            Text(
              " ______",
              style: FontStyle.cormorantStyle
                  .copyWith(fontWeight: FontWeight.w300, color: Colors.grey),
              textAlign: TextAlign.end,
            ),
            Text(
              "${_currentIndex + 1}",
              style: FontStyle.cormorantStyle.copyWith(
                fontSize: 25,
              ),
              textAlign: TextAlign.end,
            ),
            isSearch
                ? SelectableText.rich(
                    highlightedContent!,
                    style: FontStyle.cormorantStyle.copyWith(
                        fontWeight: FontWeight.w600, color: Colors.black),
                    textAlign: TextAlign.center,
                  )
                : SelectableText(
                    lists![index].content!,
                    style: FontStyle.cormorantStyle.copyWith(
                        fontWeight: FontWeight.w600, color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
            const SizedBox(height: 10),
            Text(
              " ______",
              style: FontStyle.cormorantStyle
                  .copyWith(fontWeight: FontWeight.w300, color: Colors.grey),
              textAlign: TextAlign.end,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  " ${lists![index].author}",
                  style: FontStyle.cormorantStyle.copyWith(
                      fontWeight: FontWeight.w400, color: Colors.black),
                  textAlign: TextAlign.end,
                ),
                Row(
                  children: [
                    BlocBuilder<FavoriteCubit, FavoriteState>(
                      builder: (context, state) {
                        bool favorite = SharedPrefController().getData(key: id);
                        return IconButton(
                            icon: Icon(
                              favorite ? Icons.favorite : Icons.favorite_border,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              context.read<FavoriteCubit>().toggleFavorite(
                                    id,
                                  );
                              SharedPrefController().setData(id, !favorite);
                            });
                      },
                    ),
                    IconButton(
                        icon: Icon(
                          Icons.share,
                          color: Colors.grey[700],
                        ),
                        onPressed: () async {
                          QuoteController.shareQuote(lists, _currentIndex);
                        }),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
