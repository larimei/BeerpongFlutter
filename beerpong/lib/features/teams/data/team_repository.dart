import '../domain/team.dart';

abstract interface class TeamRepository {
  List<Team> getAll();

  Team? getById(String id);

  void add(Team team);

  void update(Team team);

  void delete(String id);

  void clear();
}

class InMemoryTeamRepository implements TeamRepository {
  InMemoryTeamRepository([Iterable<Team> initialTeams = const []])
    : _teams = List.of(initialTeams);

  final List<Team> _teams;

  @override
  List<Team> getAll() => List.unmodifiable(_teams);

  @override
  Team? getById(String id) {
    for (final team in _teams) {
      if (team.id == id) return team;
    }
    return null;
  }

  @override
  void add(Team team) => _teams.add(team);

  @override
  void update(Team team) {
    final index = _teams.indexWhere((candidate) => candidate.id == team.id);
    if (index != -1) _teams[index] = team;
  }

  @override
  void delete(String id) => _teams.removeWhere((team) => team.id == id);

  @override
  void clear() => _teams.clear();
}
