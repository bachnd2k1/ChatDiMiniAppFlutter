import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_router.dart';
import '../../data/models/category.dart';
import '../../data/models/character.dart';
import '../../mini_app_integration.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/chat_launch_args.dart';
import '../../providers/session_provider.dart';
import '../chat/chat_screen.dart';
import './character_card_type.dart';
import 'widgets/dynamic_group_style_item.dart';
import 'widgets/large_character_card.dart';
import 'widgets/medium_character_card.dart';
import 'widgets/wide_character_card.dart';
import 'widgets/image_generator_button.dart';

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
      appBar: AppBar(
        leading: chatDiMiniAppEmbeddedInNativeHost
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Đóng',
                onPressed: () => requestChatDiMiniAppHostClose(),
              )
            : null,
        automaticallyImplyLeading: !chatDiMiniAppEmbeddedInNativeHost,
        title: const Text('ChatDI'),
        actions: [
          IconButton(
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRoutes.settings),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadHomeTabData(forceRefresh: true),
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
          children: [
            _header(),
            _characterStrip(context),
            _section(context, catalog),
            _dynamicStyleStrip(catalog),
            // _generatorStrip(context),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 0, right: 16, bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(32),
                  borderSide: BorderSide(color: Color(0xFF0AC198)),
                ),

                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(32),
                  borderSide: BorderSide(color: Color(0xFF0AC198), width: 1),
                ),

                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Icon(Icons.search, color: Colors.grey),
                ),

                prefixIconConstraints: BoxConstraints(
                  minWidth: 40,
                  minHeight: 40,
                ),

                hintText: 'Hỏi bất cứ điều gì',
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
          ),

          SizedBox(width: 12),

          GestureDetector(
            onTap: () {},
            child: Image.asset('assets/ic_send.png', width: 36, height: 36),
          ),
        ],
      ),
    );
  }

  Widget _section(BuildContext context, CatalogProvider catalog) {
    if (catalog.categoriesLoading) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final items = catalog.categories;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Row(
            children: [
              Text(
                'Assistants',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              Spacer(),
              Text(
                'See All',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: (SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (ctx, i) => SizedBox(
                width: 60,
                child: _AssistantCard(category: items[i]),
              ),
            ),
          )),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _allStylish(CatalogProvider catalog) {
    return catalog.homeDynamicGroupedStyles
        .take(5)
        .expand((group) {
          final stylish = group['stylish'];
          if (stylish is! List) return const <Map<String, dynamic>>[];
          return stylish.whereType<Map<String, dynamic>>();
        })
        .where((item) {
          final thumbnail = '${item['thumbnail'] ?? ''}'.toLowerCase();
          return !thumbnail.endsWith('.webm');
        })
        .toList();
  }

  Widget _dynamicStyleStrip(CatalogProvider catalog) {
    if (catalog.homeDynamicStylesLoading &&
        catalog.homeDynamicGroupedStyles.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: LinearProgressIndicator(),
      );
    }
    if (catalog.homeDynamicStylesError != null ||
        catalog.homeDynamicGroupedStyles.isEmpty) {
      return const SizedBox.shrink();
    }

    final allStylish = _allStylish(catalog);
    final dataFirst = allStylish.skip(2).take(4).toList();
    final dataSecond = allStylish.skip(7).take(5).toList();
    if (dataFirst.isEmpty && dataSecond.isEmpty) return const SizedBox.shrink();

    Widget buildRow(
      List<Map<String, dynamic>> rowData, {
      bool isRowFirst = true,
    }) {
      if (rowData.isEmpty) return const SizedBox.shrink();
      return SizedBox(
        height: 120,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: rowData.length,
          separatorBuilder: (_, _) => const SizedBox(width: 12),
          itemBuilder: (_, i) =>
              DynamicGroupStyleItem(item: rowData[i], width: 110),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildRow(dataFirst),
                buildRow(
                  dataSecond,
                  isRowFirst: false,
                ),

              ],
            ),
          ),

          ImageGeneratorButton(onTap: () {

          }),
        ],
      ),
    );
  }

  Widget buildShiftedRow({required Widget child, required double offsetLeft}) {
    return Padding(
      padding: EdgeInsets.only(right: offsetLeft.abs()),
      child: Transform.translate(offset: Offset(offsetLeft, 0), child: child),
    );
  }

  Widget _characterStrip(BuildContext context) {
    return Consumer<CatalogProvider>(
      builder: (ctx, catalog, _) {
        final chars = catalog.characters;
        return Padding(
          padding: const EdgeInsets.only(
            left: 16,
            top: 0,
            right: 16,
            bottom: 12,
          ),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Color(0xFF0AC198), Color(0xFF019AB1)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text(
                      'Characters',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    Spacer(),
                    Text(
                      'See All',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (catalog.charactersLoading)
                  const LinearProgressIndicator(
                    color: Colors.white,
                    backgroundColor: Colors.white24,
                  )
                else if (chars.isEmpty)
                  const Text(
                    'Đang không có nhân vật — vuốt xuống để prefetch.',
                    style: TextStyle(color: Colors.white),
                  )
                else
                  _characterGrid(context, chars.take(5).toList()),
              ],
            ),
          ),
        );
      },
    );
  }

  static const double _characterCardGap = 8;
  static const double _characterTopRowHeight = 248;

  Widget _characterGrid(BuildContext context, List<CharacterModel> chars) {
    return Column(
      children: [
        SizedBox(
          height: _characterTopRowHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _buildCharacterCard(context, chars[0], getCardType(0)),
              ),
              const SizedBox(width: _characterCardGap),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: _buildCharacterCard(
                        context,
                        chars[1],
                        getCardType(1),
                      ),
                    ),
                    const SizedBox(height: _characterCardGap),
                    Expanded(
                      child: _buildCharacterCard(
                        context,
                        chars[2],
                        getCardType(2),
                      ),
                    ),
                    const SizedBox(height: _characterCardGap),
                    Expanded(
                      child: _buildCharacterCard(
                        context,
                        chars[3],
                        getCardType(3),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: _characterCardGap),
        _buildCharacterCard(context, chars[4], getCardType(4)),
      ],
    );
  }

  Widget _buildCharacterCard(
    BuildContext context,
    CharacterModel item,
    CharacterCardType type,
  ) {
    void openChat() =>
        ChatScreen.open(context, ChatLaunchArgs.characterChat(item));

    switch (type) {
      case CharacterCardType.large:
        return LargeCharacterCard(item: item, onTap: openChat);
      case CharacterCardType.medium:
        return MediumCharacterCard(item: item, onTap: openChat);
      case CharacterCardType.wide:
        return WideCharacterCard(item: item, onTap: openChat);
    }
  }

  CharacterCardType getCardType(int index) {
    switch (index) {
      case 0:
        return CharacterCardType.large;

      case 4:
        return CharacterCardType.wide;

      default:
        return CharacterCardType.medium;
    }
  }

  // Widget _generatorStrip(BuildContext context) {
  //   return Consumer<CatalogProvider>(
  //     builder: (ctx, catalog, _) {
  //       final gens = catalog.imageGenerators;
  //       return Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Padding(
  //             padding: const EdgeInsets.only(top: 24, bottom: 8),
  //             child: Text(
  //               'Image presets',
  //               style: Theme.of(context).textTheme.titleMedium,
  //             ),
  //           ),
  //           if (catalog.imageGeneratorsLoading)
  //             const LinearProgressIndicator()
  //           else if (gens.isEmpty)
  //             const Text(
  //               'Đang chờ prefetch Preset — mở tab Image Generator một lần.',
  //             )
  //           else
  //             ...gens
  //                 .take(4)
  //                 .map(
  //                   (ImageGeneratorModel g) => ListTile(
  //                     leading: const Icon(Icons.auto_fix_high_outlined),
  //                     title: Text(g.name),
  //                     subtitle: Text(
  //                       g.prompt ?? '',
  //                       maxLines: 2,
  //                       overflow: TextOverflow.ellipsis,
  //                     ),
  //                     onTap: () => ChatScreen.open(
  //                       context,
  //                       ChatLaunchArgs.generatorPreset(g),
  //                     ),
  //                   ),
  //                 ),
  //         ],
  //       );
  //     },
  //   );
  // }
}

class _AssistantCard extends StatelessWidget {
  const _AssistantCard({required this.category});

  final Category category;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        ChatScreen.open(context, ChatLaunchArgs.assistantSuggestions(category));
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade200,
            ),
            alignment: Alignment.center,
            child: Text(
              category.icon ?? '',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            category.name,
            style: const TextStyle(fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
