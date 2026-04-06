import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Standalone 9:16 card designed for screenshot capture.
/// Wrap this in a RepaintBoundary with a GlobalKey to capture it.
class RoastShareCard extends StatelessWidget {
  final String roastMessage;
  final int score;
  final String scoreReason;
  final String personalityTitle;
  final int streak;
  final double income;
  final double expenses;

  const RoastShareCard({
    super.key,
    required this.roastMessage,
    required this.score,
    required this.scoreReason,
    required this.personalityTitle,
    required this.streak,
    required this.income,
    required this.expenses,
  });

  Color get _scoreColor {
    if (score >= 80) return const Color(0xFF00FF7F);
    if (score >= 50) return const Color(0xFFFFDD00);
    return const Color(0xFFFF007F);
  }

  String get _scoreLabel {
    if (score >= 80) return 'Financially Disciplined';
    if (score >= 65) return 'Getting There';
    if (score >= 40) return 'Financially Chaotic';
    return 'Economically Reckless';
  }

  String get _spentStat {
    if (income <= 0) return 'No income recorded';
    final pct = ((expenses / income) * 100).toStringAsFixed(0);
    return 'Spent $pct% of income';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 1080,
      height: 1920,
      child: Stack(
        children: [
          // ── Background gradient
          _Background(scoreColor: _scoreColor),

          // ── Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 120),

                // ── Header / Branding
                Row(
                  children: [
                    const Text(
                      '🔥',
                      style: TextStyle(fontSize: 44),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'BUDGET ROAST',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4,
                          color: Colors.white.withOpacity(0.4),
                        ),
                      ),
                    ),
                    if (streak > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF9900).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFFF9900).withOpacity(0.3)),
                        ),
                        child: Text(
                          '$streak DAY STREAK 🔥',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFFFF9900),
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 80),

                // ── Score circle
                Center(child: _ScoreCircle(score: score, color: _scoreColor)),

                const SizedBox(height: 60),

                // ── Personality Badge
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: _scoreColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(color: _scoreColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      personalityTitle.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: _scoreColor,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),

                // ── Roast message (Flexible + Auto-constrained)
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child: Text(
                        roastMessage,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: roastMessage.length > 100 ? 54 : 64,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.25,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // ── Divider
                Container(
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _scoreColor.withOpacity(0.0),
                        _scoreColor.withOpacity(0.7),
                        _scoreColor.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // ── Mini data row
                Row(
                  children: [
                    Expanded(
                      child: _MiniStat(
                        icon: '📉',
                        label: _spentStat,
                        color: _scoreColor,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _MiniStat(
                        icon: '🏷️',
                        label: _scoreLabel,
                        color: _scoreColor,
                        alignment: CrossAxisAlignment.end,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 80),

                // ── Bottom branding
                Center(
                  child: Column(
                    children: [
                      Text(
                        'SmartBudgetRoast',
                        style: GoogleFonts.inter(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: Colors.white.withOpacity(0.25),
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'How broke are you?',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          color: Colors.white.withOpacity(0.15),
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Background ────────────────────────────────────────────────────────────────
class _Background extends StatelessWidget {
  final Color scoreColor;
  const _Background({required this.scoreColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Color(0xFF0A0A0A)),
      child: CustomPaint(
        painter: _GlowPainter(scoreColor),
        size: const Size(1080, 1920),
      ),
    );
  }
}

class _GlowPainter extends CustomPainter {
  final Color glowColor;
  const _GlowPainter(this.glowColor);

  @override
  void paint(Canvas canvas, Size size) {
    // Top-left subtle glow
    final paintTL = Paint()
      ..shader = RadialGradient(
        colors: [
          glowColor.withValues(alpha: 0.12),
          Colors.transparent,
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.15, size.height * 0.15),
        radius: size.width * 0.8,
      ));
    canvas.drawCircle(
        Offset(size.width * 0.15, size.height * 0.15), size.width * 0.8, paintTL);

    // Bottom-right accent glow
    final paintBR = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFF007F).withValues(alpha: 0.08),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.9, size.height * 0.85),
        radius: size.width * 0.7,
      ));
    canvas.drawCircle(
        Offset(size.width * 0.9, size.height * 0.85), size.width * 0.7, paintBR);
  }

  @override
  bool shouldRepaint(covariant _GlowPainter old) => old.glowColor != glowColor;
}

// ── Score Circle ──────────────────────────────────────────────────────────────
class _ScoreCircle extends StatelessWidget {
  final int score;
  final Color color;
  const _ScoreCircle({required this.score, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 300,
      child: CustomPaint(
        painter: _RingPainter(score / 100, color),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$score',
              style: GoogleFonts.inter(
                fontSize: 96,
                fontWeight: FontWeight.w900,
                color: color,
                height: 1,
              ),
            ),
            Text(
              '/ 100',
              style: GoogleFonts.inter(
                fontSize: 32,
                color: Colors.white.withValues(alpha: 0.5),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  const _RingPainter(this.progress, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    const strokeWidth = 12.0;

    // Track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    // Progress arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.progress != progress;
}

// ── Mini Stat ─────────────────────────────────────────────────────────────────
class _MiniStat extends StatelessWidget {
  final String icon;
  final String label;
  final Color color;
  final CrossAxisAlignment alignment;
  const _MiniStat({
    required this.icon,
    required this.label,
    required this.color,
    this.alignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(icon, style: const TextStyle(fontSize: 36)),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: alignment == CrossAxisAlignment.start
              ? TextAlign.left
              : TextAlign.right,
          style: GoogleFonts.inter(
            fontSize: 28,
            color: color.withOpacity(0.85),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
