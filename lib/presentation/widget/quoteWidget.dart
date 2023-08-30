import 'package:flutter/material.dart';
import 'package:quote/core/fontStyle.dart';
import 'package:quote/domain/quote.dart';

class QuoteWidget extends StatelessWidget {
  const QuoteWidget({
    super.key,
    required int currentIndex,
    required this.lists,
    required this.index,
  }) : _currentIndex = currentIndex;

  final int _currentIndex;
  final List<Results>? lists;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          SelectableText(
            lists![index].content!,
            style: FontStyle.cormorantStyle
                .copyWith(fontWeight: FontWeight.w600, color: Colors.black),
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
          Text(
            " ${lists![index].author}",
            style: FontStyle.cormorantStyle
                .copyWith(fontWeight: FontWeight.w600, color: Colors.grey),
            textAlign: TextAlign.end,
          ),
        ],
      ),
    );
  }
}
