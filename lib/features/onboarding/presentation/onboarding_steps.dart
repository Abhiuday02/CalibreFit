import 'package:calibrefit/app/app_constants.dart';
import 'package:calibrefit/features/onboarding/domain/onboarding_profile.dart';
import 'package:calibrefit/features/onboarding/presentation/onboarding_providers.dart';
import 'package:calibrefit/features/onboarding/presentation/widgets/onboarding_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ===========================================================================
// Step 1 — Basic Information
// ===========================================================================

class StepBasicInfo extends ConsumerStatefulWidget {
  const StepBasicInfo({super.key});

  @override
  ConsumerState<StepBasicInfo> createState() => _StepBasicInfoState();
}

class _StepBasicInfoState extends ConsumerState<StepBasicInfo> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _ageCtrl;
  late final TextEditingController _heightCtrl;
  late final TextEditingController _weightCtrl;
  BiologicalSex? _sex;

  @override
  void initState() {
    super.initState();
    final p = ref.read(onboardingNotifierProvider).profile;
    _nameCtrl = TextEditingController(text: p.displayName ?? '');
    _ageCtrl = TextEditingController(text: p.age?.toString() ?? '');
    _heightCtrl = TextEditingController(text: p.heightCm?.toString() ?? '');
    _weightCtrl = TextEditingController(text: p.weightKg?.toString() ?? '');
    _sex = p.biologicalSex;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_sex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your biological sex.')),
      );
      return;
    }
    ref
        .read(onboardingNotifierProvider.notifier)
        .setBasicInfo(
          displayName: _nameCtrl.text.trim(),
          age: int.parse(_ageCtrl.text.trim()),
          heightCm: double.parse(_heightCtrl.text.trim()),
          weightKg: double.parse(_weightCtrl.text.trim()),
          biologicalSex: _sex!,
        );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const OnboardingStepHeader(
              emoji: '👤',
              title: 'Tell us about yourself',
              subtitle:
                  'This helps us personalise your workouts and nutrition plan.',
            ),
            const SizedBox(height: AppSpacing.xl),

            // Name
            TextFormField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Your name',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Name is required.' : null,
            ),
            const SizedBox(height: AppSpacing.md),

            // Age
            TextFormField(
              controller: _ageCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Age (years)',
                prefixIcon: Icon(Icons.cake_outlined),
              ),
              validator: (v) {
                final n = int.tryParse(v ?? '');
                if (n == null) return 'Enter a valid age.';
                if (n < 13 || n > 100) return 'Age must be between 13–100.';
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),

            // Height + Weight in a row
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _heightCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Height (cm)',
                      prefixIcon: Icon(Icons.height_rounded),
                    ),
                    validator: (v) {
                      final n = double.tryParse(v ?? '');
                      if (n == null) return 'Required.';
                      if (n < 100 || n > 250) return '100–250 cm.';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: TextFormField(
                    controller: _weightCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Weight (kg)',
                      prefixIcon: Icon(Icons.monitor_weight_outlined),
                    ),
                    validator: (v) {
                      final n = double.tryParse(v ?? '');
                      if (n == null) return 'Required.';
                      if (n < 30 || n > 300) return '30–300 kg.';
                      return null;
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),

            // Biological sex
            Text(
              'Biological sex',
              style: Theme.of(context).textTheme.labelLarge
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.sm),
            ...BiologicalSex.values.map(
              (s) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: OnboardingChip(
                  label: _sexLabel(s),
                  isSelected: _sex == s,
                  onTap: () => setState(() => _sex = s),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),
            _ContinueButton(onPressed: _submit),
          ],
        ),
      ),
    );
  }

  String _sexLabel(BiologicalSex s) => switch (s) {
    BiologicalSex.male => 'Male',
    BiologicalSex.female => 'Female',
    BiologicalSex.preferNotToSay => 'Prefer not to say',
  };
}

// ===========================================================================
// Step 2 — Fitness Level
// ===========================================================================

