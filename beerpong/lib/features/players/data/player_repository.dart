import '../domain/player.dart';
import '../../../app/data/in_memory_repository.dart';

abstract interface class PlayerRepository {
  List<Player> getAll();

  Player? getById(String id);

  void add(Player player);

  void update(Player player);

  void delete(String id);

  void clear();
}

class InMemoryPlayerRepository extends InMemoryRepository<Player>
    implements PlayerRepository {
  InMemoryPlayerRepository([Iterable<Player> initialPlayers = const []])
    : super(initialPlayers, idOf: (player) => player.id);
}
