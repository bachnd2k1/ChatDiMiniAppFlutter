import 'package:flutter/material.dart';

class TrendingItem extends StatelessWidget {

  final String prompt;

  const TrendingItem({super.key, required this.prompt});

  @override
  Widget build(BuildContext context) {
    return Text(
      prompt,
      style: TextStyle(
        fontSize: 17,
        fontWeight: .w400,
        color: Colors.black,
        height: 1.3,
      ),
    );
  }
}