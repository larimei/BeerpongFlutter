import 'dart:convert';

import 'package:localstorage/localstorage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_snapshot.dart';

export 'app_snapshot.dart';

abstract interface class AppStateStore {
  Future<AppSnapshot> load();
  Future<void> save(AppSnapshot snapshot);
  Future<void> clear();
}

/// Persists the app snapshot through the localstorage package.
class BrowserAppStateStore implements AppStateStore {
  const BrowserAppStateStore();

  static const _storageKey = 'beerpong.app_snapshot';

  @override
  Future<AppSnapshot> load() async {
    try {
      await initLocalStorage();
      final encoded = localStorage.getItem(_storageKey);
      if (encoded == null) return const AppSnapshot.empty();
      final snapshot = AppSnapshot.tryDecode(encoded);
      if (snapshot == null) {
        await clear();
        return const AppSnapshot.empty();
      }
      return snapshot;
    } catch (_) {
      return const AppSnapshot.empty();
    }
  }

  @override
  Future<void> save(AppSnapshot snapshot) async {
    try {
      await initLocalStorage();
      localStorage.setItem(_storageKey, snapshot.encode());
    } catch (_) {
      // The app remains usable as an in-memory session.
    }
  }

  @override
  Future<void> clear() async {
    try {
      await initLocalStorage();
      localStorage.removeItem(_storageKey);
    } catch (_) {
      // The app state has still been cleared in memory.
    }
  }
}

class SupabaseAppStateStore implements AppStateStore {
  SupabaseAppStateStore(this._client);

  final SupabaseClient _client;

  String get _userId => _client.auth.currentUser!.id;

  @override
  Future<AppSnapshot> load() async {
    final row = await _client
        .from('app_snapshots')
        .select('payload')
        .eq('owner_id', _userId)
        .maybeSingle();
    if (row == null) return const AppSnapshot.empty();
    final payload = row['payload'];
    if (payload is! Map) return const AppSnapshot.empty();
    return AppSnapshot.tryDecode(jsonEncode(payload)) ??
        const AppSnapshot.empty();
  }

  @override
  Future<void> save(AppSnapshot snapshot) async {
    await _client.from('app_snapshots').upsert({
      'owner_id': _userId,
      'payload': jsonDecode(snapshot.encode()),
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  @override
  Future<void> clear() =>
      _client.from('app_snapshots').delete().eq('owner_id', _userId);
}
