import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'main.dart';

part 'router.g.dart';

/// App router. Add routes here; auth redirects can `ref.watch` providers.
@Riverpod(keepAlive: true)
GoRouter router(Ref ref) => GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (_, _) => const MyHomePage(title: 'Flutter Demo Home Page'),
    ),
  ],
);
