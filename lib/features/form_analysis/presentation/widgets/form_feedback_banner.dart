import 'package:calibrefit/app/app_constants.dart';
import 'package:calibrefit/features/form_analysis/domain/form_feedback.dart';
import 'package:flutter/material.dart';

/// Real-time animated feedback banner displaying biomechanical corrections and praise.
class FormFeedbackBanner extends StatelessWidget {
  const FormFeedbackBanner({super.key, required this.feedback});

  final FormFeedback? feedback;

  (Color, Color, IconData) _getSeverityStyling(FeedbackSeverity severity) {
    return switch (severity) {
      FeedbackSeverity.good => (
        const Color(0xFF10B981),
        const Color(0xFF10B981).withValues(alpha: 0.18),
        Icons.check_circle_rounded,
      ),
      FeedbackSeverity.info => (
        const Color(0xFF3B82F6),
        const Color(0xFF3B82F6).withValues(alpha: 0.18),
        Icons.info_outline_rounded,
      ),
      FeedbackSeverity.warning => (
        const Color(0xFFF59E0B),
        const Color(0xFFF59E0B).withValues(alpha: 0.18),
        Icons.warning_amber_rounded,
      ),
      FeedbackSeverity.critical => (
        const Color(0xFFEF4444),
        const Color(0xFFEF4444).withValues(alpha: 0.18),
        Icons.error_outline_rounded,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    if (feedback == null) {
      return const SizedBox.shrink();
    }

    final (color, bgColor, icon) = _getSeverityStyling(feedback!.severity);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: Container(
        key: ValueKey(feedback!.message),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: color.withValues(alpha: 0.6), width: 1.2),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                feedback!.message,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
