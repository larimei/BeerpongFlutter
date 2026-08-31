import 'package:flutter/material.dart';

enum TournamentMode {
  knockout('Knockout'),
  roundRobin('Round robin');

  const TournamentMode(this.label);

  final String label;
}

@immutable
class Competition {
  const Competition({
    required this.id,
    required this.name,
    required this.mode,
    required this.color,
    this.teamIds = const [],
  });

  final String id;
  final String name;
  final TournamentMode mode;
  final Color color;
  final List<String> teamIds;
}
