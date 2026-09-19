import 'package:calibrefit/app/app_constants.dart';
import 'package:calibrefit/features/analytics/domain/one_rep_max.dart';
import 'package:calibrefit/features/analytics/presentation/analytics_providers.dart';
import 'package:calibrefit/shared/cards/app_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Interactive 1RM (One-Rep Max) calculator supporting Epley, Brzycki, Lander,
/// and Hybrid formulas with an expandable training percentage table.
class OneRepMaxCalculatorCard extends ConsumerStatefulWidget {
  const OneRepMaxCalculatorCard({super.key});

  @override
  ConsumerState<OneRepMaxCalculatorCard> createState() =>
      _OneRepMaxCalculatorCardState();
}

class _OneRepMaxCalculatorCardState
    extends ConsumerState<OneRepMaxCalculatorCard> {
  bool _showPercentages = false;
  late TextEditingController _weightController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(oneRepMaxCalculatorProvider);
    _weightController = TextEditingController(
      text: state.weightKg.toStringAsFixed(1),
    );
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final calcState = ref.watch(oneRepMaxCalculatorProvider);
    final notifier = ref.read(oneRepMaxCalculatorProvider.notifier);
    final estimate = calcState.estimate;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '1RM Calculator',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Scientific one-rep max estimation',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  Icons.calculate_outlined,
                  color: colorScheme.onPrimaryContainer,
                  size: 20,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Formula Selector Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: OneRepMaxFormula.values.map((formula) {
                final isSelected = calcState.formula == formula;
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.xs),
                  child: FilterChip(
                    label: Text(formula.displayName),
                    selected: isSelected,
                    onSelected: (_) => notifier.setFormula(formula),
                    selectedColor: colorScheme.primaryContainer,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Inputs Row: Weight & Reps
          Row(
            children: [
              // Weight input
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.35,
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'WEIGHT (KG)',
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () {
                              final newW = (calcState.weightKg - 2.5).clamp(
                                0.0,
                                500.0,
                              );
                              notifier.setWeight(newW);
                              _weightController.text = newW.toStringAsFixed(1);
                            },
                          ),
                          Text(
                            '${calcState.weightKg.toStringAsFixed(1)} kg',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () {
                              final newW = (calcState.weightKg + 2.5).clamp(
                                0.0,
                                500.0,
                              );
                              notifier.setWeight(newW);
                              _weightController.text = newW.toStringAsFixed(1);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: AppSpacing.sm),

              // Reps input
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.35,
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'REPS PERFORMED',
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () {
                              final newR = (calcState.reps - 1).clamp(1, 36);
                              notifier.setReps(newR);
                            },
                          ),
                          Text(
                            '${calcState.reps} reps',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () {
                              final newR = (calcState.reps + 1).clamp(1, 36);
                              notifier.setReps(newR);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Primary Estimated 1RM Callout Banner
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary.withValues(alpha: 0.15),
                  colorScheme.tertiary.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ESTIMATED 1RM (${calcState.formula.displayName.toUpperCase()})',
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      calcState.formula.formulaDescription,
                      style: textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${estimate.selected1RmKg.toStringAsFixed(1)} kg',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Formula Comparison Grid
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _FormulaComparisonPill(
                  title: 'Epley',
                  valueKg: estimate.epleyKg,
                  isSelected: calcState.formula == OneRepMaxFormula.epley,
                ),
                _FormulaComparisonPill(
                  title: 'Brzycki',
                  valueKg: estimate.brzyckiKg,
                  isSelected: calcState.formula == OneRepMaxFormula.brzycki,
                ),
                _FormulaComparisonPill(
                  title: 'Lander',
                  valueKg: estimate.landerKg,
                  isSelected: calcState.formula == OneRepMaxFormula.lander,
                ),
                _FormulaComparisonPill(
                  title: 'Average',
                  valueKg: estimate.averageKg,
                  isSelected: calcState.formula == OneRepMaxFormula.average,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // Expandable Training Percentages
          Theme(
            data: theme.copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              initiallyExpanded: _showPercentages,
              onExpansionChanged: (val) =>
                  setState(() => _showPercentages = val),
              tilePadding: EdgeInsets.zero,
              title: Text(
                'Training Percentages Table',
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              subtitle: Text(
                'Target loads from 100% to 60% of 1RM',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              children: [
                const SizedBox(height: AppSpacing.xs),
                Table(
                  columnWidths: const {
                    0: FlexColumnWidth(1.2),
                    1: FlexColumnWidth(1.5),
                    2: FlexColumnWidth(1.5),
                  },
                  children: [
                    TableRow(
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.5,
                        ),
                      ),
                      children: [
                        _buildTableHeaderCell(context, '% 1RM'),
                        _buildTableHeaderCell(context, 'Weight'),
                        _buildTableHeaderCell(context, 'Rep Capacity'),
                      ],
                    ),
                    ...estimate.trainingPercentages.map((tp) {
                      return TableRow(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: colorScheme.outlineVariant.withValues(
                                alpha: 0.3,
                              ),
                              width: 0.5,
                            ),
                          ),
                        ),
                        children: [
                          _buildTableCell(context, '${tp.percentage}%'),
                          _buildTableCell(
                            context,
                            '${tp.weightKg.toStringAsFixed(1)} kg',
                            isBold: true,
                          ),
                          _buildTableCell(context, tp.estimatedReps),
                        ],
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeaderCell(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 6,
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildTableCell(
    BuildContext context,
    String text, {
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 8,
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          color: isBold
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}

class _FormulaComparisonPill extends StatelessWidget {
  const _FormulaComparisonPill({
    required this.title,
    required this.valueKg,
    required this.isSelected,
  });

  final String title;
  final double valueKg;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Text(
          title,
          style: textTheme.labelSmall?.copyWith(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${valueKg.toStringAsFixed(1)} kg',
          style: textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: isSelected ? colorScheme.primary : colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
