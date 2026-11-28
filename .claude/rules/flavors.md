---
paths:
  - "android/**"
  - "ios/**"
  - "lib/main*.dart"
  - "pubspec.yaml"
  - ".env*"
  - "flutter_launcher_icons-*.yaml"
  - "flutter_native_splash-*.yaml"
  - "assets/logo/**"
---

# Flavors, icons, splash, native config

- `flutter run --flavor staging -t lib/main_staging.dart` (entry files `main_<flavor>.dart` call `bootstrap('<flavor>')` in `main.dart`). Keep `--flavor` and `-t` matching. Plain `flutter run` → `dev` (`default-flavor` in pubspec, env from `appFlavor`).
- App-wide startup code goes in `bootstrap()` in `lib/main.dart`, not in the per-flavor entry files.
- Android: `productFlavors` in `android/app/build.gradle.kts`, label via `resValue("string","app_name")`.
- iOS: build configs `Debug-<flavor>` / `Release-<flavor>` / `Profile-<flavor>` + schemes `dev`/`staging`/`prod`. Bundle id and `APP_DISPLAY_NAME` (→ `CFBundleDisplayName`) are set per config in `project.pbxproj`. Adding a flavor means adding all three configs + a scheme.
- Env: `main.dart` loads `.env.$appFlavor` via `flutter_dotenv`. `.env.*` files are gitignored but declared as assets, so a fresh clone must create `.env.dev`, `.env.staging`, `.env.prod` from `.env.example` before building. Everything in them ships inside the app bundle — no real secrets.
- Icons & splash per flavor: prod = light (white bg, dark logo), dev/staging = inverted (dark `#111111` bg, white logo). Sources in `assets/logo/`; configs `flutter_launcher_icons-<flavor>.yaml` / `flutter_native_splash-<flavor>.yaml`. Regenerate with `dart run flutter_launcher_icons` and `dart run flutter_native_splash:create --flavors dev,staging,prod`. iOS configs point at `AppIcon-<flavor>` and `LAUNCH_SCREEN_STORYBOARD=LaunchScreen<Flavor>` (Info.plist uses `$(LAUNCH_SCREEN_STORYBOARD)`); re-running the splash generator does not touch these.
- Splash is native only (no Flutter splash page): logo `splash_<light|dark>.png` (@4x, 180pt) + bottom wordmark `branding_<light|dark>.png` ("WeUs"); Android 12 uses `splash_a12_*.png` (1152px, logo kept inside the icon circle). If startup work is added (e.g. auth check), keep the native splash up with `FlutterNativeSplash.preserve()` / `remove()` instead of adding a splash route, so deep links land directly on their page.
- Deep link scheme: iOS `APP_URL_SCHEME` per build config in `project.pbxproj` → `CFBundleURLTypes` in Info.plist. Android `manifestPlaceholders["appScheme"]` per flavor → VIEW intent-filter in AndroidManifest.
- Android `compileSdk = 37` (required by `permission_handler`); `android.suppressUnsupportedCompileSdk=37` silences the AGP warning.
