import 'package:flutter/material.dart';

class CharacterCardContainer extends StatelessWidget {
  const CharacterCardContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(12),
    this.borderRadius = 16,
  });

  final Widget child;
  final EdgeInsets padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: child,
    );
  }
}

class CharacterAvatar extends StatelessWidget {
  const CharacterAvatar({
    super.key,
    required this.picture,
    this.radius = 28,
  });

  final String? picture;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final url = picture;
    if (url == null || url.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey.shade200,
        child: Icon(Icons.person_outline, size: radius, color: Colors.grey),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey.shade200,
      backgroundImage: NetworkImage(url),
      onBackgroundImageError: (_, __) {},
    );
  }
}
