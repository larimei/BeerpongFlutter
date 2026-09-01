import 'package:localstorage/localstorage.dart';

import 'app_snapshot.dart';

export 'app_snapshot.dart';

/// Persists the app snapshot through the localstorage package.
class BrowserAppStateStore {
  const BrowserAppStateStore();

  static const _storageKey = 'beerpong.app_snapshot';

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

  Future<void> save(AppSnapshot snapshot) async {
    try {
      await initLocalStorage();
      localStorage.setItem(_storageKey, snapshot.encode());
    } catch (_) {
      // The app remains usable as an in-memory session.
    }
  }

  Future<void> clear() async {
    try {
      await initLocalStorage();
      localStorage.removeItem(_storageKey);
    } catch (_) {
      // The app state has still been cleared in memory.
    }
  }
}
