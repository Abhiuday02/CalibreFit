import 'dart:math' as math;

import 'package:calibrefit/app/app_constants.dart';
import 'package:calibrefit/features/nutrition/domain/daily_nutrition_log.dart';
import 'package:calibrefit/shared/cards/app_card.dart';
import 'package:flutter/material.dart';

/// A card displaying the daily caloric target, consumed calories, and remaining
/// allowance inside a circular progress ring.
class CalorieRingCard extends StatelessWidget {
  const CalorieRingCard({super.key, required this.log});

  final DailyNutritionLog log;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final target = log.target.calories;
    final consumed = log.consumedCalories;
    final remaining = log.remainingCalories;
    final progress = target > 0 ? (consumed / target).clamp(0.0, 1.0) : 0.0;
    final isOver = remaining < 0;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Calories & Energy Balance',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: isOver
                      ? colorScheme.errorContainer
                      : colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  isOver ? 'Deficit Exceeded' : 'On Track',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isOver
                        ? colorScheme.onErrorContainer
                        : colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 180,
            width: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Semantics(
                  label: AppSemantics.calorieRing,
                  value:
                      '$consumed of $target calories consumed. $remaining calories remaining.',
                  child: RepaintBoundary(
                    child: CustomPaint(
                      size: const Size(180, 180),
                      painter: _CalorieRingPainter(
                        progress: progress,
                        trackColor: colorScheme.surfaceContainerHighest,
                        progressColor: isOver
                            ? colorScheme.error
                            : colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${remaining.abs()}',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: isOver
                            ? colorScheme.error
                            : colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      isOver ? 'kcal over' : 'kcal remaining',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MetricColumn(
                label: 'Base Target',
                value: '$target kcal',
                icon: Icons.flag_outlined,
                color: colorScheme.primary,
              ),
              Container(
                height: 32,
                width: 1,
                color: colorScheme.outlineVariant.withAlpha(80),
              ),
              _MetricColumn(
                label: 'Consumed',
                value: '$consumed kcal',
                icon: Icons.restaurant_outlined,
                color: colorScheme.secondary,
              ),
              Container(
                height: 32,
                width: 1,
                color: colorScheme.outlineVariant.withAlpha(80),
              ),
              _MetricColumn(
                label: 'TDEE',
                value: '${log.target.tdee} kcal',
                icon: Icons.local_fire_department_outlined,
                color: Colors.amber.shade700,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricColumn extends StatelessWidget {
  const _MetricColumn({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 11,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _CalorieRingPainter extends CustomPainter {
  const _CalorieRingPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
  });

  final double progress;
  final Color trackColor;
  final Color progressColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 24) / 2;
    const strokeWidth = 14.0;

    // Background track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    if (progress <= 0.0) return;

    // Progress arc
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start at 12 o'clock
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CalorieRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor;
  }
}
