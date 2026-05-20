import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../mini_app_integration.dart';
import '../providers/catalog_provider.dart';
import 'history_screen.dart';
import 'home/home_screen.dart';
import 'channel/assistants_screen.dart';
import 'channel/characters_screen.dart';
import 'channel/image_generators_screen.dart';

// class MainShellScreen extends StatefulWidget {
//   const MainShellScreen({super.key});
//
//   @override
//   State<MainShellScreen> createState() => _MainShellScreenState();
// }
//
// class _MainShellScreenState extends State<MainShellScreen> {
//   int index = 0;
//
//   final _pages = const [
//     HomeScreen(),
//     AssistantsScreen(),
//     ImageGeneratorsScreen(),
//     CharactersScreen(),
//     HistoryScreen(),
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<CatalogProvider>().prefetchTabData();
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: IndexedStack(index: index, children: _pages.toList()),
//       bottomNavigationBar: NavigationBar(
//         selectedIndex: index,
//         destinations: const [
//           NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
//           NavigationDestination(icon: Icon(Icons.support_agent), label: 'Assistants'),
//           NavigationDestination(icon: Icon(Icons.photo_outlined), label: 'Image'),
//           NavigationDestination(icon: Icon(Icons.face_outlined), label: 'Characters'),
//           NavigationDestination(icon: Icon(Icons.history), label: 'History'),
//         ],
//         onDestinationSelected: (value) => setState(() => index = value),
//       ),
//     );
//   }
// }

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int index = 0;

  final _pages = const [
    HomeScreen(),
    AssistantsScreen(),
    ImageGeneratorsScreen(),
    CharactersScreen(),
    HistoryScreen(),
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CatalogProvider>().prefetchTabData();
    });
  }

  Future<void> _handleBack() async {
    final navigator = Navigator.of(context);

    // inner routes
    if (navigator.canPop()) {
      navigator.pop();
      return;
    }

    // close native host
    if (chatDiMiniAppEmbeddedInNativeHost) {
      await requestChatDiMiniAppHostClose();
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !chatDiMiniAppEmbeddedInNativeHost,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _handleBack();
      },
      child: Scaffold(
        body: IndexedStack(
          children: _pages,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: index,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.support_agent),
              label: 'Assistants',
            ),
            NavigationDestination(
              icon: Icon(Icons.photo_outlined),
              label: 'Image',
            ),
            NavigationDestination(
              icon: Icon(Icons.face_outlined),
              label: 'Characters',
            ),
            NavigationDestination(
              icon: Icon(Icons.history),
              label: 'History',
            ),
          ],
          onDestinationSelected: (value) {
            setState(() {
              index = value;
            });
          },
        ),
      ),
    );
  }
}