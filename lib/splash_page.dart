import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Draws the logo outline, fills it in, then moves on to /home.
/// The native splash shows only the background color, so this picks up seamlessly.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key, required this.dark});

  /// dev/staging use the inverted (dark) look, prod is light.
  final bool dark;

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );

  @override
  void initState() {
    super.initState();
    final reduceMotion = WidgetsBinding
        .instance.platformDispatcher.accessibilityFeatures.disableAnimations;
    if (reduceMotion) _controller.value = 1;
    _controller.forward().whenComplete(() async {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      if (mounted) context.go('/home');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.dark ? const Color(0xFF111111) : Colors.white;
    final ink = widget.dark ? Colors.white : const Color(0xFF111111);
    return Scaffold(
      backgroundColor: bg,
      body: Center(
        child: SizedBox(
          width: 180,
          child: AspectRatio(
            aspectRatio: LogoPainter.viewBox.width / LogoPainter.viewBox.height,
            child: CustomPaint(painter: LogoPainter(_controller, ink)),
          ),
        ),
      ),
    );
  }
}

/// The app logo as vector paths, traced from assets/logo (source is 1254px square).
class LogoPainter extends CustomPainter {
  LogoPainter(this.progress, this.color) : super(repaint: progress);

  final Animation<double> progress;
  final Color color;

  static const viewBox = Rect.fromLTRB(193, 233, 1061, 945);
  static final List<Path> parts = _buildParts();
  static final List<PathMetric> _metrics = [
    for (final p in parts) ...p.computeMetrics(),
  ];
  static final double _totalLength =
      _metrics.fold<double>(0, (sum, m) => sum + m.length);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / viewBox.width);
    canvas.translate(-viewBox.left, -viewBox.top);

    final t = progress.value;
    // 0-75%: trace the outline. 60-100%: fill fades in over it.
    final drawn = Curves.easeInOut.transform((t / .75).clamp(0, 1));
    final fill = Curves.easeOut.transform(((t - .6) / .4).clamp(0, 1));

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color;
    var remaining = drawn * _totalLength;
    for (final m in _metrics) {
      if (remaining <= 0) break;
      canvas.drawPath(m.extractPath(0, math.min(remaining, m.length)), stroke);
      remaining -= m.length;
    }

    if (fill > 0) {
      final paint = Paint()..color = color.withValues(alpha: fill);
      for (final p in parts) {
        canvas.drawPath(p, paint);
      }
    }
  }

  @override
  bool shouldRepaint(LogoPainter old) => old.color != color;

  static List<Path> _buildParts() {
    const r8 = Radius.circular(8);
    var vertical = Path()
      ..addRRect(RRect.fromLTRBR(585, 242, 668, 600, r8));
    // Concave bottom of the cross, clearing the center head.
    vertical = Path.combine(
      PathOperation.difference,
      vertical,
      Path()
        ..addOval(Rect.fromCircle(center: const Offset(626, 684), radius: 112)),
    );
    final cross = Path.combine(
      PathOperation.union,
      vertical,
      Path()..addRRect(RRect.fromLTRBR(473, 336, 781, 409, r8)),
    );

    Path head(double x, double y, double r) =>
        Path()..addOval(Rect.fromCircle(center: Offset(x, y), radius: r));

    final centerBody = Path()
      ..moveTo(424, 890)
      ..cubicTo(475, 815, 550, 780, 626, 780)
      ..cubicTo(702, 780, 777, 815, 828, 890)
      ..arcToPoint(const Offset(800, 929), radius: const Radius.circular(21))
      ..cubicTo(745, 897, 690, 882, 626, 882)
      ..cubicTo(562, 882, 507, 897, 452, 929)
      ..arcToPoint(const Offset(424, 890), radius: const Radius.circular(21))
      ..close();

    final leftBody = Path()
      ..moveTo(206, 902)
      ..cubicTo(228, 845, 290, 790, 362, 790)
      ..cubicTo(400, 790, 432, 798, 461, 815)
      ..quadraticBezierTo(428, 843, 403, 881)
      ..cubicTo(330, 874, 280, 885, 224, 915)
      ..arcToPoint(const Offset(206, 902), radius: const Radius.circular(11))
      ..close();
    // Right body mirrors the left around x = 627 (1254 / 2).
    final rightBody = leftBody.transform(Float64List.fromList(
        [-1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 1254, 0, 0, 1]));

    return [
      cross,
      head(626, 684, 81),
      centerBody,
      head(367, 707, 71),
      leftBody,
      head(887, 707, 71),
      rightBody,
    ];
  }
}
