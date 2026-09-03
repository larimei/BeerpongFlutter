class InMemoryRepository<T> {
  InMemoryRepository(Iterable<T> initialItems, {required this.idOf})
    : _items = List.of(initialItems);

  final String Function(T item) idOf;
  final List<T> _items;

  List<T> getAll() => List.unmodifiable(_items);

  T? getById(String id) {
    for (final item in _items) {
      if (idOf(item) == id) return item;
    }
    return null;
  }

  void add(T item) => _items.add(item);

  void update(T item) {
    final index = _items.indexWhere(
      (candidate) => idOf(candidate) == idOf(item),
    );
    if (index != -1) _items[index] = item;
  }

  void delete(String id) => _items.removeWhere((item) => idOf(item) == id);

  void clear() => _items.clear();
}
