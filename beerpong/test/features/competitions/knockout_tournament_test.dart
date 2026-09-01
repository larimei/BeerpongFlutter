import 'package:beerpong/app/data/app_snapshot.dart';
import 'package:beerpong/features/competitions/application/competitions_controller.dart';
import 'package:beerpong/features/competitions/data/competition_repository.dart';
import 'package:beerpong/features/competitions/domain/competition.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('knockout tournaments', () {
    late CompetitionsController controller;

    setUp(() {
      controller = CompetitionsController(
        InMemoryCompetitionRepository(const [
          Competition(
            id: 'cup',
            name: 'Cup',
            mode: TournamentMode.knockout,
            color: Colors.amber,
            teamIds: ['red', 'blue'],
          ),
        ]),
      );
    });

    tearDown(() => controller.dispose());

    test('generates and completes a two-team tournament', () {
      expect(controller.generateKnockoutTournament('cup'), isTrue);

      final tournament = controller.competitionById('cup')!.tournament!;
      expect(tournament.matches, hasLength(1));
      expect(
        tournament.matches.single.teamIds,
        unorderedEquals(['red', 'blue']),
      );
      expect(tournament.matches.single.isPlayable, isTrue);

      final winner = tournament.matches.single.teamIds.first!;
      expect(
        controller.confirmKnockoutMatchWinner(
          competitionId: 'cup',
          matchId: tournament.matches.single.id,
          winnerTeamId: winner,
        ),
        isTrue,
      );
      expect(
        controller.competitionById('cup')!.tournament!.winnerTeamId,
        winner,
      );
      expect(controller.competitionById('cup')!.tournament!.isComplete, isTrue);
    });

    test('uses automatic byes and locks future matches for three teams', () {
      controller = CompetitionsController(
        InMemoryCompetitionRepository(const [
          Competition(
            id: 'cup',
            name: 'Cup',
            mode: TournamentMode.knockout,
            color: Colors.amber,
            teamIds: ['red', 'blue', 'green'],
          ),
        ]),
      );

      expect(controller.generateKnockoutTournament('cup'), isTrue);
      final tournament = controller.competitionById('cup')!.tournament!;
      expect(tournament.bracketSize, 4);
      expect(tournament.matches.where((match) => match.isBye), hasLength(1));
      expect(tournament.matches.last.isPlayable, isFalse);
      expect(tournament.matches.last.teamIds.whereType<String>(), hasLength(1));
    });

    test('advances a confirmed first-round winner into the final', () {
      controller.dispose();
      controller = CompetitionsController(
        InMemoryCompetitionRepository(const [
          Competition(
            id: 'cup',
            name: 'Cup',
            mode: TournamentMode.knockout,
            color: Colors.amber,
            teamIds: ['red', 'blue', 'green'],
          ),
        ]),
      );
      controller.generateKnockoutTournament('cup');
      final firstRoundMatch = controller
          .competitionById('cup')!
          .tournament!
          .matches
          .firstWhere((match) => match.isPlayable);
      final winner = firstRoundMatch.teamIds.first!;

      expect(
        controller.confirmKnockoutMatchWinner(
          competitionId: 'cup',
          matchId: firstRoundMatch.id,
          winnerTeamId: winner,
        ),
        isTrue,
      );
      final finalMatch = controller
          .competitionById('cup')!
          .tournament!
          .matches
          .last;
      expect(finalMatch.teamIds, contains(winner));
      expect(finalMatch.isPlayable, isTrue);
    });

    test('rejects invalid generation and unconfirmed winner changes', () {
      expect(
        controller.confirmKnockoutMatchWinner(
          competitionId: 'cup',
          matchId: 'missing',
          winnerTeamId: 'red',
        ),
        isFalse,
      );
      expect(controller.generateKnockoutTournament('missing'), isFalse);
    });

    test(
      'clears a bracket and rejects match confirmations after mode change',
      () {
        controller.generateKnockoutTournament('cup');
        final matchId = controller
            .competitionById('cup')!
            .tournament!
            .matches
            .single
            .id;

        expect(
          controller.updateCompetition(
            id: 'cup',
            name: 'Cup',
            mode: TournamentMode.roundRobin,
            color: Colors.amber,
          ),
          isTrue,
        );
        expect(controller.competitionById('cup')!.tournament, isNull);
        expect(
          controller.confirmKnockoutMatchWinner(
            competitionId: 'cup',
            matchId: matchId,
            winnerTeamId: 'red',
          ),
          isFalse,
        );
      },
    );

    test('persists the drawn bracket and confirmed outcome', () {
      controller.generateKnockoutTournament('cup');
      final tournament = controller.competitionById('cup')!.tournament!;
      final winner = tournament.matches.single.teamIds.first!;
      controller.confirmKnockoutMatchWinner(
        competitionId: 'cup',
        matchId: tournament.matches.single.id,
        winnerTeamId: winner,
      );

      final restored = AppSnapshot.tryDecode(
        AppSnapshot(
          players: const [],
          teams: const [],
          competitions: controller.competitions,
        ).encode(),
      );

      expect(
        restored?.competitions.single.tournament?.drawOrder,
        tournament.drawOrder,
      );
      expect(restored?.competitions.single.tournament?.winnerTeamId, winner);
    });
  });
}
