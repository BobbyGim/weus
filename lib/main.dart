import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:intl/date_symbol_data_local.dart";

import "package:weus/src/data/data.dart";
import "package:weus/src/presentation/pages/pages.dart";
import "package:weus/src/presentation/theme/theme.dart";
import "package:weus/src/router.dart";

/// `flutter run --flavor x` (no -t) lands here and picks the env from the flavor.
Future<void> main() => bootstrap(appFlavor ?? "dev");

/// Shared startup for every entry point (main_dev/staging/prod.dart).
Future<void> bootstrap(String flavor) async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env.$flavor");

  // Korean month/weekday names for DateFormat (the schedule calendar).
  await initializeDateFormatting("ko_KR");

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Still unknown at launch counts as online.
    final offline = ref.watch(offlineProvider).value ?? false;

    return MaterialApp.router(
      title: "위어스",
      theme: appTheme,
      routerConfig: ref.watch(routerProvider),
      // The router stays mounted under the offline page, so reconnecting
      // lands back on the same screen with its state.
      builder: (_, child) => Stack(
        children: [
          ExcludeSemantics(excluding: offline, child: child),

          if (offline)
            OfflinePage(onRetry: () => ref.invalidate(offlineProvider)),
        ],
      ),
    );
  }
}
