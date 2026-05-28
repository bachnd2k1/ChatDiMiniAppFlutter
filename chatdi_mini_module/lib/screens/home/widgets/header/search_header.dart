import 'package:flutter/material.dart';

class HomeSearchHeader extends StatelessWidget {
  final VoidCallback? onSendTap;

  const HomeSearchHeader({super.key, this.onSendTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 0, right: 16, bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(32),
                  borderSide: const BorderSide(color: Color(0xFF0AC198)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(32),
                  borderSide: const BorderSide(
                    color: Color(0xFF0AC198),
                    width: 1,
                  ),
                ),
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(left: 12),
                  child: Icon(Icons.search, color: Colors.grey),
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 40,
                  minHeight: 40,
                ),
                hintText: 'Hỏi bất cứ điều gì',
                hintStyle: const TextStyle(color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onSendTap,
            child: Image.asset('assets/ic_send.png', width: 36, height: 36),
          ),
        ],
      ),
    );
  }
}
