import 'package:calibrefit/features/exercise_library/domain/exercise.dart';
import 'package:calibrefit/features/exercise_library/domain/exercise_repository.dart';

/// In-memory mock implementation of [ExerciseRepository].
///
/// Contains initial seed exercises including the 8 MVP exercises for AI form analysis.
class MockExerciseRepository implements ExerciseRepository {
  const MockExerciseRepository();

  static const _simulatedDelay = Duration(milliseconds: 150);

  static const List<Exercise> _seedExercises = [
    Exercise(
      id: 'ex-bench-press',
      name: 'Barbell Bench Press',
      slug: 'barbell-bench-press',
      category: ExerciseCategory.chest,
      primaryMuscles: ['Pectoralis Major', 'Anterior Deltoid'],
      secondaryMuscles: ['Triceps Brachii', 'Core'],
      equipment: 'Barbell & Flat Bench',
      difficulty: ExerciseDifficulty.intermediate,
      instructions: [
        'Lie flat on the bench with your eyes directly under the bar.',
        'Grip the bar slightly wider than shoulder-width apart.',
        'Unrack the bar by straightening your arms and moving it over your chest.',
        'Lower the bar slowly to your mid-chest while tucking your elbows at ~45 degrees.',
        'Press the bar upward explosively until your arms are fully extended.',
      ],
      correctPosture: [
        'Keep five points of contact: head, shoulders, glutes on bench, and both feet flat on floor.',
        'Maintain a slight natural arch in the lower back.',
        'Retract and depress your shoulder blades into the bench.',
      ],
      breathing: 'Inhale deeply on the way down; hold briefly at chest; exhale forcefully as you press up.',
      tempo: '3-0-1-0 (3s descent, 0s pause, 1s press, 0s reset)',
      commonMistakes: [
        'Bouncing the barbell off your chest.',
        'Flaring elbows out at 90 degrees, stressing the rotator cuff.',
        'Lifting glutes or hips off the bench during the press.',
      ],
      videoUrl: 'https://calibrefit.app/videos/bench_press.mp4',
      animationUrl: 'https://calibrefit.app/animations/bench_press.json',
      aiSupported: true,
      defaultSets: 4,
      defaultRepRange: '6–8',
      defaultSuggestedLoadKg: 42.5,
      defaultRestSeconds: 120,
    ),
    Exercise(
      id: 'ex-incline-db-press',
      name: 'Incline Dumbbell Press',
      slug: 'incline-dumbbell-press',
      category: ExerciseCategory.chest,
      primaryMuscles: ['Upper Chest (Clavicular Head)', 'Anterior Deltoid'],
      secondaryMuscles: ['Triceps Brachii'],
      equipment: 'Incline Bench & Dumbbells',
      difficulty: ExerciseDifficulty.intermediate,
      instructions: [
        'Set an incline bench to 30–45 degrees and sit with dumbbells on your knees.',
        'Kick the dumbbells up to shoulder level as you lean back.',
        'Press the dumbbells up until arms are extended, keeping wrists neutral.',
        'Lower the weights smoothly until your elbows reach approximately 90 degrees.',
        'Press back up following a slight inward arc.',
      ],
      correctPosture: [
        'Keep shoulders packed and chest up throughout the movement.',
        'Feet planted firmly on the floor.',
        'Maintain wrists stacked over elbows.',
      ],
      breathing:
          'Inhale on the descent; exhale during the upward pressing motion.',
      tempo: '3-1-1-0 (3s descent, 1s bottom stretch, 1s press, 0s pause)',
      commonMistakes: [
        'Bench angle set too steep (above 45 degrees shifts work to front delts).',
        'Clanking the dumbbells together at the top.',
        'Letting elbows flare excessively outward.',
      ],
      videoUrl: 'https://calibrefit.app/videos/incline_db_press.mp4',
      animationUrl: 'https://calibrefit.app/animations/incline_db_press.json',
      aiSupported: false,
      defaultSets: 3,
      defaultRepRange: '8–10',
      defaultSuggestedLoadKg: 17.5,
      defaultRestSeconds: 90,
    ),
    Exercise(
      id: 'ex-cable-fly',
      name: 'Cable Fly',
      slug: 'cable-fly',
      category: ExerciseCategory.chest,
      primaryMuscles: ['Pectoralis Major (Sternal Head)'],
      secondaryMuscles: ['Anterior Deltoid', 'Biceps (short head)'],
      equipment: 'Cable Machine & D-Handles',
      difficulty: ExerciseDifficulty.beginner,
      instructions: [
        'Set the pulleys at chest height and grasp each handle.',
        'Take a step forward into a staggered stance to establish stability.',
        'With a slight bend in your elbows, bring handles together in front of your chest in a hugging motion.',
        'Pause and squeeze your chest muscles at peak contraction.',
        'Slowly reverse the motion until you feel a gentle stretch across your chest.',
      ],
      correctPosture: [
        'Maintain a slight forward lean at the torso.',
        'Keep the bend in your elbows constant throughout the set.',
        'Keep shoulders down and chest lifted.',
      ],
      breathing:
          'Inhale as you open your arms; exhale as you bring hands together.',
      tempo: '2-1-1-1 (2s open, 1s stretch, 1s squeeze, 1s peak contraction)',
      commonMistakes: [
        'Bending and extending elbows (turning the fly into a press).',
        'Using excessive body swing/momentum.',
        'Letting arms travel too far back behind the torso.',
      ],
      videoUrl: 'https://calibrefit.app/videos/cable_fly.mp4',
      animationUrl: 'https://calibrefit.app/animations/cable_fly.json',
      aiSupported: false,
      defaultSets: 3,
      defaultRepRange: '10–12',
      defaultSuggestedLoadKg: 15.0,
      defaultRestSeconds: 60,
    ),
    Exercise(
      id: 'ex-squat',
      name: 'Barbell Back Squat',
      slug: 'barbell-back-squat',
      category: ExerciseCategory.legs,
      primaryMuscles: ['Quadriceps', 'Gluteus Maximus'],
      secondaryMuscles: ['Hamstrings', 'Core', 'Erector Spinae'],
      equipment: 'Barbell & Squat Rack',
      difficulty: ExerciseDifficulty.intermediate,
      instructions: [
        'Step under the bar and rest it across your upper back (trapezius).',
        'Unrack the bar and take 2–3 steps back with feet shoulder-width apart.',
        'Hinge at hips and bend knees, pushing knees slightly out over toes.',
        'Lower until your hip crease is at or below the top of your knees.',
        'Drive through your whole foot to stand back up to full extension.',
      ],
      correctPosture: [
        'Chest proud with spine in neutral alignment.',
        'Knees track in line with your 2nd/3rd toes.',
        'Weight balanced across the midfoot.',
      ],
      breathing: 'Inhale deeply and brace your core at the top; descend; exhale as you complete the ascent.',
      tempo: '3-1-1-0 (3s descent, 1s in the hole, 1s ascent, 0s reset)',
      commonMistakes: [
        'Knees caving inward (valgus collapse).',
        'Rounding the lower back (butt wink) at depth.',
        'Rising up onto the balls of your feet.',
      ],
      videoUrl: 'https://calibrefit.app/videos/squat.mp4',
      animationUrl: 'https://calibrefit.app/animations/squat.json',
      aiSupported: true,
      defaultSets: 4,
      defaultRepRange: '6–8',
      defaultSuggestedLoadKg: 60.0,
      defaultRestSeconds: 150,
    ),
    Exercise(
      id: 'ex-pushup',
      name: 'Push-up',
      slug: 'push-up',
      category: ExerciseCategory.chest,
      primaryMuscles: ['Pectoralis Major', 'Anterior Deltoid'],
      secondaryMuscles: ['Triceps Brachii', 'Core (Rectus Abdominis)'],
      equipment: 'Bodyweight',
      difficulty: ExerciseDifficulty.beginner,
      instructions: [
        'Start in a high plank position with hands slightly wider than shoulder-width.',
        'Form a straight line from your head to your heels.',
        'Lower your body by bending elbows until chest is about 2 inches off the ground.',
        'Push firmly through palms to return to starting plank position.',
      ],
      correctPosture: [
        'Core braced tight to avoid sagging hips or arched back.',
        'Elbows tucked at roughly 45 degrees, not flared to the sides.',
        'Neck neutral looking slightly ahead of hands.',
      ],
      breathing: 'Inhale on the descent; exhale smoothly as you push up.',
      tempo: '2-0-1-0 (2s down, 0s pause, 1s up, 0s reset)',
      commonMistakes: [
        'Sagging hips or piking hips upward.',
        'Flaring elbows out perpendicular to torso.',
        'Partial range of motion (bobbing head instead of moving chest).',
      ],
      videoUrl: 'https://calibrefit.app/videos/pushup.mp4',
      animationUrl: 'https://calibrefit.app/animations/pushup.json',
      aiSupported: true,
      defaultSets: 3,
      defaultRepRange: '10–15',
      defaultSuggestedLoadKg: 0.0,
      defaultRestSeconds: 60,
    ),
    Exercise(
      id: 'ex-shoulder-press',
      name: 'Dumbbell Shoulder Press',
      slug: 'dumbbell-shoulder-press',
      category: ExerciseCategory.shoulders,
      primaryMuscles: ['Anterior Deltoid', 'Lateral Deltoid'],
      secondaryMuscles: ['Triceps Brachii', 'Upper Trapezius'],
      equipment: 'Dumbbells & Bench',
      difficulty: ExerciseDifficulty.intermediate,
      instructions: [
        'Sit with back supported, holding dumbbells at shoulder level with palms facing forward.',
        'Press weights upward until arms are straight overhead.',
        'Pause briefly at the top without banging the dumbbells.',
        'Lower dumbbells with control back to shoulder height.',
      ],
      correctPosture: [
        'Back flat against the backrest with core engaged.',
        'Do not overarch your lower back as the weights go overhead.',
        'Elbows slightly angled forward in the scapular plane.',
      ],
      breathing: 'Inhale as you lower weights; exhale as you press overhead.',
      tempo: '2-0-1-0 (2s down, 0s pause, 1s press, 0s top)',
      commonMistakes: [
        'Arching the lower back excessively to compensate for shoulder mobility.',
        'Pressing weights too far in front of or behind the head.',
        'Dropping weights too fast without controlling eccentric phase.',
      ],
      videoUrl: 'https://calibrefit.app/videos/shoulder_press.mp4',
      animationUrl: 'https://calibrefit.app/animations/shoulder_press.json',
      aiSupported: true,
      defaultSets: 3,
      defaultRepRange: '8–10',
      defaultSuggestedLoadKg: 14.0,
      defaultRestSeconds: 90,
    ),
    Exercise(
      id: 'ex-bicep-curl',
      name: 'Dumbbell Bicep Curl',
      slug: 'dumbbell-bicep-curl',
      category: ExerciseCategory.arms,
      primaryMuscles: ['Biceps Brachii'],
      secondaryMuscles: ['Brachialis', 'Brachioradialis'],
      equipment: 'Dumbbells',
      difficulty: ExerciseDifficulty.beginner,
      instructions: [
        'Stand tall with dumbbells at your sides, palms facing inward.',
        'Keeping elbows pinned to your sides, curl weights up while supinating (rotating palms up).',
        'Squeeze biceps hard at the peak of the movement.',
        'Slowly lower the dumbbells back to starting position.',
      ],
      correctPosture: [
        'Elbows stationary at sides throughout the entire rep.',
        'Torso upright without leaning back or swinging.',
        'Wrists kept straight and firm.',
      ],
      breathing: 'Exhale as you curl up; inhale as you lower the weights.',
      tempo: '2-1-1-0 (2s descent, 1s bottom stretch, 1s curl, 0s pause)',
      commonMistakes: [
        'Swinging the torso to gain momentum.',
        'Drifting elbows forward during the curl.',
        'Dropping the weights quickly instead of controlling the descent.',
      ],
      videoUrl: 'https://calibrefit.app/videos/bicep_curl.mp4',
      animationUrl: 'https://calibrefit.app/animations/bicep_curl.json',
      aiSupported: true,
      defaultSets: 3,
      defaultRepRange: '10–12',
      defaultSuggestedLoadKg: 10.0,
      defaultRestSeconds: 60,
    ),
    Exercise(
      id: 'ex-deadlift',
      name: 'Barbell Deadlift',
      slug: 'barbell-deadlift',
      category: ExerciseCategory.back,
      primaryMuscles: ['Erector Spinae', 'Gluteus Maximus', 'Hamstrings'],
      secondaryMuscles: ['Latissimus Dorsi', 'Trapezius', 'Forearms', 'Core'],
      equipment: 'Barbell & Plates',
      difficulty: ExerciseDifficulty.advanced,
      instructions: [
        'Stand with feet hip-width apart, barbell over the middle of your feet.',
        'Hinge at your hips and grip the bar just outside your legs.',
        'Drop your hips slightly, pull chest forward, and engage your lats.',
        'Drive through the floor with your legs, keeping the bar close to your shins and thighs.',
        'Lock out hips and knees at the top with glutes contracted.',
        'Hinge at hips to lower the bar back to the floor with control.',
      ],
      correctPosture: [
        'Neutral spine throughout the entire lift; never round your lower back.',
        'Lats locked tight ("protect your armpits").',
        'Barbell travels in a vertical line over midfoot.',
      ],
      breathing:
          'Inhale deeply and brace core before lifting; exhale at top lockout.',
      tempo: '2-0-1-1 (2s descent, 0s touch, 1s pull, 1s lockout)',
      commonMistakes: [
        'Rounding the lumbar spine under load.',
        'Hyperextending the spine at the top of the lift.',
        'Allowing the barbell to drift away from the body.',
      ],
      videoUrl: 'https://calibrefit.app/videos/deadlift.mp4',
      animationUrl: 'https://calibrefit.app/animations/deadlift.json',
      aiSupported: true,
      defaultSets: 3,
      defaultRepRange: '5',
      defaultSuggestedLoadKg: 80.0,
      defaultRestSeconds: 180,
    ),
    Exercise(
      id: 'ex-lunges',
      name: 'Walking Dumbbell Lunges',
      slug: 'walking-dumbbell-lunges',
      category: ExerciseCategory.legs,
      primaryMuscles: ['Quadriceps', 'Gluteus Maximus'],
      secondaryMuscles: ['Hamstrings', 'Calves', 'Core'],
      equipment: 'Dumbbells',
      difficulty: ExerciseDifficulty.intermediate,
      instructions: [
        'Stand upright holding a dumbbell in each hand by your sides.',
        'Step forward with your right leg, lowering your hips until both knees are bent at ~90 degrees.',
        'Your rear knee should hover just above the floor.',
        'Drive through the front heel to step forward into the next lunge with the left leg.',
      ],
      correctPosture: [
        'Keep torso upright with shoulders pulled back.',
        'Front knee tracks directly over front ankle, not past toes.',
        'Hips stay level and square.',
      ],
      breathing:
          'Inhale as you step forward and lower; exhale as you drive up.',
      tempo: '2-0-1-0 (2s lower, 0s pause, 1s step through, 0s reset)',
      commonMistakes: [
        'Leaning torso too far forward.',
        'Front knee caving inward during descent.',
        'Taking too short of a stride, causing excessive knee stress.',
      ],
      videoUrl: 'https://calibrefit.app/videos/lunges.mp4',
      animationUrl: 'https://calibrefit.app/animations/lunges.json',
      aiSupported: true,
      defaultSets: 3,
      defaultRepRange: '10–12 per leg',
      defaultSuggestedLoadKg: 12.0,
      defaultRestSeconds: 90,
    ),
    Exercise(
      id: 'ex-lat-pulldown',
      name: 'Lat Pulldown',
      slug: 'lat-pulldown',
      category: ExerciseCategory.back,
      primaryMuscles: ['Latissimus Dorsi'],
      secondaryMuscles: ['Biceps Brachii', 'Rhomboids', 'Rear Deltoids'],
      equipment: 'Cable Machine & Wide Bar',
      difficulty: ExerciseDifficulty.beginner,
      instructions: [
        'Sit at the lat pulldown station and adjust the thigh pad to lock your legs securely.',
        'Grasp the bar with a wide overhand grip.',
        'With torso tilted slightly back (~10–15 degrees), pull the bar down toward your upper chest.',
        'Squeeze your shoulder blades together at the bottom.',
        'Slowly let the bar return to full arm extension with lats stretching.',
      ],
      correctPosture: [
        'Chest lifted toward the bar as you pull.',
        'Shoulders stay pulled down away from ears.',
        'Avoid excessive backward swinging.',
      ],
      breathing:
          'Exhale as you pull the bar down; inhale as you extend your arms.',
      tempo: '3-0-1-1 (3s release, 0s top stretch, 1s pull, 1s squeeze)',
      commonMistakes: [
        'Pulling the bar behind the neck (stresses cervical spine).',
        'Leaning back too far and turning the exercise into a row.',
        'Using momentum and swinging the torso.',
      ],
      videoUrl: 'https://calibrefit.app/videos/lat_pulldown.mp4',
      animationUrl: 'https://calibrefit.app/animations/lat_pulldown.json',
      aiSupported: true,
      defaultSets: 3,
      defaultRepRange: '10–12',
      defaultSuggestedLoadKg: 35.0,
      defaultRestSeconds: 90,
    ),
  ];

  @override
  Future<List<Exercise>> getExercises({
    String? query,
    ExerciseCategory? category,
  }) async {
    await Future<void>.delayed(_simulatedDelay);

    var results = List<Exercise>.from(_seedExercises);

    if (category != null) {
      results = results.where((e) => e.category == category).toList();
    }

    if (query != null && query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      results = results.where((e) {
        final matchesName = e.name.toLowerCase().contains(q);
        final matchesEquipment = e.equipment.toLowerCase().contains(q);
        final matchesMuscles =
            e.primaryMuscles.any((m) => m.toLowerCase().contains(q)) ||
            e.secondaryMuscles.any((m) => m.toLowerCase().contains(q));
        return matchesName || matchesEquipment || matchesMuscles;
      }).toList();
    }

    return results;
  }

  @override
  Future<Exercise?> getExerciseById(String id) async {
    await Future<void>.delayed(_simulatedDelay);
    try {
      return _seedExercises.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }
}
