import 'package:flutter/material.dart';

import '../../../data/models/image_style.dart';
import '../../../providers/chat_provider.dart';

class ChatStyleSelector extends StatefulWidget {
  const ChatStyleSelector({super.key, required this.chat});

  final ChatProvider chat;

  @override
  State<ChatStyleSelector> createState() => _ChatStyleSelectorState();
}

class _ChatStyleSelectorState extends State<ChatStyleSelector> {
  bool _imageTab = false;
  ImageStyle? _selectedStyle;
  int _styleCount = 0;
  bool _stylePickerEnabled = true;

  @override
  void initState() {
    super.initState();
    _syncFromChat();
    widget.chat.addListener(_onChatChromeChange);
  }

  @override
  void dispose() {
    widget.chat.removeListener(_onChatChromeChange);
    super.dispose();
  }

  void _syncFromChat() {
    final chat = widget.chat;
    _imageTab = chat.isImageTab;
    _selectedStyle = chat.selectedStyle;
    _styleCount = chat.imageStyles.length;
    _stylePickerEnabled = chat.character == null;
  }

  void _onChatChromeChange() {
    final chat = widget.chat;
    final imageTab = chat.isImageTab;
    final selectedStyle = chat.selectedStyle;
    final styleCount = chat.imageStyles.length;
    final stylePickerEnabled = chat.character == null;

    if (imageTab == _imageTab &&
        selectedStyle == _selectedStyle &&
        styleCount == _styleCount &&
        stylePickerEnabled == _stylePickerEnabled) {
      return;
    }

    setState(() {
      _imageTab = imageTab;
      _selectedStyle = selectedStyle;
      _styleCount = styleCount;
      _stylePickerEnabled = stylePickerEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    final chat = widget.chat;

    return
      Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      child: Row(
        mainAxisAlignment: .center,
        children: [
          ChoiceChip(
            label: const Text('Ask'),
            selected: !_imageTab,
            onSelected: (_) => chat.setTabAsk(),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text('Image'),
            selected: _imageTab,
            onSelected: _stylePickerEnabled ? (_) => chat.setTabImage() : null,
          ),
          // PopupMenuButton<String>(
          //   onSelected: (id) {
          //     if (id == '__clear') {
          //       chat.selectStyle(null);
          //       return;
          //     }
          //     final style = chat.imageStyles.firstWhere((s) => s.id == id);
          //     chat.selectStyle(style);
          //   },
          //   itemBuilder: (ctx) => [
          //     const PopupMenuItem<String>(
          //       value: '__clear',
          //       child: Text('Không áp style'),
          //     ),
          //     ...chat.imageStyles.map(
          //       (s) => PopupMenuItem<String>(
          //         value: s.id,
          //         child: Text(s.name),
          //       ),
          //     ),
          //   ],
          //   child: Padding(
          //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          //     child: Row(
          //       mainAxisSize: MainAxisSize.min,
          //       children: [
          //         Icon(
          //           Icons.palette_outlined,
          //           size: 18,
          //           color: _imageTab ? null : disabledColor,
          //         ),
          //         const SizedBox(width: 6),
          //         Text(
          //           _selectedStyle?.name ?? 'Style',
          //           style: TextStyle(color: _imageTab ? null : disabledColor),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
