import "dart:async";

import "package:flutter/services.dart";
import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:intl/date_symbol_data_local.dart";
import "package:material_ui/material_ui.dart";
import "package:supabase_flutter/supabase_flutter.dart";
import "package:weus/src/data/data.dart";
import "package:weus/src/presentation/pages/pages.dart";
import "package:weus/src/presentation/theme/theme.dart";
import "package:weus/src/router/router.dart";

/// `flutter run --flavor x` (no -t) lands here and picks the env from the flavor.
Future<void> main() => bootstrap(appFlavor ?? "dev");

/// Shared startup for every entry point (main_dev/staging/prod.dart).
Future<void> bootstrap(String flavor) async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env.$flavor");

  await Supabase.initialize(
    url: dotenv.env["SUPABASE_URL"]!,
    publishableKey: dotenv.env["SUPABASE_PUBLISHABLE_KEY"]!,
  );

  // Korean month/weekday names for DateFormat (the schedule calendar).
  await initializeDateFormatting("ko_KR");

  await _precacheImages();

  runApp(const ProviderScope(child: MyApp()));
}

/// assets/image/ 아래 PNG를 네이티브 스플래시가 떠 있는 동안 미리 디코딩해 둔다.
/// 어느 화면이든 처음 열릴 때 이미지가 빈 프레임 없이 바로 보인다.
/// SVG는 캐시 키가 화면의 글자 크기를 포함해서 여기서 미리 넣어도 맞지 않는다.
Future<void> _precacheImages() async {
  final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);

  final config = ImageConfiguration(
    bundle: rootBundle,
    devicePixelRatio: WidgetsBinding
        .instance
        .platformDispatcher
        .implicitView
        ?.devicePixelRatio,
  );

  final paths = manifest.listAssets().where(
    (path) => path.startsWith("assets/image/") && path.endsWith(".png"),
  );

  await Future.wait([
    for (final path in paths) _precache(AssetImage(path), config),
  ]);
}

/// precacheImage와 같은 일을 BuildContext 없이 한다. 실패해도 앱 시작은 막지 않는다.
Future<void> _precache(ImageProvider image, ImageConfiguration config) {
  final done = Completer<void>();

  final stream = image.resolve(config);

  late final ImageStreamListener listener;

  void finish() {
    if (!done.isCompleted) done.complete();

    // 리스너를 떼도 이미지는 ImageCache에 남는다.
    stream.removeListener(listener);
  }

  listener = ImageStreamListener(
    (_, _) => finish(),
    onError: (_, _) => finish(),
  );

  stream.addListener(listener);

  return done.future;
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Still unknown at launch counts as online.
    final offline = ref.watch(offlineProvider).value ?? false;

    // 로그인돼 있으면 앱을 켜자마자 프로필을 뒤에서 불러온다 (화면은 기다리지 않음).
    ref.listen(myProfileProvider, (_, _) {});

    return MaterialApp.router(
      title: "위어스",
      theme: appTheme,
      // Korean only: Material's own texts (date picker, tooltips) follow it.
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [Locale("ko", "KR")],
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
