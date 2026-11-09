import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

({int count, VoidCallback increment}) useHomePage() {
  final count = useState(0);

  return (count: count.value, increment: () => count.value++);
}
