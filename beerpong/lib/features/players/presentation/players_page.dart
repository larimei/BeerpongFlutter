import 'package:flutter/material.dart';

import '../../../app/widgets/entity_card.dart';
import '../application/players_controller.dart';
import 'player_details_page.dart';

class PlayersPage extends StatelessWidget {
  const PlayersPage({
    required this.controller,
    this.onOpenSettings,
    super.key,
  });

  final PlayersController controller;
  final VoidCallback? onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FAF9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0FAF9),
        title: const Text('Players'),
        actions: [
          IconButton(
            onPressed: onOpenSettings,
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          final players = controller.players;
          if (players.isEmpty) {
            return const _EmptyPlayers();
          }
          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 96),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
            ),
            itemCount: players.length,
            itemBuilder: (context, index) {
              final player = players[index];
              return EntityCard(
                name: player.name,
                color: player.color,
                icon: Icons.sports_bar_outlined,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => PlayerDetailsPage(
                      playerId: player.id,
                      controller: controller,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _EmptyPlayers extends StatelessWidget {
  const _EmptyPlayers();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sports_bar_outlined,
              size: 72,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 20),
            Text(
              'No players yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'Add your first player to start building the tournament.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
