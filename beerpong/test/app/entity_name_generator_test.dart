import 'dart:convert';

import 'package:beerpong/app/data/entity_name_generator.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('uses the matching names array for every entity type', () async {
    final bundle = _NamesAssetBundle(
      jsonEncode({
        'playerNames': ['Player Name'],
        'teamNames': ['Team Name'],
        'tournamentNames': ['Competition Name'],
      }),
    );
    final generator = EntityNameGenerator(assetBundle: bundle);

    expect(await generator.randomName(EntityNameType.player), 'Player Name');
    expect(await generator.randomName(EntityNameType.team), 'Team Name');
    expect(
      await generator.randomName(EntityNameType.competition),
      'Competition Name',
    );
    expect(bundle.loadedPaths, everyElement(EntityNameGenerator.assetPath));
  });
}

class _NamesAssetBundle extends CachingAssetBundle {
  _NamesAssetBundle(this.contents);

  final String contents;
  final List<String> loadedPaths = [];

  @override
  Future<ByteData> load(String key) async {
    loadedPaths.add(key);
    return ByteData.sublistView(Uint8List.fromList(utf8.encode(contents)));
  }
}
