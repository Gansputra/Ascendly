import 'dart:async';
import 'dart:math';
import 'package:ascendly/core/theme.dart';
import 'package:flutter/material.dart';

class StreakGauge extends StatefulWidget {
  final Duration duration;
  final double size;

  const StreakGauge({
    Key? key,
    required this.duration,
    this.size = 200,
  }) : super(key: key);

  @override
  State<StreakGauge> createState() => _StreakGaugeState();
}

class _StreakGaugeState extends State<StreakGauge> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _shineController;
  late AnimationController _drawController;
  late Animation<double> _drawAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _drawController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _drawAnimation = CurvedAnimation(
      parent: _drawController,
      curve: Curves.fastOutSlowIn,
    );
    
    // Start draw animation
    _drawController.forward();
    
    // Periodically trigger shine (start after draw finish)
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        Timer.periodic(const Duration(seconds: 6), (timer) {
          if (mounted) _shineController.forward(from: 0);
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shineController.dispose();
    _drawController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final days = widget.duration.inDays;
    // Progress of the current 24-hour cycle
    final progress = (widget.duration.inSeconds % (24 * 3600)) / (24 * 3600);
    
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Glow
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                width: widget.size * 0.7,
                height: widget.size * 0.7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.2 + (_pulseController.value * 0.1)),
                      blurRadius: 50 + (_pulseController.value * 20),
                      spreadRadius: 2 + (_pulseController.value * 5),
                    ),
                  ],
                ),
              );
            },
          ),
          
          // Custom Painter for Gauge
          AnimatedBuilder(
            animation: Listenable.merge([_shineController, _drawController]),
            builder: (context, child) {
              return CustomPaint(
                size: Size(widget.size, widget.size),
                painter: GaugePainter(
                  progress: progress * _drawAnimation.value,
                  color: Colors.white,
                  backgroundColor: Colors.white.withOpacity(0.15),
                  shineProgress: _shineController.value,
                ),
              );
            },
          ),
          
          // Streak Info
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$days',
                style: TextStyle(
                  fontSize: widget.size * 0.32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1,
                  shadows: [
                    Shadow(
                      color: Colors.white.withOpacity(0.5),
                      blurRadius: 15,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'DAYS',
                style: TextStyle(
                  fontSize: widget.size * 0.07,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 6,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 12),
              // Level/Power indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bolt, color: Colors.orangeAccent, size: widget.size * 0.08),
                    Text(
                      'CORE POWER',
                      style: TextStyle(
                        fontSize: widget.size * 0.05,
                        fontWeight: FontWeight.bold,
                        color: Colors.orangeAccent,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class GaugePainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;
  final double shineProgress;

  GaugePainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
    required this.shineProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (min(size.width, size.height) / 2) - 20;
    const strokeWidth = 18.0;

    // Draw Background Track
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Glow Effect for the progress arc
    final glowPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 10
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    // Progress Paint
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const startAngle = -pi / 2;
    final sweepAngle = 2 * pi * progress;

    if (progress > 0) {
      // Glow Arc
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        glowPaint,
      );

      // Main Arc
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );

      // Shine Sweep Effect
      if (shineProgress > 0 && shineProgress < 1) {
        final shinePaint = Paint()
          ..color = Colors.white.withOpacity(0.8 * (1 - (shineProgress - 0.5).abs() * 2))
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth + 2
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

        final shineStart = startAngle + (sweepAngle * shineProgress) - (pi / 8);
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          shineStart,
          pi / 4,
          false,
          shinePaint,
        );
      }
    }
    
    // Tip glow
    if (progress > 0) {
      final tipAngle = startAngle + sweepAngle;
      final tipOffset = Offset(
        center.dx + radius * cos(tipAngle),
        center.dy + radius * sin(tipAngle),
      );
      
      final tipPaint = Paint()..color = Colors.white;
      canvas.drawCircle(tipOffset, 4, tipPaint);
      
      final tipGlow = Paint()
        ..color = Colors.white.withOpacity(0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
      canvas.drawCircle(tipOffset, 12, tipGlow);
    }
  }

  @override
  bool shouldRepaint(covariant GaugePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.shineProgress != shineProgress;
  }
}
