import 'package:calibrefit/features/notifications/data/mock_notification_repository.dart';
import 'package:calibrefit/features/notifications/domain/notification_models.dart';
import 'package:calibrefit/features/notifications/presentation/notification_providers.dart';
import 'package:calibrefit/features/nutrition/data/mock_nutrition_repository.dart';
import 'package:calibrefit/features/nutrition/domain/food_item.dart';
import 'package:calibrefit/features/nutrition/domain/macro_calculator.dart';
import 'package:calibrefit/features/nutrition/presentation/nutrition_providers.dart';
import 'package:calibrefit/features/sync/data/mock_sync_repository.dart';
import 'package:calibrefit/features/sync/domain/sync_models.dart';
import 'package:calibrefit/features/sync/presentation/sync_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('E2E: Nutrition, Notifications, and Cloud Sync Flow', () {
    late ProviderContainer container;
    late MockNutritionRepository nutritionRepo;
    late MockNotificationRepository notificationRepo;
    late MockSyncRepository syncRepo;

    setUp(() async {
      nutritionRepo = MockNutritionRepository(
        target: const MacroTarget(
          calories: 2400,
          proteinG: 180,
          carbsG: 260,
          fatG: 65,
          waterMl: 3000,
          bmr: 1750,
          tdee: 2400,
        ),
      );
      notificationRepo = MockNotificationRepository();
      syncRepo = MockSyncRepository();

      container = ProviderContainer(
        overrides: [
          nutritionRepositoryProvider.overrideWithValue(nutritionRepo),
          notificationRepositoryProvider.overrideWithValue(notificationRepo),
          syncRepositoryProvider.overrideWithValue(syncRepo),
        ],
      );

      await container.read(syncEngineProvider.notifier).init();
    });

    tearDown(() {
      container.dispose();
    });

    test('User can log nutrition, configure reminders & test alerts, and sync offline mutations', () async {
      // ── Step 1: Diet & Nutrition Planning ─────────────────────────────────
      final today = DateTime.now();
      final foods = await nutritionRepo.searchFoodDatabase('salmon');
      expect(foods, isNotEmpty);
      final salmon = foods.first;

      final nutritionController = container.read(
        nutritionLogControllerProvider.notifier,
      );
      await nutritionController.logFood(
        mealType: MealType.lunch,
        food: salmon,
        servings: 1.5,
      );
      await nutritionController.logWater(500);

      final dailyLog = await container.read(dailyNutritionLogProvider.future);
      expect(
        dailyLog
            .entriesForMeal(MealType.lunch)
            .any((e) => e.foodItem.id == salmon.id),
        isTrue,
      );
      expect(
        dailyLog.waterIntakeMl,
        greaterThanOrEqualTo(2250),
      ); // 1750 seed + 500
      expect(dailyLog.consumedCalories, greaterThan(0));

      // ── Step 2: Notifications & Reminders ─────────────────────────────────
      final notifController = container.read(
        notificationControllerProvider.notifier,
      );

      final currentPrefs = await notificationRepo.getPreferences();
      await notifController.updatePreferences(
        currentPrefs.copyWith(
          workoutReminderHour: 7,
          workoutReminderMinute: 30,
          workoutReminderDays: [1, 2, 3, 4, 5],
          hydrationIntervalHours: 2,
        ),
      );

      final updatedPrefs = await notificationRepo.getPreferences();
      expect(updatedPrefs.workoutReminderHour, equals(7));
      expect(updatedPrefs.workoutReminderMinute, equals(30));

      // Dispatch a test alert
      await container.read(deliveredNotificationsProvider.future);
      final initialUnread = container.read(unreadNotificationsCountProvider);
      final testAlert = await notifController.sendTestNotification(
        NotificationType.workoutReminder,
      );
      expect(testAlert.title, contains('Workout'));

      final deliveredList = await container.read(
        deliveredNotificationsProvider.future,
      );
      expect(deliveredList.first.id, equals(testAlert.id));
      expect(
        container.read(unreadNotificationsCountProvider),
        equals(initialUnread + 1),
      );

      // Mark as read
      await notifController.markAsRead(testAlert.id);
      await container.read(deliveredNotificationsProvider.future);
      expect(
        container.read(unreadNotificationsCountProvider),
        equals(initialUnread),
      );

      // ── Step 3: Cloud Sync & Offline Persistence ──────────────────────────
      final syncEngine = container.read(syncEngineProvider.notifier);

      // Transition to offline mode
      await syncEngine.setOnline(false);
      var syncState = container.read(syncEngineProvider);
      expect(syncState.isOnline, isFalse);
      expect(syncState.status, equals(SyncStatus.offline));

      // Enqueue an offline mutation
      await syncEngine.enqueueMutation(
        entityType: EntityType.nutrition,
        action: MutationAction.create,
        entityId: 'offline-lunch-entry-42',
        payload: {
          'foodName': 'Grilled Salmon',
          'calories': (salmon.calories * 1.5).round(),
          'loggedAt': today.toIso8601String(),
        },
      );

      final pending = await syncRepo.getPendingMutations();
      expect(
        pending.any((m) => m.entityId == 'offline-lunch-entry-42'),
        isTrue,
      );

      // Transition to online mode -> triggers automatic sync
      await syncEngine.setOnline(true);

      syncState = container.read(syncEngineProvider);
      expect(syncState.isOnline, isTrue);
      expect(syncState.status, equals(SyncStatus.idle));
      expect(syncState.pendingCount, equals(0));

      final remainingQueue = await syncRepo.getPendingMutations();
      expect(remainingQueue, isEmpty);
    });
  });
}
