import 'package:calibrefit/features/analytics/domain/volume_analytics.dart';
import 'package:calibrefit/features/history/domain/workout_history_record.dart';
import 'package:flutter/material.dart';

/// A custom-painted bar chart displaying weekly workout volume progression.
class WeeklyVolumeChart extends StatelessWidget {
  const WeeklyVolumeChart({super.key, required this.points, this.height = 200});

  final List<VolumeMetricPoint> points;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (points.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            'No volume data available.',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: _VolumeBarChartPainter(
          points: points,
          primaryColor: colorScheme.primary,
          secondaryColor: colorScheme.tertiary,
          gridColor: colorScheme.outlineVariant.withValues(alpha: 0.4),
          textColor: colorScheme.onSurfaceVariant,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _VolumeBarChartPainter extends CustomPainter {
  _VolumeBarChartPainter({
    required this.points,
    required this.primaryColor,
    required this.secondaryColor,
    required this.gridColor,
    required this.textColor,
  });

  final List<VolumeMetricPoint> points;
  final Color primaryColor;
  final Color secondaryColor;
  final Color gridColor;
  final Color textColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final maxVolume = points
        .map((p) => p.volumeKg)
        .fold<double>(0.0, (prev, curr) => curr > prev ? curr : prev);
    final effectiveMax = maxVolume > 0 ? maxVolume * 1.15 : 1000.0;

    const bottomPadding = 28.0;
    const topPadding = 20.0;
    final chartHeight = size.height - bottomPadding - topPadding;
    final chartWidth = size.width;

    // Draw horizontal grid lines (3 lines)
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (int i = 0; i <= 3; i++) {
      final y = topPadding + (chartHeight / 3) * i;
      canvas.drawLine(Offset(0, y), Offset(chartWidth, y), gridPaint);
    }

    final barCount = points.length;
    final totalBarSpacing = chartWidth / barCount;
    final barWidth = (totalBarSpacing * 0.55).clamp(16.0, 36.0);

    for (int i = 0; i < barCount; i++) {
      final point = points[i];
      final xCenter = totalBarSpacing * i + (totalBarSpacing / 2);
      final normalizedHeight = (point.volumeKg / effectiveMax) * chartHeight;
      final yTop = topPadding + chartHeight - normalizedHeight;
      final yBottom = topPadding + chartHeight;

      // Bar rect with rounded top
      final barRect = RRect.fromRectAndCorners(
        Rect.fromLTRB(
          xCenter - barWidth / 2,
          yTop,
          xCenter + barWidth / 2,
          yBottom,
        ),
        topLeft: const Radius.circular(6),
        topRight: const Radius.circular(6),
      );

      final isLast = i == barCount - 1;
      final barPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            isLast ? primaryColor : primaryColor.withValues(alpha: 0.85),
            isLast ? secondaryColor : primaryColor.withValues(alpha: 0.4),
          ],
        ).createShader(barRect.outerRect);

      canvas.drawRRect(barRect, barPaint);

      // Volume text on top of bar
      final volText = (point.volumeKg >= 1000)
          ? '${(point.volumeKg / 1000).toStringAsFixed(1)}k'
          : point.volumeKg.toStringAsFixed(0);

      final textPainter = TextPainter(
        text: TextSpan(
          text: volText,
          style: TextStyle(
            color: isLast ? primaryColor : textColor,
            fontSize: 10,
            fontWeight: isLast ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(xCenter - (textPainter.width / 2), yTop - 14),
      );

      // Label below bar
      final labelPainter = TextPainter(
        text: TextSpan(
          text: point.label,
          style: TextStyle(
            color: isLast ? primaryColor : textColor,
            fontSize: 11,
            fontWeight: isLast ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      labelPainter.paint(
        canvas,
        Offset(xCenter - (labelPainter.width / 2), yBottom + 8),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _VolumeBarChartPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.primaryColor != primaryColor;
  }
}

/// A custom-painted line chart displaying 1RM / load progression over time.
class ProgressionLineChart extends StatelessWidget {
  const ProgressionLineChart({
    super.key,
    required this.points,
    this.height = 180,
  });

  final List<ExerciseProgressPoint> points;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (points.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            'No progression data available.',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: _ProgressionLinePainter(
          points: points,
          lineColor: colorScheme.primary,
          accentColor: colorScheme.tertiary,
          gridColor: colorScheme.outlineVariant.withValues(alpha: 0.35),
          textColor: colorScheme.onSurfaceVariant,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _ProgressionLinePainter extends CustomPainter {
  _ProgressionLinePainter({
    required this.points,
    required this.lineColor,
    required this.accentColor,
    required this.gridColor,
    required this.textColor,
  });

  final List<ExerciseProgressPoint> points;
  final Color lineColor;
  final Color accentColor;
  final Color gridColor;
  final Color textColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    const bottomPadding = 24.0;
    const topPadding = 20.0;
    const horizontalPadding = 24.0;
    final chartHeight = size.height - bottomPadding - topPadding;
    final chartWidth = size.width - (horizontalPadding * 2);

    // Compute min and max 1RM
    double minVal = points.first.estimated1RmKg;
    double maxVal = points.first.estimated1RmKg;
    for (final p in points) {
      if (p.estimated1RmKg < minVal) minVal = p.estimated1RmKg;
      if (p.estimated1RmKg > maxVal) maxVal = p.estimated1RmKg;
    }

    final range = (maxVal - minVal) > 0 ? (maxVal - minVal) * 1.3 : 10.0;
    final effectiveMin = (minVal - (range * 0.15)).clamp(0.0, double.infinity);

    // Grid lines
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1.0;

    for (int i = 0; i <= 2; i++) {
      final y = topPadding + (chartHeight / 2) * i;
      canvas.drawLine(
        Offset(horizontalPadding, y),
        Offset(size.width - horizontalPadding, y),
        gridPaint,
      );
    }

    final stepX = points.length > 1 ? chartWidth / (points.length - 1) : 0.0;
    final offsets = <Offset>[];

    for (int i = 0; i < points.length; i++) {
      final x = horizontalPadding + (stepX * i);
      final normalizedY = (points[i].estimated1RmKg - effectiveMin) / range;
      final y = topPadding + chartHeight - (normalizedY * chartHeight);
      offsets.add(Offset(x, y));
    }

    // Gradient fill under the line
    final fillPath = Path()..moveTo(offsets.first.dx, topPadding + chartHeight);
    for (final offset in offsets) {
      fillPath.lineTo(offset.dx, offset.dy);
    }
    fillPath.lineTo(offsets.last.dx, topPadding + chartHeight);
    fillPath.close();

    final fillPaint = Paint()
      ..shader =
          LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              lineColor.withValues(alpha: 0.35),
              lineColor.withValues(alpha: 0.02),
            ],
          ).createShader(
            Rect.fromLTRB(
              horizontalPadding,
              topPadding,
              size.width - horizontalPadding,
              topPadding + chartHeight,
            ),
          );

    canvas.drawPath(fillPath, fillPaint);

    // Line stroke
    final linePath = Path()..moveTo(offsets.first.dx, offsets.first.dy);
    for (int i = 1; i < offsets.length; i++) {
      linePath.lineTo(offsets[i].dx, offsets[i].dy);
    }

    final strokePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(linePath, strokePaint);

    // Data points & callouts
    final pointPaint = Paint()..color = lineColor;
    final pointBorderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < offsets.length; i++) {
      final pt = offsets[i];
      final isLast = i == offsets.length - 1;

      canvas.drawCircle(pt, isLast ? 6.0 : 4.0, pointPaint);
      canvas.drawCircle(pt, isLast ? 6.0 : 4.0, pointBorderPaint);

      // Weight label above point
      final weightText = '${points[i].estimated1RmKg.toStringAsFixed(1)} kg';
      final textPainter = TextPainter(
        text: TextSpan(
          text: weightText,
          style: TextStyle(
            color: isLast ? lineColor : textColor,
            fontSize: 10,
            fontWeight: isLast ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(pt.dx - (textPainter.width / 2), pt.dy - 16),
      );

      // Date label below
      final dateText = '${points[i].date.day}/${points[i].date.month}';
      final datePainter = TextPainter(
        text: TextSpan(
          text: dateText,
          style: TextStyle(color: textColor, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      datePainter.paint(
        canvas,
        Offset(pt.dx - (datePainter.width / 2), topPadding + chartHeight + 6),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressionLinePainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.lineColor != lineColor;
  }
}
