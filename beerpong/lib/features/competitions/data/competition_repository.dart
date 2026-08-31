import '../domain/competition.dart';

abstract interface class CompetitionRepository {
  List<Competition> getAll();

  Competition? getById(String id);

  void add(Competition competition);

  void update(Competition competition);

  void delete(String id);
}

class InMemoryCompetitionRepository implements CompetitionRepository {
  InMemoryCompetitionRepository([
    Iterable<Competition> initialCompetitions = const [],
  ]) : _competitions = List.of(initialCompetitions);

  final List<Competition> _competitions;

  @override
  List<Competition> getAll() => List.unmodifiable(_competitions);

  @override
  Competition? getById(String id) {
    for (final competition in _competitions) {
      if (competition.id == id) return competition;
    }
    return null;
  }

  @override
  void add(Competition competition) => _competitions.add(competition);

  @override
  void update(Competition competition) {
    final index = _competitions.indexWhere(
      (candidate) => candidate.id == competition.id,
    );
    if (index != -1) _competitions[index] = competition;
  }

  @override
  void delete(String id) {
    _competitions.removeWhere((competition) => competition.id == id);
  }
}
