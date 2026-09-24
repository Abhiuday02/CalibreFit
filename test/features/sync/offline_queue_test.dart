import 'package:calibrefit/features/sync/data/local_cache_store.dart';
import 'package:calibrefit/features/sync/data/mock_sync_repository.dart';
import 'package:calibrefit/features/sync/domain/sync_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocalCacheStore', () {
    late LocalCacheStore cache;

    setUp(() {
      cache = LocalCacheStore();
    });

    test('put and get store and retrieve records', () async {
      await cache.put('workouts', 'w-1', {'name': 'Leg Day', 'volume': 5000});

      final item = await cache.get('workouts', 'w-1');
      expect(item, isNotNull);
      expect(item!['name'], 'Leg Day');
      expect(item['volume'], 5000);
    });

    test('getAll returns all items in collection', () async {
      await cache.put('nutrition', 'n-1', {'calories': 500});
      await cache.put('nutrition', 'n-2', {'calories': 750});

      final all = await cache.getAll('nutrition');
      expect(all.length, 2);
    });

    test('delete removes specified item', () async {
      await cache.put('workouts', 'w-1', {'name': 'Upper Push'});
      await cache.delete('workouts', 'w-1');

      final item = await cache.get('workouts', 'w-1');
      expect(item, isNull);
    });

    test('clearCollection and clearAll empty stores correctly', () async {
      await cache.put('c1', '1', {'val': 1});
      await cache.put('c2', '2', {'val': 2});

      expect(cache.totalRecordsCount, 2);

      await cache.clearCollection('c1');
      expect(cache.count('c1'), 0);
      expect(cache.count('c2'), 1);

      await cache.clearAll();
      expect(cache.totalRecordsCount, 0);
    });
  });

  group('OfflineMutation', () {
    test('serializes and deserializes correctly via JSON', () {
      final mutation = OfflineMutation(
        id: 'mut-123',
        entityType: EntityType.workout,
        action: MutationAction.create,
        entityId: 'workout-999',
        payload: {'name': 'Chest Day', 'sets': 4},
        createdAt: DateTime(2026, 9, 21, 10, 0),
        retryCount: 1,
        lastError: 'Network timeout',
      );

      final json = mutation.toJson();
      final revived = OfflineMutation.fromJson(json);

      expect(revived.id, mutation.id);
      expect(revived.entityType, mutation.entityType);
      expect(revived.action, mutation.action);
      expect(revived.entityId, mutation.entityId);
      expect(revived.payload['name'], 'Chest Day');
      expect(revived.createdAt, mutation.createdAt);
      expect(revived.retryCount, 1);
      expect(revived.lastError, 'Network timeout');
    });
  });

  group('MockSyncRepository Queue', () {
    late MockSyncRepository repository;

    setUp(() {
      repository = MockSyncRepository();
    });

    test('enqueueMutation and getPendingMutations manage queue', () async {
      final initial = await repository.getPendingMutations();
      final initialCount = initial.length;

      final newMutation = OfflineMutation(
        id: 'test-mut-1',
        entityType: EntityType.nutrition,
        action: MutationAction.create,
        entityId: 'nut-55',
        payload: {'food': 'Eggs', 'calories': 140},
        createdAt: DateTime.now(),
      );

      await repository.enqueueMutation(newMutation);

      final updated = await repository.getPendingMutations();
      expect(updated.length, initialCount + 1);
      expect(updated.any((m) => m.id == 'test-mut-1'), isTrue);

      await repository.removeMutation('test-mut-1');
      final afterRemove = await repository.getPendingMutations();
      expect(afterRemove.length, initialCount);

      await repository.clearQueue();
      final afterClear = await repository.getPendingMutations();
      expect(afterClear, isEmpty);
    });
  });
}
