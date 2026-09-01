import 'package:beerpong/features/competitions/domain/competition.dart';
import 'package:beerpong/features/competitions/domain/competition_statistics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('derives team and snapshotted player results from confirmed games', () {
    const competition = Competition(
      id: 'cup',
      name: 'Cup',
      mode: TournamentMode.roundRobin,
      color: Colors.amber,
      roundRobinTournament: RoundRobinTournament(
        drawOrder: ['red', 'blue'],
        matches: [
          RoundRobinMatch(
            id: 'game-0',
            teamIds: ['red', 'blue'],
            winnerTeamId: 'red',
            playerIdsByTeam: {
              'red': ['player-1', 'player-2'],
              'blue': ['player-3'],
            },
          ),
        ],
      ),
    );

    final statistics = CompetitionStatistics.fromCompetitions([competition]);

    expect(statistics.forTeam('red'), const GameRecord(won: 1, lost: 0));
    expect(statistics.forTeam('blue'), const GameRecord(won: 0, lost: 1));
    expect(statistics.forPlayer('player-1'), const GameRecord(won: 1, lost: 0));
    expect(statistics.forPlayer('player-2'), const GameRecord(won: 1, lost: 0));
    expect(statistics.forPlayer('player-3'), const GameRecord(won: 0, lost: 1));
  });
}
