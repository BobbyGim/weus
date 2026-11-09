import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:weus/main.dart';
import 'package:weus/splash_page.dart';

void main() {
  testWidgets('splash draws the logo, then moves to home', (tester) async {
    await tester.pumpWidget(MyApp(flavor: 'dev'));
    expect(find.byType(SplashPage), findsOneWidget);

    await tester.pump(const Duration(seconds: 2)); // animation ends
    await tester.pump(const Duration(seconds: 1)); // hold delay ends
    await tester.pumpAndSettle();
    expect(find.byType(SplashPage), findsNothing);
    expect(find.text('Flutter Demo Home Page'), findsOneWidget);
  });

  testWidgets('logo paths match the source artwork', (tester) async {
    // 1:1 with the source crop so the golden can be diffed against the PNG.
    tester.view.physicalSize = const Size(868, 712);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      Center(
        child: RepaintBoundary(
          child: SizedBox(
            width: 868,
            height: 712,
            child: CustomPaint(
              painter: LogoPainter(
                const AlwaysStoppedAnimation(1),
                const Color(0xFF111111),
              ),
            ),
          ),
        ),
      ),
    );
    await expectLater(find.byType(RepaintBoundary).first,
        matchesGoldenFile('goldens/logo.png'));
  });
}
