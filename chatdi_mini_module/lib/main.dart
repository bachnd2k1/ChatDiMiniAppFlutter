import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_router.dart';
import 'core/database/local_db.dart';
import 'core/network/api_client.dart';
import 'core/utils/device_id_service.dart';
import 'data/repositories/catalog_repository.dart';
import 'data/repositories/chat_api_repository.dart';
import 'data/repositories/conversation_local_repository.dart';
import 'providers/app_config_provider.dart';
import 'providers/catalog_provider.dart';
import 'providers/session_provider.dart';
import 'mini_app_integration.dart';

Future<void> main() async {
  chatDiMiniAppEmbeddedInNativeHost = false;
  await runChatDiApp();
}

/// Entrypoint for iOS native host (Flutter add-to-app mini app mode).
@pragma('vm:entry-point')
Future<void> miniAppSplash() async {
  chatDiMiniAppEmbeddedInNativeHost = true;
  await runChatDiApp(initialRoute: AppRoutes.splash);
}

@pragma('vm:entry-point')
Future<void> miniAppMain() async {
  chatDiMiniAppEmbeddedInNativeHost = true;
  await runChatDiApp(initialRoute: AppRoutes.main);
}

Future<void> runChatDiApp({String initialRoute = AppRoutes.splash}) async {
  WidgetsFlutterBinding.ensureInitialized();

  await initLocalDb();

  await DeviceIdService.instance.getOrCreate();

  final appConfig = AppConfigProvider();
  await appConfig.hydrate();

  final apiClient = ApiClient(acceptLanguage: appConfig.languageCode);
  apiClient.setDeviceIdFuture(DeviceIdService.instance.getOrCreate());

  runApp(
    ChatDiApp(
      apiClient: apiClient,
      appConfig: appConfig,
      initialRoute: initialRoute,
    ),
  );
}

class ChatDiApp extends StatelessWidget {
  const ChatDiApp({
    super.key,
    required this.apiClient,
    required this.appConfig,
    this.initialRoute = AppRoutes.splash,
  });

  final ApiClient apiClient;
  final AppConfigProvider appConfig;
  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppConfigProvider>.value(value: appConfig),
        Provider.value(value: apiClient),
        Provider(create: (_) => CatalogRepository(apiClient)),
        Provider(create: (_) => ChatApiRepository(apiClient)),
        Provider(create: (_) => ConversationLocalRepository()),
        ChangeNotifierProvider(
          create: (ctx) => CatalogProvider(ctx.read<CatalogRepository>()),
        ),
        ChangeNotifierProvider(create: (_) => SessionProvider(apiClient)),
      ],
      child: Consumer<AppConfigProvider>(
        builder: (context, config, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'ChatDI',
            themeMode: config.darkMode ? ThemeMode.dark : ThemeMode.light,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.indigo,
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
            ),
            locale: Locale(config.languageCode),
            initialRoute: initialRoute,
            // Avoid Navigator.defaultGenerateInitialRoutes: for `/main` it would
            // still push `/` first, mount SplashScreen, then Splash replaces the
            // *top* route with onboarding after hydrate.
            onGenerateInitialRoutes: AppRoutes.initialRoutes,
            routes: AppRoutes.builders(),
          );
        },
      ),
    );
  }
}
