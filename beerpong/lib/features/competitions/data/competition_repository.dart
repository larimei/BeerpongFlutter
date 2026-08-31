import '../domain/competition.dart';

abstract interface class CompetitionRepository {
  List<Competition> getAll();

  void add(Competition competition);
}

class InMemoryCompetitionRepository implements CompetitionRepository {
  InMemoryCompetitionRepository([
    Iterable<Competition> initialCompetitions = const [],
  ]) : _competitions = List.of(initialCompetitions);

  final List<Competition> _competitions;

  @override
  List<Competition> getAll() => List.unmodifiable(_competitions);

  @override
  void add(Competition competition) => _competitions.add(competition);
}