class StepFitnessLevel extends ConsumerWidget {
  const StepFitnessLevel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(onboardingNotifierProvider).profile.fitnessLevel;
    final notifier = ref.read(onboardingNotifierProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const OnboardingStepHeader(
            emoji: '🏋️',
            title: 'Your fitness experience',
            subtitle: 'We use this to calibrate starting weights and workout complexity.',
          ),
          const SizedBox(height: AppSpacing.xl),
          ...FitnessLevel.values.map((level) {
            final (label, desc, icon) = _levelMeta(level);
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: OnboardingChip(
                label: label,
                description: desc,
                icon: icon,
                isSelected: current == level,
                onTap: () => notifier.setFitnessLevel(level),
              ),
            );
          }),
        ],
      ),
    );
  }

  (String, String, IconData) _levelMeta(FitnessLevel l) => switch (l) {
    FitnessLevel.beginner => (
      'Beginner',
      'New to structured training (< 1 year)',
      Icons.emoji_people_rounded,
    ),
    FitnessLevel.intermediate => (
      'Intermediate',
      'Training consistently for 1–3 years',
      Icons.directions_run_rounded,
    ),
    FitnessLevel.advanced => (
      'Advanced',
      'Experienced lifter (3+ years)',
      Icons.fitness_center_rounded,
    ),
    FitnessLevel.athlete => (
      'Athlete',
      'Competitive sport or elite performance',
      Icons.emoji_events_rounded,
    ),
  };
}

// ===========================================================================
// Step 3 — Fitness Goal
// ===========================================================================

class StepFitnessGoal extends ConsumerWidget {
  const StepFitnessGoal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(onboardingNotifierProvider).profile.fitnessGoal;
    final notifier = ref.read(onboardingNotifierProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const OnboardingStepHeader(
            emoji: '🎯',
            title: 'What is your main goal?',
            subtitle:
                'Your goal shapes your programme, volume, and recommendations.',
          ),
          const SizedBox(height: AppSpacing.xl),
          ...FitnessGoal.values.map((goal) {
            final (label, icon) = _goalMeta(goal);
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: OnboardingChip(
                label: label,
                icon: icon,
                isSelected: current == goal,
                onTap: () => notifier.setFitnessGoal(goal),
              ),
            );
          }),
        ],
      ),
    );
  }

  (String, IconData) _goalMeta(FitnessGoal g) => switch (g) {
    FitnessGoal.loseWeight => ('Lose weight', Icons.trending_down_rounded),
    FitnessGoal.buildMuscle => ('Build muscle', Icons.fitness_center_rounded),
    FitnessGoal.improveEndurance => (
      'Improve endurance',
      Icons.directions_run_rounded,
    ),
    FitnessGoal.maintainFitness => ('Maintain fitness', Icons.repeat_rounded),
    FitnessGoal.improveFlexibility => (
      'Improve flexibility',
      Icons.self_improvement_rounded,
    ),
    FitnessGoal.generalHealth => ('General health', Icons.favorite_rounded),
  };
}

// ===========================================================================
// Step 4 — Equipment
// ===========================================================================

class StepEquipment extends ConsumerWidget {
  const StepEquipment({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref
        .watch(onboardingNotifierProvider)
        .profile
        .availableEquipment;
    final notifier = ref.read(onboardingNotifierProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const OnboardingStepHeader(
            emoji: '🏗️',
            title: 'Available equipment',
            subtitle:
                'Select everything you have access to. Pick all that apply.',
          ),
          const SizedBox(height: AppSpacing.xl),
          ...Equipment.values.map((e) {
            final (label, icon) = _equipMeta(e);
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: OnboardingChip(
                label: label,
                icon: icon,
                isSelected: selected.contains(e),
                onTap: () => notifier.toggleEquipment(e),
              ),
            );
          }),
          const SizedBox(height: AppSpacing.xl),
          _ContinueButton(
            onPressed: selected.isEmpty
                ? null
                : () => notifier.confirmEquipment(),
          ),
        ],
      ),
    );
  }

  (String, IconData) _equipMeta(Equipment e) => switch (e) {
    Equipment.fullGym => ('Full gym', Icons.apartment_rounded),
    Equipment.homeGym => ('Home gym', Icons.home_rounded),
    Equipment.dumbbellsOnly => ('Dumbbells only', Icons.fitness_center_rounded),
    Equipment.barbellAndRack => ('Barbell & rack', Icons.sports_rounded),
    Equipment.resistanceBands => ('Resistance bands', Icons.cable_rounded),
    Equipment.bodyweightOnly => (
      'Bodyweight only',
      Icons.accessibility_new_rounded,
    ),
    Equipment.cables => ('Cable machines', Icons.linear_scale_rounded),
    Equipment.machines => ('Weight machines', Icons.settings_rounded),
  };
}

// ===========================================================================
// Step 5 — Training Days
// ===========================================================================

class StepTrainingDays extends ConsumerStatefulWidget {
  const StepTrainingDays({super.key});

  @override
  ConsumerState<StepTrainingDays> createState() => _StepTrainingDaysState();
}

class _StepTrainingDaysState extends ConsumerState<StepTrainingDays> {
  late int _days;

