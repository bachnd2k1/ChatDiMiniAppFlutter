import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_router.dart';
import '../../mini_app_integration.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/session_provider.dart';
import 'widgets/assistant/assistant_section.dart';
import 'widgets/character/character_section.dart';
import 'widgets/dynamic/dynamic_style_section.dart';
import 'widgets/header/search_header.dart';
import 'widgets/trendings/trending_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _bootstrapDone = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_bootstrapDone) return;
    _bootstrapDone = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHomeTabData();
    });
  }

  Future<void> _loadHomeTabData({bool forceRefresh = false}) async {
    final catalog = context.read<CatalogProvider>();
    final session = context.read<SessionProvider>();

    await Future.wait([
      catalog.ensureCategoriesLoaded(forceRefresh: forceRefresh),
      catalog.ensureCharactersLoaded(forceRefresh: forceRefresh),
      catalog.ensureImageGeneratorsLoaded(forceRefresh: forceRefresh),
    ]);

    final sid = await session.ensureConnectedSession();
    if (!mounted || sid == null || sid.isEmpty) return;
    await catalog.ensureHomeDynamicStylesLoaded(
      sessionId: sid,
      forceRefresh: forceRefresh,
    );
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFD4F2ED),
              Color(0xFFF0FEFA),
              Color(0xFFEFFDF9),
              Color(0xFFACE1DD),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 👉 Custom App Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    if (chatDiMiniAppEmbeddedInNativeHost)
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        tooltip: 'Đóng',
                        onPressed: () => requestChatDiMiniAppHostClose(),
                      )
                    else
                      const SizedBox(width: 48),

                    const Expanded(
                      child: Text(
                        'ChatDI',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    IconButton(
                      onPressed: () =>
                          Navigator.of(context).pushNamed(AppRoutes.settings),
                      icon: const Icon(Icons.settings_outlined),
                    ),
                  ],
                ),
              ),

              // 👉 Content
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => _loadHomeTabData(forceRefresh: true),
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    children: [
                      HomeSearchHeader(onSendTap: () {}),
                      HomeCharacterSection(
                        isLoading: catalog.charactersLoading,
                        characters: catalog.characters,
                      ),
                      if (catalog.categoriesLoading)
                        const Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else
                        HomeAssistantSection(categories: catalog.categories),
                      HomeDynamicStyleSection(
                        groupedStyles: catalog.homeDynamicGroupedStyles,
                        isLoading: catalog.homeDynamicStylesLoading,
                        onTapGenerator: () {},
                      ),
                      TrendingSection(trendings: catalog.trendings),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
