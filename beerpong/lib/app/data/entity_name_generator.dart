import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';

enum EntityNameType {
  player('playerNames'),
  team('teamNames'),
  competition('tournamentNames');

  const EntityNameType(this.jsonKey);

  final String jsonKey;
}

class EntityNameGenerator {
  EntityNameGenerator({AssetBundle? assetBundle, Random? random})
    : _assetBundle = assetBundle ?? rootBundle,
      _random = random ?? Random();

  static const assetPath = 'lib/assets/names.json';

  final AssetBundle _assetBundle;
  final Random _random;

  Future<String> randomName(EntityNameType type) async {
    final namesByType = await _loadNames();
    final names = namesByType[type.jsonKey];
    if (names is! List<dynamic>) return '';

    final validNames = names
        .whereType<String>()
        .where((name) => name.trim().isNotEmpty)
        .toList();
    if (validNames.isEmpty) return '';
    return validNames[_random.nextInt(validNames.length)];
  }

  Future<Map<String, dynamic>> _loadNames() async {
    final json = jsonDecode(
      await _assetBundle.loadString(assetPath, cache: false),
    );
    return json is Map<String, dynamic> ? json : const {};
  }
}
