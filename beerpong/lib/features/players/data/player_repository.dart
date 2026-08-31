import '../domain/player.dart';

abstract interface class PlayerRepository {
  List<Player> getAll();

  Player? getById(String id);

  void add(Player player);

  void update(Player player);

  void delete(String id);
}

class InMemoryPlayerRepository implements PlayerRepository {
  InMemoryPlayerRepository([Iterable<Player> initialPlayers = const []])
    : _players = List.of(initialPlayers);

  final List<Player> _players;

  @override
  List<Player> getAll() => List.unmodifiable(_players);

  @override
  Player? getById(String id) {
    for (final player in _players) {
      if (player.id == id) return player;
    }
    return null;
  }

  @override
  void add(Player player) => _players.add(player);

  @override
  void update(Player player) {
    final index = _players.indexWhere((candidate) => candidate.id == player.id);
    if (index != -1) _players[index] = player;
  }

  @override
  void delete(String id) => _players.removeWhere((player) => player.id == id);
}
