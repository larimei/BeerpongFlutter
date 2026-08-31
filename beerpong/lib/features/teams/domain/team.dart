import 'package:flutter/material.dart';

@immutable
class Team {
  const Team({
    required this.id,
    required this.name,
    required this.playerIds,
    required this.color,
    this.lost = 0,
    this.won = 0,
  });

  final String id;
  final String name;
  final List<String> playerIds;
  final Color color;
  final int lost;
  final int won;

  Team copyWith({String? name, List<String>? playerIds, Color? color}) {
    return Team(
      id: id,
      name: name ?? this.name,
      playerIds: List.unmodifiable(playerIds ?? this.playerIds),
      color: color ?? this.color,
      lost: lost,
      won: won,
    );
  }
}
