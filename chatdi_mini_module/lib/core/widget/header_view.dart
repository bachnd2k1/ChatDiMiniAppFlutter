import 'package:flutter/material.dart';

class HeaderView extends StatelessWidget {
  const HeaderView({
    super.key,
    this.leftWidget,
    this.centerWidget,
    this.rightWidgets = const [],
    this.height = kToolbarHeight,
  });

  final Widget? leftWidget;
  final Widget? centerWidget;
  final List<Widget> rightWidgets;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: .only(right: 16),
      child: SizedBox(
        height: height,
        child: Stack(
          children: [
            Row(
              children: [
                SizedBox(width: 56, child: leftWidget),
                const Spacer(),
                Row(mainAxisSize: MainAxisSize.min, children: rightWidgets),
              ],
            ),

            Expanded(child: Center(child: centerWidget)),
          ],
        ),
      ),
    );
  }
}