  @override
  void initState() {
    super.initState();
    _days =
        ref.read(onboardingNotifierProvider).profile.trainingDaysPerWeek ?? 3;
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(onboardingNotifierProvider.notifier);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const OnboardingStepHeader(
            emoji: '📅',
            title: 'Training days per week',
            subtitle: 'How many days can you commit to training each week?',
          ),
          const SizedBox(height: AppSpacing.xl),
          OnboardingNumberStepper(
            value: _days,
            label: 'Days per week',
            min: 1,
            max: 7,
            onDecrement: () => setState(() => _days--),
            onIncrement: () => setState(() => _days++),
          ),
          const SizedBox(height: AppSpacing.md),
          _DaysGrid(selected: _days, onTap: (d) => setState(() => _days = d)),
          const SizedBox(height: AppSpacing.xl),
          _ContinueButton(onPressed: () => notifier.setTrainingDays(_days)),
        ],
      ),
    );
  }
}

class _DaysGrid extends StatelessWidget {
  const _DaysGrid({required this.selected, required this.onTap});
  final int selected;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final day = i + 1;
        final isSelected = day == selected;
        return GestureDetector(
          onTap: () => onTap(day),
          child: AnimatedContainer(
            duration: AppAnimation.fast,
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.surfaceContainerLow,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.outlineVariant,
              ),
            ),
            child: Center(
              child: Text(
                '$day',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? colorScheme.onPrimary
                      : colorScheme.onSurface,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ===========================================================================
// Step 6 — Session Duration
// ===========================================================================

class StepSessionDuration extends ConsumerWidget {
  const StepSessionDuration({super.key});

  static const _options = [30, 45, 60, 75, 90];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref
        .watch(onboardingNotifierProvider)
        .profile
        .preferredSessionMinutes;
    final notifier = ref.read(onboardingNotifierProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const OnboardingStepHeader(
            emoji: '⏱️',
            title: 'Preferred session length',
            subtitle: 'How long do you typically want your workouts to be?',
          ),
          const SizedBox(height: AppSpacing.xl),
          ..._options.map(
            (min) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: OnboardingChip(
                label: '$min minutes',
                icon: Icons.timer_outlined,
                isSelected: current == min,
                onTap: () => notifier.setSessionDuration(min),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// Step 7 — Cardio Preference
// ===========================================================================

class StepCardio extends ConsumerWidget {
  const StepCardio({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref
        .watch(onboardingNotifierProvider)
        .profile
        .cardioPreference;
    final notifier = ref.read(onboardingNotifierProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const OnboardingStepHeader(
            emoji: '🏃',
            title: 'Cardio preference',
            subtitle: 'How much cardio do you want included in your programme?',
          ),
          const SizedBox(height: AppSpacing.xl),
          ...CardioPreference.values.map((pref) {
            final (label, desc, icon) = _cardioMeta(pref);
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: OnboardingChip(
                label: label,
                description: desc,
                icon: icon,
                isSelected: current == pref,
                onTap: () => notifier.setCardioPreference(pref),
              ),
            );
          }),
        ],
      ),
    );
  }

  (String, String, IconData) _cardioMeta(CardioPreference p) => switch (p) {
    CardioPreference.none => (
      'No cardio',
      'Strength training only',
      Icons.fitness_center_rounded,
    ),
    CardioPreference.light => (
      'Light cardio',
      '1–2 sessions per week',
      Icons.directions_walk_rounded,
    ),
    CardioPreference.moderate => (
      'Moderate cardio',
      '2–3 sessions per week',
      Icons.directions_run_rounded,
    ),
    CardioPreference.heavy => (
      'Heavy cardio',
      '4+ sessions per week',
      Icons.speed_rounded,
    ),
  };
}

// ===========================================================================
// Step 8 — Limitations / Injuries
// ===========================================================================

class StepLimitations extends ConsumerStatefulWidget {
  const StepLimitations({super.key});

  @override
  ConsumerState<StepLimitations> createState() => _StepLimitationsState();
}

class _StepLimitationsState extends ConsumerState<StepLimitations> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
      text: ref.read(onboardingNotifierProvider).profile.limitationsNotes ?? '',
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(onboardingNotifierProvider.notifier);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const OnboardingStepHeader(
            emoji: '🩹',
            title: 'Injuries or limitations',
            subtitle:
                'Any injuries, pain, or physical limitations we should know about? '
                'This is optional — skip it if none apply.',
          ),
          const SizedBox(height: AppSpacing.xl),
          TextFormField(
            controller: _ctrl,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Describe any limitations (optional)',
              hintText: 'e.g. lower back pain, bad knees, shoulder injury...',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _ContinueButton(
            onPressed: () {
              final notes = _ctrl.text.trim();
              notifier.setLimitations(notes.isEmpty ? null : notes);
            },
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// Step 9 — Dietary Preference
// ===========================================================================

class StepDietaryPreference extends ConsumerWidget {
  const StepDietaryPreference({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref
        .watch(onboardingNotifierProvider)
        .profile
        .dietaryPreference;
    final notifier = ref.read(onboardingNotifierProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const OnboardingStepHeader(
            emoji: '🥗',
            title: 'Dietary preference',
            subtitle:
                'Your diet type helps us suggest appropriate meal templates.',
          ),
          const SizedBox(height: AppSpacing.xl),
          ...DietaryPreference.values.map((pref) {
            final (label, icon) = _dietMeta(pref);
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: OnboardingChip(
                label: label,
                icon: icon,
                isSelected: current == pref,
                onTap: () => notifier.setDietaryPreference(pref),
              ),
            );
          }),
        ],
      ),
    );
  }

  (String, IconData) _dietMeta(DietaryPreference p) => switch (p) {
    DietaryPreference.nonVegetarian => (
      'Non-vegetarian',
      Icons.set_meal_rounded,
    ),
    DietaryPreference.vegetarian => ('Vegetarian', Icons.eco_rounded),
    DietaryPreference.vegan => ('Vegan', Icons.grass_rounded),
    DietaryPreference.eggetarian => ('Eggetarian', Icons.egg_rounded),
    DietaryPreference.pescatarian => ('Pescatarian', Icons.set_meal_rounded),
    DietaryPreference.noPreference => (
      'No preference',
      Icons.restaurant_rounded,
    ),
  };
}

// ===========================================================================
// Step 10 — Nutrition Tracking
// ===========================================================================

class StepNutritionTracking extends ConsumerWidget {
  const StepNutritionTracking({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref
        .watch(onboardingNotifierProvider)
        .profile
        .nutritionTrackingPreference;
    final notifier = ref.read(onboardingNotifierProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const OnboardingStepHeader(
            emoji: '📊',
            title: 'Nutrition tracking',
            subtitle: 'How much detail would you like in your nutrition recommendations?',
          ),
          const SizedBox(height: AppSpacing.xl),
          ...NutritionTrackingPreference.values.map((pref) {
            final (label, desc) = _trackMeta(pref);
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: OnboardingChip(
                label: label,
                description: desc,
                icon: Icons.bar_chart_rounded,
                isSelected: current == pref,
                onTap: () => notifier.setNutritionTracking(pref),
              ),
            );
          }),
        ],
      ),
    );
  }

  (String, String) _trackMeta(NutritionTrackingPreference p) => switch (p) {
    NutritionTrackingPreference.trackCaloriesAndMacros => (
      'Calories & macros',
      'Detailed protein, carbs, and fat targets',
    ),
    NutritionTrackingPreference.trackCaloriesOnly => (
      'Calories only',
      'Daily calorie target without macro breakdown',
    ),
    NutritionTrackingPreference.noTracking => (
      'No tracking',
      'Meal suggestions without specific numbers',
    ),
  };
}

// ===========================================================================
// Step 11 — Review & Confirm
// ===========================================================================

class StepReview extends ConsumerWidget {
  const StepReview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingNotifierProvider);
    final notifier = ref.read(onboardingNotifierProvider.notifier);
    final p = state.profile;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const OnboardingStepHeader(
            emoji: '✅',
            title: 'Looking good!',
            subtitle:
                "Here's a summary of your profile. Tap any section to edit, "
                'or confirm to generate your starter plan.',
          ),
          const SizedBox(height: AppSpacing.xl),

          // Summary card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  _ReviewRow('Name', p.displayName ?? '—'),
                  _ReviewRow('Age', p.age != null ? '${p.age} yrs' : '—'),
                  _ReviewRow(
                    'Height',
                    p.heightCm != null
                        ? '${p.heightCm!.toStringAsFixed(1)} cm'
                        : '—',
                  ),
                  _ReviewRow(
                    'Weight',
                    p.weightKg != null
                        ? '${p.weightKg!.toStringAsFixed(1)} kg'
                        : '—',
                  ),
                  _ReviewRow('Sex', _sexLabel(p.biologicalSex)),
                  _ReviewRow('Experience', _levelLabel(p.fitnessLevel)),
                  _ReviewRow('Goal', _goalLabel(p.fitnessGoal)),
                  _ReviewRow(
                    'Equipment',
                    p.availableEquipment.isEmpty
                        ? '—'
                        : p.availableEquipment.length == 1
                        ? _equipLabel(p.availableEquipment.first)
                        : '${p.availableEquipment.length} selected',
                  ),
                  _ReviewRow(
                    'Training days',
                    p.trainingDaysPerWeek != null
                        ? '${p.trainingDaysPerWeek}×/week'
                        : '—',
                  ),
                  _ReviewRow(
                    'Session length',
                    p.preferredSessionMinutes != null
                        ? '${p.preferredSessionMinutes} min'
                        : '—',
                  ),
                  _ReviewRow('Cardio', _cardioLabel(p.cardioPreference)),
                  _ReviewRow('Diet', _dietLabel(p.dietaryPreference)),
                  _ReviewRow(
                    'Nutrition tracking',
                    _trackingLabel(p.nutritionTrackingPreference),
                  ),
                  if (p.limitationsNotes != null)
                    _ReviewRow('Limitations', p.limitationsNotes!),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // Disclaimer
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Text(
              '⚠️  Suggestions are training guidance only. '
              'Consult a qualified professional before starting any fitness programme.',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          _ContinueButton(
            label: state.isSaving ? 'Saving…' : 'Start my journey 🚀',
            isLoading: state.isSaving,
            onPressed: state.isSaving
                ? null
                : () async {
                    final error = await notifier.completeOnboarding();
                    if (error != null && context.mounted) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(error)));
                    }
                  },
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  String _sexLabel(BiologicalSex? s) => switch (s) {
    BiologicalSex.male => 'Male',
    BiologicalSex.female => 'Female',
    BiologicalSex.preferNotToSay => 'Not specified',
    null => '—',
  };

  String _levelLabel(FitnessLevel? l) => switch (l) {
    FitnessLevel.beginner => 'Beginner',
    FitnessLevel.intermediate => 'Intermediate',
    FitnessLevel.advanced => 'Advanced',
    FitnessLevel.athlete => 'Athlete',
    null => '—',
  };

  String _goalLabel(FitnessGoal? g) => switch (g) {
    FitnessGoal.loseWeight => 'Lose weight',
    FitnessGoal.buildMuscle => 'Build muscle',
    FitnessGoal.improveEndurance => 'Improve endurance',
    FitnessGoal.maintainFitness => 'Maintain fitness',
    FitnessGoal.improveFlexibility => 'Improve flexibility',
    FitnessGoal.generalHealth => 'General health',
    null => '—',
  };

  String _equipLabel(Equipment e) => switch (e) {
    Equipment.fullGym => 'Full gym',
    Equipment.homeGym => 'Home gym',
    Equipment.dumbbellsOnly => 'Dumbbells',
    Equipment.barbellAndRack => 'Barbell & rack',
    Equipment.resistanceBands => 'Resistance bands',
    Equipment.bodyweightOnly => 'Bodyweight',
    Equipment.cables => 'Cables',
    Equipment.machines => 'Machines',
  };

  String _cardioLabel(CardioPreference? c) => switch (c) {
    CardioPreference.none => 'None',
    CardioPreference.light => 'Light',
    CardioPreference.moderate => 'Moderate',
    CardioPreference.heavy => 'Heavy',
    null => '—',
  };

  String _dietLabel(DietaryPreference? d) => switch (d) {
    DietaryPreference.nonVegetarian => 'Non-vegetarian',
    DietaryPreference.vegetarian => 'Vegetarian',
    DietaryPreference.vegan => 'Vegan',
    DietaryPreference.eggetarian => 'Eggetarian',
    DietaryPreference.pescatarian => 'Pescatarian',
    DietaryPreference.noPreference => 'No preference',
    null => '—',
  };

  String _trackingLabel(NutritionTrackingPreference? t) => switch (t) {
    NutritionTrackingPreference.trackCaloriesAndMacros => 'Calories & macros',
    NutritionTrackingPreference.trackCaloriesOnly => 'Calories only',
    NutritionTrackingPreference.noTracking => 'No tracking',
    null => '—',
  };
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// Shared internal button
// ===========================================================================

class _ContinueButton extends StatelessWidget {
  const _ContinueButton({
    this.onPressed,
    this.label = 'Continue',
    this.isLoading = false,
  });

  final VoidCallback? onPressed;
  final String label;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: colorScheme.onPrimary,
                ),
              )
            : Text(label),
      ),
    );
  }
}
