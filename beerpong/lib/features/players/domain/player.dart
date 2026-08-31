import 'package:flutter/material.dart';

@immutable
class Player {
  const Player({
    required this.id,
    required this.name,
    required this.color,
    this.won = 0,
    this.lost = 0,
  });

  final String id;
  final String name;
  final Color color;
  final int won;
  final int lost;

  Player copyWith({String? name, Color? color}) {
    return Player(
      id: id,
      name: name ?? this.name,
      color: color ?? this.color,
      won: won,
      lost: lost,
    );
  }
}
