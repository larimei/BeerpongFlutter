import '../domain/competition.dart';
import '../../../app/data/in_memory_repository.dart';

abstract interface class CompetitionRepository {
  List<Competition> getAll();

  Competition? getById(String id);

  void add(Competition competition);

  void update(Competition competition);

  void delete(String id);

  void clear();
}

class InMemoryCompetitionRepository extends InMemoryRepository<Competition>
    implements CompetitionRepository {
  InMemoryCompetitionRepository([
    Iterable<Competition> initialCompetitions = const [],
  ]) : super(initialCompetitions, idOf: (competition) => competition.id);
}
