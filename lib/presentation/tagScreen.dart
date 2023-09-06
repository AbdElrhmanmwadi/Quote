import 'package:flutter/material.dart';
import 'package:quote/core/ApiService.dart';
import 'package:quote/core/fontStyle.dart';
import 'package:quote/model/tag.dart';
import 'package:quote/presentation/QuotesScreen.dart';

class TagScreen extends StatefulWidget {
  const TagScreen({Key? key}) : super(key: key);

  @override
  _TagScreenState createState() => _TagScreenState();
}

class _TagScreenState extends State<TagScreen> {
  List<Tag> tags = [];
  List<Tag> selectedTags = [];

  @override
  void initState() {
    getTags();
    super.initState();
  }

  void getTags() async {
    tags = await ApiServies.getAllTag();
    setState(() {});
  }

  void toggleTagSelection(Tag tag) {
    setState(() {
      if (selectedTags.contains(tag)) {
        selectedTags.remove(tag);
      } else {
        if (selectedTags.length < tags.length) {
          selectedTags.add(tag);
        }
      }
    });
  }

  void navigateToAnotherPage() {
    if (selectedTags.length >= 20) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => QuotesScreen(),
      ));
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Selection Error'),
            content: Text('Please select 20 tags to proceed.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          actions: [
            IconButton(
              onPressed: navigateToAnotherPage,
              icon: Icon(
                Icons.arrow_forward,
                color: Colors.red,
              ),
            ),
          ],
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(' Select Tags',
              style: FontStyle.cormorantStyle.copyWith(
                fontSize: 25,
                fontWeight: FontWeight.w900,
                color: Colors.red,
              ))),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 5,
            children: tags.map((tag) {
              final isSelected = selectedTags.contains(tag);
              return MaterialButton(
                color: isSelected ? Colors.red : Colors.grey,
                textColor: isSelected ? Colors.white : Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                onPressed: () async {
                  toggleTagSelection(tag);
                  await ApiServies.getQuoteByTag(tag.name);

                  print(ApiServies.quoteByTag);
                },
                child: Text('${tag.name}'),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
