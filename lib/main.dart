import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";

import "package:weus/src/presentation/theme/theme.dart";
import "package:weus/src/router.dart";

/// `flutter run --flavor x` (no -t) lands here and picks the env from the flavor.
Future<void> main() => bootstrap(appFlavor ?? "dev");

/// Shared startup for every entry point (main_dev/staging/prod.dart).
Future<void> bootstrap(String flavor) async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env.$flavor");

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: "위어스",
      theme: appTheme,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
