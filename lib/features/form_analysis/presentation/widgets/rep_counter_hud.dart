import 'package:calibrefit/app/app_constants.dart';
import 'package:calibrefit/features/form_analysis/domain/rep_counter_state_machine.dart';
import 'package:flutter/material.dart';

/// Heads-Up Display (HUD) presenting live rep count, movement phase, and joint angle telemetry.
class RepCounterHud extends StatelessWidget {
  const RepCounterHud({
    super.key,
    required this.reps,
    required this.phase,
    required this.keyAngles,
  });

  final int reps;
  final MovementPhase phase;
  final Map<String, double> keyAngles;

  (Color, String) _getPhaseBadge() {
    return switch (phase) {
      MovementPhase.start => (Colors.blueGrey, 'Ready / Lockout'),
      MovementPhase.eccentric => (const Color(0xFF3B82F6), 'Descent Phase'),
      MovementPhase.inflection => (
        const Color(0xFFF59E0B),
        'Peak Contraction / Depth',
      ),
      MovementPhase.concentric => (const Color(0xFF8B5CF6), 'Ascent Phase'),
      MovementPhase.completed => (const Color(0xFF10B981), 'Rep Completed!'),
    };
  }

  @override
  Widget build(BuildContext context) {
    final (phaseColor, phaseLabel) = _getPhaseBadge();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Rep counter column
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'REPS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color: Colors.white70,
                    ),
                  ),
                  Text(
                    '$reps',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                ],
              ),

              // Movement Phase Pill
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: phaseColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(color: phaseColor, width: 1.2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: phaseColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      phaseLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: phaseColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (keyAngles.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            const Divider(color: Colors.white24, height: 1),
            const SizedBox(height: AppSpacing.xs),

            // Joint angle telemetry row
            Row(
              children: keyAngles.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.md),
                  child: Row(
                    children: [
                      Text(
                        '${entry.key}: ',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white70,
                        ),
                      ),
                      Text(
                        '${entry.value.toStringAsFixed(0)}°',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
