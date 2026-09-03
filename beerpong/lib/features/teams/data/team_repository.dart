import '../domain/team.dart';
import '../../../app/data/in_memory_repository.dart';

abstract interface class TeamRepository {
  List<Team> getAll();

  Team? getById(String id);

  void add(Team team);

  void update(Team team);

  void delete(String id);

  void clear();
}

class InMemoryTeamRepository extends InMemoryRepository<Team>
    implements TeamRepository {
  InMemoryTeamRepository([Iterable<Team> initialTeams = const []])
    : super(initialTeams, idOf: (team) => team.id);
}
