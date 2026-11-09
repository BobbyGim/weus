import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'features/home/home.dart';

part 'router.g.dart';

/// App router. Add routes here; auth redirects can `ref.watch` providers.
@Riverpod(keepAlive: true)
GoRouter router(Ref ref) => GoRouter(
  routes: [GoRoute(path: '/', builder: (_, _) => const HomePage())],
);
