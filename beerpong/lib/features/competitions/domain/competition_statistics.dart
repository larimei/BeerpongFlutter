import 'competition.dart';

class CompetitionStatistics {
  const CompetitionStatistics._(this._teamRecords, this._playerRecords);

  factory CompetitionStatistics.fromCompetitions(
    Iterable<Competition> competitions,
  ) {
    final teamRecords = <String, GameRecord>{};
    final playerRecords = <String, GameRecord>{};
    for (final competition in competitions) {
      final matches =
          competition.tournament?.matches ??
          competition.roundRobinTournament?.matches ??
          const <Object>[];
      for (final match in matches) {
        switch (match) {
          case KnockoutMatch(
            :final teamIds,
            :final winnerTeamId,
            :final playerIdsByTeam,
          ):
            _record(
              teamIds.whereType<String>(),
              winnerTeamId,
              playerIdsByTeam,
              teamRecords,
              playerRecords,
            );
          case RoundRobinMatch(
            :final teamIds,
            :final winnerTeamId,
            :final playerIdsByTeam,
          ):
            _record(
              teamIds,
              winnerTeamId,
              playerIdsByTeam,
              teamRecords,
              playerRecords,
            );
          case _:
            break;
        }
      }
    }
    return CompetitionStatistics._(teamRecords, playerRecords);
  }

  final Map<String, GameRecord> _teamRecords;
  final Map<String, GameRecord> _playerRecords;

  GameRecord forTeam(String teamId) => _teamRecords[teamId] ?? GameRecord.zero;

  GameRecord forPlayer(String playerId) =>
      _playerRecords[playerId] ?? GameRecord.zero;

  static void _record(
    Iterable<String> teamIds,
    String? winnerTeamId,
    Map<String, List<String>> playerIdsByTeam,
    Map<String, GameRecord> teamRecords,
    Map<String, GameRecord> playerRecords,
  ) {
    if (winnerTeamId == null) return;
    for (final teamId in teamIds) {
      final won = teamId == winnerTeamId;
      teamRecords[teamId] = (teamRecords[teamId] ?? GameRecord.zero).withResult(
        won: won,
      );
      for (final playerId in playerIdsByTeam[teamId] ?? const []) {
        playerRecords[playerId] = (playerRecords[playerId] ?? GameRecord.zero)
            .withResult(won: won);
      }
    }
  }
}

class GameRecord {
  const GameRecord({required this.won, required this.lost});

  static const zero = GameRecord(won: 0, lost: 0);

  final int won;
  final int lost;

  GameRecord withResult({required bool won}) =>
      GameRecord(won: this.won + (won ? 1 : 0), lost: lost + (won ? 0 : 1));

  @override
  bool operator ==(Object other) =>
      other is GameRecord && other.won == won && other.lost == lost;

  @override
  int get hashCode => Object.hash(won, lost);
}
