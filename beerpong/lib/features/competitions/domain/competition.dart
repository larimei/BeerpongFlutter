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

  Competition copyWith({
    String? name,
    TournamentMode? mode,
    Color? color,
    List<String>? teamIds,
  }) {
    return Competition(
      id: id,
      name: name ?? this.name,
      mode: mode ?? this.mode,
      color: color ?? this.color,
      teamIds: teamIds ?? this.teamIds,
    );
  }
}
