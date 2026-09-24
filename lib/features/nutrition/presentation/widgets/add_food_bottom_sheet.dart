import 'package:calibrefit/app/app_constants.dart';
import 'package:calibrefit/features/nutrition/domain/food_item.dart';
import 'package:calibrefit/features/nutrition/presentation/nutrition_providers.dart';
import 'package:calibrefit/shared/loaders/app_loader.dart';
import 'package:calibrefit/shared/widgets/app_error_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Modal bottom sheet allowing the user to search the food database,
/// select a serving quantity, and log the item to a specific [MealType].
class AddFoodBottomSheet extends ConsumerStatefulWidget {
  const AddFoodBottomSheet({super.key, required this.mealType});

  final MealType mealType;

  static Future<void> show(BuildContext context, MealType mealType) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (_) => AddFoodBottomSheet(mealType: mealType),
    );
  }

  @override
  ConsumerState<AddFoodBottomSheet> createState() => _AddFoodBottomSheetState();
}

class _AddFoodBottomSheetState extends ConsumerState<AddFoodBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  FoodItem? _selectedFood;
  double _servings = 1.0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onFoodSelected(FoodItem food) {
    setState(() {
      _selectedFood = food;
      _servings = 1.0;
    });
  }

  void _onConfirmLog() async {
    if (_selectedFood == null) return;
    await ref
        .read(nutritionLogControllerProvider.notifier)
        .logFood(
          mealType: widget.mealType,
          food: _selectedFood!,
          servings: _servings,
        );
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final searchResultsAsync = ref.watch(foodSearchResultsProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            top: AppSpacing.md,
            bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                ),
              ),

              // Title and close
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add to ${widget.mealType.displayName}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),

              // Search field
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search food (e.g. Chicken, Oats, Rice)...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            ref
                                .read(foodSearchQueryProvider.notifier)
                                .setQuery('');
                          },
                        )
                      : null,
                ),
                onChanged: (val) {
                  ref.read(foodSearchQueryProvider.notifier).setQuery(val);
                },
              ),
              const SizedBox(height: AppSpacing.md),

              // Selected food serving adjustment panel
              if (_selectedFood != null) ...[
                _SelectedFoodConfigCard(
                  food: _selectedFood!,
                  servings: _servings,
                  onServingsChanged: (val) {
                    setState(() => _servings = val);
                  },
                  onClearSelection: () {
                    setState(() => _selectedFood = null);
                  },
                  onConfirmLog: _onConfirmLog,
                ),
                const SizedBox(height: AppSpacing.md),
                const Divider(height: 1),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Or choose another food:',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
              ],

              // Results list
              Expanded(
                child: searchResultsAsync.when(
                  loading: () => const Center(child: AppLoader()),
                  error: (err, _) => Center(
                    child: AppErrorWidget(
                      message: 'Failed to search foods: $err',
                      onRetry: () => ref.invalidate(foodSearchResultsProvider),
                    ),
                  ),
                  data: (foods) {
                    if (foods.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off_outlined,
                              size: 48,
                              color: theme.colorScheme.outline,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              'No food items match "${_searchController.text}"',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      controller: scrollController,
                      itemCount: foods.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final food = foods[index];
                        final isSelected = _selectedFood?.id == food.id;

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs,
                            vertical: 2,
                          ),
                          title: Text(
                            food.name,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : null,
                            ),
                          ),
                          subtitle: Text(
                            '${food.servingSize.toInt()} ${food.servingUnit} • ${food.calories} kcal • ${food.proteinG}g P • ${food.carbsG}g C • ${food.fatG}g F'
                            '${food.brand != null ? ' • ${food.brand}' : ''}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          trailing: isSelected
                              ? Icon(
                                  Icons.check_circle,
                                  color: theme.colorScheme.primary,
                                )
                              : const Icon(Icons.add_circle_outline),
                          onTap: () => _onFoodSelected(food),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SelectedFoodConfigCard extends StatelessWidget {
  const _SelectedFoodConfigCard({
    required this.food,
    required this.servings,
    required this.onServingsChanged,
    required this.onClearSelection,
    required this.onConfirmLog,
  });

  final FoodItem food;
  final double servings;
  final ValueChanged<double> onServingsChanged;
  final VoidCallback onClearSelection;
  final VoidCallback onConfirmLog;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalCals = (food.calories * servings).round();
    final totalProtein = ((food.proteinG * servings) * 10).round() / 10.0;
    final totalCarbs = ((food.carbsG * servings) * 10).round() / 10.0;
    final totalFat = ((food.fatG * servings) * 10).round() / 10.0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withAlpha(50),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: theme.colorScheme.primary.withAlpha(100)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  food.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: onClearSelection,
                tooltip: 'Deselect',
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Servings (${food.servingSize.toInt()} ${food.servingUnit}/serving):',
                style: theme.textTheme.bodyMedium,
              ),
              Row(
                children: [
                  IconButton.filledTonal(
                    icon: const Icon(Icons.remove, size: 16),
                    onPressed: servings > 0.5
                        ? () => onServingsChanged(
                            ((servings - 0.5) * 10).round() / 10.0,
                          )
                        : null,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                    ),
                    child: Text(
                      servings.toStringAsFixed(1),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton.filledTonal(
                    icon: const Icon(Icons.add, size: 16),
                    onPressed: servings < 10.0
                        ? () => onServingsChanged(
                            ((servings + 0.5) * 10).round() / 10.0,
                          )
                        : null,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '$totalCals kcal • ${totalProtein}g Protein • ${totalCarbs}g Carbs • ${totalFat}g Fat',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ElevatedButton.icon(
            onPressed: onConfirmLog,
            icon: const Icon(Icons.check, size: 18),
            label: Text('Log $totalCals kcal'),
          ),
        ],
      ),
    );
  }
}
