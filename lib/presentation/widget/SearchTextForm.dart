import 'package:flutter/material.dart';

class SearchTextFormField extends StatelessWidget {
  final IconData icon;
  final String hintText;
  final TextEditingController controller;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  const SearchTextFormField({
    super.key,
    required this.icon,
    required this.hintText,
    required this.controller,
    required this.onChanged,
    required this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onFieldSubmitted: onFieldSubmitted,
      onChanged: onChanged,
      controller: controller,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
        hintText: hintText,
        hintStyle: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w300,
          color: Colors.black.withOpacity(.5),
        ),
        focusColor: Colors.red,
        prefixIcon: IconButton(
          onPressed: () async {
            // showSearch(
            //   query: '${controller.text}',
            //   context: context,
            //   delegate: CustomSearchDelegate(
            //     await ApiServies.searchs('${controller.text}'),
            //   ),
            // );
          },
          icon: Icon(icon),
        ),
        fillColor: Colors.grey.withOpacity(.1),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
