import 'package:calibrefit/app/app_constants.dart';
import 'package:flutter/material.dart';

/// Row of multi-selectable day-of-week chips (Mon - Sun).
class ReminderDayChips extends StatelessWidget {
  const ReminderDayChips({
    super.key,
    required this.selectedDays,
    required this.onDaysChanged,
    this.enabled = true,
  });

  final List<int> selectedDays; // 1 = Mon ... 7 = Sun
  final ValueChanged<List<int>> onDaysChanged;
  final bool enabled;

  static const _days = [
    (1, 'M', 'Mon'),
    (2, 'T', 'Tue'),
    (3, 'W', 'Wed'),
    (4, 'T', 'Thu'),
    (5, 'F', 'Fri'),
    (6, 'S', 'Sat'),
    (7, 'S', 'Sun'),
  ];

  void _toggleDay(int day) {
    if (!enabled) return;
    final updated = List<int>.from(selectedDays);
    if (updated.contains(day)) {
      if (updated.length > 1) {
        // Keep at least 1 day selected
        updated.remove(day);
      }
    } else {
      updated.add(day);
      updated.sort();
    }
    onDaysChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: _days.map((d) {
        final (dayNum, label, fullName) = d;
        final isSelected = selectedDays.contains(dayNum);

        return Tooltip(
          message: fullName,
          child: InkWell(
            onTap: enabled ? () => _toggleDay(dayNum) : null,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: AnimatedContainer(
              duration: AppAnimation.fast,
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? (enabled
                          ? colorScheme.primary
                          : colorScheme.primary.withAlpha(120))
                    : colorScheme.surfaceContainerHighest,
                border: Border.all(
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.outlineVariant.withAlpha(80),
                ),
              ),
              child: Center(
                child: Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? colorScheme.onPrimary
                        : (enabled
                              ? colorScheme.onSurface
                              : colorScheme.onSurface.withAlpha(100)),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
