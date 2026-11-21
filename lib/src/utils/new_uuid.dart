import "dart:math";

final _random = Random.secure();

/// 랜덤 UUID v4. 같은 생성 요청을 서버가 한 번만 처리하게 하는 요청 id 등에 쓴다.
String newUuid() {
  final bytes = List.generate(16, (_) => _random.nextInt(256));

  bytes[6] = (bytes[6] & 0x0f) | 0x40; // 버전 4

  bytes[8] = (bytes[8] & 0x3f) | 0x80; // RFC 4122 변형

  final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, "0")).join();

  return "${hex.substring(0, 8)}-${hex.substring(8, 12)}-"
      "${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}";
}
