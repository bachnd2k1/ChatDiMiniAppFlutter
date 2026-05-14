import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

/// Web: không đọc `File` cục bộ; chỉ network + data-uri.
Widget chatSseImageBody(String? payload, {double maxHeight = 220}) {
  final p = payload?.trim();
  if (p == null || p.isEmpty) return const SizedBox.shrink();

  if (p.startsWith('http://') || p.startsWith('https://')) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight, maxWidth: 360),
        child: Image.network(
          p,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              SelectableText(p, style: TextStyle(fontSize: 12, color: Colors.red.shade300)),
          loadingBuilder: (ctx, child, prog) {
            if (prog == null) return child;
            return const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()));
          },
        ),
      ),
    );
  }

  final bytes = _tryMemoryImage(p);
  if (bytes != null) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight, maxWidth: 360),
        child: Image.memory(bytes, fit: BoxFit.cover),
      ),
    );
  }

  return SelectableText(
    p,
    style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
    maxLines: 4,
  );
}

Uint8List? _tryMemoryImage(String p) {
  if (!p.startsWith('data:image')) return null;
  try {
    final comma = p.indexOf(',');
    if (comma < 0) return null;
    return Uint8List.fromList(base64Decode(p.substring(comma + 1)));
  } catch (_) {
    return null;
  }
}
