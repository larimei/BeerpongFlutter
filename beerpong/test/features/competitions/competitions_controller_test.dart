import 'package:beerpong/features/competitions/application/competitions_controller.dart';
import 'package:beerpong/features/competitions/data/competition_repository.dart';
import 'package:beerpong/features/competitions/domain/competition.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CompetitionsController', () {
    late CompetitionsController controller;

    setUp(() {
      controller = CompetitionsController(InMemoryCompetitionRepository());
    });

    tearDown(() => controller.dispose());

    test('creates a trimmed knockout competition without teams', () {
      final added = controller.addCompetition(
        name: '  Summer Cup  ',
        mode: TournamentMode.knockout,
        color: Colors.amber,
      );

      expect(added, isTrue);
      expect(controller.competitions, hasLength(1));
      expect(controller.competitions.single.name, 'Summer Cup');
      expect(controller.competitions.single.mode, TournamentMode.knockout);
      expect(controller.competitions.single.teamIds, isEmpty);
      expect(controller.competitions.single.color, Colors.amber);
    });

    test('rejects a whitespace-only competition name', () {
      final added = controller.addCompetition(
        name: '   ',
        mode: TournamentMode.knockout,
        color: Colors.amber,
      );

      expect(added, isFalse);
      expect(controller.competitions, isEmpty);
    });

    test('allows duplicate names and retains creation order and modes', () {
      controller.addCompetition(
        name: 'Open Cup',
        mode: TournamentMode.roundRobin,
        color: Colors.blue,
      );
      controller.addCompetition(
        name: 'Open Cup',
        mode: TournamentMode.knockout,
        color: Colors.red,
      );

      expect(controller.competitions.map((competition) => competition.name), [
        'Open Cup',
        'Open Cup',
      ]);
      expect(controller.competitions.map((competition) => competition.mode), [
        TournamentMode.roundRobin,
        TournamentMode.knockout,
      ]);
    });

    test('looks up and edits a competition while preserving its teams', () {
      const competition = Competition(
        id: 'competition-1',
        name: 'Original Cup',
        mode: TournamentMode.knockout,
        color: Colors.amber,
        teamIds: ['team-1', 'team-2'],
      );
      controller.dispose();
      controller = CompetitionsController(
        InMemoryCompetitionRepository([competition]),
      );

      final updated = controller.updateCompetition(
        id: competition.id,
        name: '  Renamed Cup  ',
        mode: TournamentMode.roundRobin,
        color: Colors.blue,
      );

      expect(updated, isTrue);
      expect(controller.competitionById(competition.id)?.name, 'Renamed Cup');
      expect(
        controller.competitionById(competition.id)?.mode,
        TournamentMode.roundRobin,
      );
      expect(controller.competitionById(competition.id)?.color, Colors.blue);
      expect(controller.competitionById(competition.id)?.teamIds, [
        'team-1',
        'team-2',
      ]);
    });

    test('rejects invalid edits and handles a missing competition', () {
      controller.addCompetition(
        name: 'Open Cup',
        mode: TournamentMode.knockout,
        color: Colors.amber,
      );
      final id = controller.competitions.single.id;

      expect(
        controller.updateCompetition(
          id: id,
          name: '   ',
          mode: TournamentMode.roundRobin,
          color: Colors.blue,
        ),
        isFalse,
      );
      expect(
        controller.updateCompetition(
          id: 'missing',
          name: 'Missing Cup',
          mode: TournamentMode.roundRobin,
          color: Colors.blue,
        ),
        isFalse,
      );
      expect(controller.competitionById('missing'), isNull);
      expect(controller.competitionById(id)?.name, 'Open Cup');
    });

    test('deletes only the selected competition', () {
      controller.addCompetition(
        name: 'First Cup',
        mode: TournamentMode.knockout,
        color: Colors.amber,
      );
      controller.addCompetition(
        name: 'Second Cup',
        mode: TournamentMode.roundRobin,
        color: Colors.blue,
      );
      final firstId = controller.competitions.first.id;

      controller.deleteCompetition(firstId);

      expect(controller.competitionById(firstId), isNull);
      expect(controller.competitions.single.name, 'Second Cup');
    });
  });
}
