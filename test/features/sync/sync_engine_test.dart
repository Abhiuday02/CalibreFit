import 'package:calibrefit/features/sync/data/mock_sync_repository.dart';
import 'package:calibrefit/features/sync/domain/sync_models.dart';
import 'package:calibrefit/features/sync/presentation/sync_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SyncEngineNotifier', () {
    late ProviderContainer container;
    late MockSyncRepository repository;

    setUp(() async {
      repository = MockSyncRepository();
      container = ProviderContainer(
        overrides: [syncRepositoryProvider.overrideWithValue(repository)],
      );
      await container.read(syncEngineProvider.notifier).init();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state initializes with pending seed mutations', () async {
      final state = container.read(syncEngineProvider);
      expect(state.status, equals(SyncStatus.idle));
      expect(state.isOnline, isTrue);
      expect(state.pendingCount, greaterThanOrEqualTo(1));
      expect(state.lastSyncTime, isNotNull);
    });

    test(
      'setOnline(false) transitions to offline status and prevents sync',
      () async {
        final notifier = container.read(syncEngineProvider.notifier);

        await notifier.setOnline(false);

        var state = container.read(syncEngineProvider);
        expect(state.isOnline, isFalse);
        expect(state.status, equals(SyncStatus.offline));

        // Attempting to sync while offline should keep status offline
        await notifier.syncNow();
        state = container.read(syncEngineProvider);
        expect(state.status, equals(SyncStatus.offline));
      },
    );

    test(
      'enqueueing while offline increments pending count and retains items',
      () async {
        final notifier = container.read(syncEngineProvider.notifier);
        await notifier.setOnline(false);

        final initialPending = container.read(syncEngineProvider).pendingCount;

        await notifier.enqueueMutation(
          entityType: EntityType.workout,
          action: MutationAction.create,
          entityId: 'offline-w-1',
          payload: {'name': 'Heavy Squats'},
        );

        final state = container.read(syncEngineProvider);
        expect(state.pendingCount, equals(initialPending + 1));

        final pendingList = await repository.getPendingMutations();
        expect(pendingList.any((m) => m.entityId == 'offline-w-1'), isTrue);
      },
    );

    test('syncNow flushes queue and updates lastSyncTime', () async {
      final notifier = container.read(syncEngineProvider.notifier);

      final beforeTime = container.read(syncEngineProvider).lastSyncTime;

      await notifier.syncNow();

      final state = container.read(syncEngineProvider);
      expect(state.status, equals(SyncStatus.idle));
      expect(state.pendingCount, equals(0));
      expect(state.lastSyncTime?.isAfter(beforeTime!), isTrue);

      final queue = await repository.getPendingMutations();
      expect(queue, isEmpty);
    });

    test('reconnecting online automatically flushes queue', () async {
      final notifier = container.read(syncEngineProvider.notifier);

      await notifier.setOnline(false);
      await notifier.enqueueMutation(
        entityType: EntityType.nutrition,
        action: MutationAction.create,
        entityId: 'nut-offline-99',
        payload: {'food': 'Steak'},
      );

      expect(container.read(syncEngineProvider).pendingCount, greaterThan(0));

      // Reconnect online (which triggers and awaits syncNow())
      await notifier.setOnline(true);

      final state = container.read(syncEngineProvider);
      expect(state.isOnline, isTrue);
      expect(state.pendingCount, equals(0));
    });

    test('conflict resolution applies during push and records audit logs', () async {
      final notifier = container.read(syncEngineProvider.notifier);

      // Push mutation on existing seeded remote entity 'workout-conflict-demo'
      final mutation = OfflineMutation(
        id: 'conflict-mut-1',
        entityType: EntityType.workout,
        action: MutationAction.update,
        entityId: 'workout-conflict-demo',
        payload: {
          'id': 'workout-conflict-demo',
          'name': 'Morning Push (Local Overwrite)',
          'totalVolume': 7000.0,
        },
        // Fresh timestamp (now) -> Local should win over remote seeded 10 mins ago
        createdAt: DateTime.now(),
      );

      await repository.enqueueMutation(mutation);
      await notifier.syncNow();

      final conflicts = await repository.getConflictLogs();
      expect(conflicts, isNotEmpty);
      expect(conflicts.first.entityId, equals('workout-conflict-demo'));
      expect(conflicts.first.winner, equals('local'));
    });
  });
}
