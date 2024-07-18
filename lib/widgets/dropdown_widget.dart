import 'package:flutter/material.dart';

class MyDropdownBox extends StatelessWidget {
  final double width;
  final String hint;
  final String? value;
  final Function(String?) onChanged;
  final Iterable<({String child, String value})> items;

  const MyDropdownBox(
      {super.key,
      required this.width,
      required this.hint,
      required this.value,
      required this.onChanged,
      required this.items});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: DropdownButtonHideUnderline(
        child: ButtonTheme(
          alignedDropdown: true,
          child: DropdownButton<String>(
            hint: Text(hint),
            value: value,
            onChanged: onChanged,
            items: items
                .map((item) => DropdownMenuItem(
                      value: item.value,
                      child: Text(item.child),
                    ))
                .toList(),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            iconSize: 24,
            elevation: 16,
          ),
        ),
      ),
    );
  }
}
