import 'package:flutter/material.dart';

import '../data/competition_repository.dart';
import '../domain/competition.dart';

class CompetitionsController extends ChangeNotifier {
  CompetitionsController(this._repository)
    : _competitions = _repository.getAll();

  final CompetitionRepository _repository;
  List<Competition> _competitions;
  int _nextId = 0;

  List<Competition> get competitions => List.unmodifiable(_competitions);

  bool addCompetition({
    required String name,
    required TournamentMode mode,
    required Color color,
  }) {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) return false;

    _repository.add(
      Competition(
        id: '${DateTime.now().microsecondsSinceEpoch}-${_nextId++}',
        name: trimmedName,
        mode: mode,
        color: color,
      ),
    );
    _competitions = _repository.getAll();
    notifyListeners();
    return true;
  }
}
