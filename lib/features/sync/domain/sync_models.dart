/// Operational state of the background sync engine.
enum SyncStatus {
  idle,
  syncing,
  offline,
  error;

  String get displayName => switch (this) {
    SyncStatus.idle => 'Synced',
    SyncStatus.syncing => 'Syncing...',
    SyncStatus.offline => 'Offline',
    SyncStatus.error => 'Sync Error',
  };
}

/// The mutation operation performed offline.
enum MutationAction { create, update, delete }

/// The category of entity being modified.
enum EntityType {
  workout,
  setLog,
  nutrition,
  profile;

  String get displayName => switch (this) {
    EntityType.workout => 'Workout Session',
    EntityType.setLog => 'Exercise Set',
    EntityType.nutrition => 'Nutrition Entry',
    EntityType.profile => 'User Profile',
  };
}

/// An offline mutation queued for synchronization with the remote backend.
class OfflineMutation {
  const OfflineMutation({
    required this.id,
    required this.entityType,
    required this.action,
    required this.entityId,
    required this.payload,
    required this.createdAt,
    this.retryCount = 0,
    this.lastError,
  });

  final String id;
  final EntityType entityType;
  final MutationAction action;
  final String entityId;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  final int retryCount;
  final String? lastError;

  OfflineMutation copyWith({
    String? id,
    EntityType? entityType,
    MutationAction? action,
    String? entityId,
    Map<String, dynamic>? payload,
    DateTime? createdAt,
    int? retryCount,
    String? lastError,
  }) {
    return OfflineMutation(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      action: action ?? this.action,
      entityId: entityId ?? this.entityId,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      retryCount: retryCount ?? this.retryCount,
      lastError: lastError ?? this.lastError,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'entityType': entityType.name,
    'action': action.name,
    'entityId': entityId,
    'payload': payload,
    'createdAt': createdAt.toIso8601String(),
    'retryCount': retryCount,
    'lastError': lastError,
  };

  factory OfflineMutation.fromJson(Map<String, dynamic> json) =>
      OfflineMutation(
        id: json['id'] as String,
        entityType: EntityType.values.byName(json['entityType'] as String),
        action: MutationAction.values.byName(json['action'] as String),
        entityId: json['entityId'] as String,
        payload: Map<String, dynamic>.from(json['payload'] as Map),
        createdAt: DateTime.parse(json['createdAt'] as String),
        retryCount: json['retryCount'] as int? ?? 0,
        lastError: json['lastError'] as String?,
      );
}

/// Audit log entry recorded when a conflict between local and remote versions is resolved.
class ConflictResolutionLog {
  const ConflictResolutionLog({
    required this.id,
    required this.entityId,
    required this.entityType,
    required this.localTimestamp,
    required this.remoteTimestamp,
    required this.winner,
    required this.strategy,
    required this.resolvedAt,
  });

  final String id;
  final String entityId;
  final EntityType entityType;
  final DateTime localTimestamp;
  final DateTime remoteTimestamp;
  final String winner; // 'local' or 'remote'
  final String strategy;
  final DateTime resolvedAt;
}

/// Snapshot of the synchronization engine state.
class SyncState {
  const SyncState({
    this.status = SyncStatus.idle,
    this.isOnline = true,
    this.lastSyncTime,
    this.pendingCount = 0,
    this.lastError,
  });

  final SyncStatus status;
  final bool isOnline;
  final DateTime? lastSyncTime;
  final int pendingCount;
  final String? lastError;

  SyncState copyWith({
    SyncStatus? status,
    bool? isOnline,
    DateTime? lastSyncTime,
    int? pendingCount,
    String? lastError,
  }) {
    return SyncState(
      status: status ?? this.status,
      isOnline: isOnline ?? this.isOnline,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      pendingCount: pendingCount ?? this.pendingCount,
      lastError: lastError ?? this.lastError,
    );
  }
}
