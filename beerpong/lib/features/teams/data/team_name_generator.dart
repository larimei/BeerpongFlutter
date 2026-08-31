import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';

class TeamNameGenerator {
  TeamNameGenerator({AssetBundle? assetBundle, Random? random})
    : _assetBundle = assetBundle ?? rootBundle,
      _random = random ?? Random();

  static const assetPath = 'lib/assets/team_names.json';

  final AssetBundle _assetBundle;
  final Random _random;

  Future<String> randomName() async {
    final json = await _assetBundle.loadString(assetPath);
    final names = (jsonDecode(json) as List<dynamic>)
        .whereType<String>()
        .where((name) => name.trim().isNotEmpty)
        .toList();
    if (names.isEmpty) return '';
    return names[_random.nextInt(names.length)];
  }
}
