import "package:connectivity_plus/connectivity_plus.dart";
import "package:riverpod_annotation/riverpod_annotation.dart";

part "offline_provider.g.dart";

/// True while the device has no network (Wi-Fi, mobile data…) at all.
/// Invalidate it to check again right now.
// shortcut: only sees the network interface, so Wi-Fi without internet counts
// as online; ping the API server here once there is one.
@riverpod
Stream<bool> offline(Ref ref) async* {
  final connectivity = Connectivity();

  yield _isOffline(await connectivity.checkConnectivity());

  yield* connectivity.onConnectivityChanged.map(_isOffline);
}

bool _isOffline(List<ConnectivityResult> results) =>
    results.contains(ConnectivityResult.none);
