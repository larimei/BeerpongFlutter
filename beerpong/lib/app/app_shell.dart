import 'dart:async';

import 'package:flutter/material.dart';

import '../features/competitions/application/competitions_controller.dart';
import '../features/competitions/data/competition_repository.dart';
import '../features/competitions/presentation/competitions_page.dart';
import '../features/competitions/presentation/widgets/add_competition_form.dart';
import '../features/players/application/players_controller.dart';
import '../features/players/data/player_repository.dart';
import '../features/players/presentation/players_page.dart';
import '../features/teams/presentation/teams_page.dart';
import '../features/teams/application/teams_controller.dart';
import '../features/teams/data/team_repository.dart';
import '../features/teams/presentation/widgets/add_team_form.dart';
import 'data/app_state_store.dart';
import 'presentation/settings_page.dart';
import 'widgets/entity_add_form.dart';
import 'widgets/global_add_overlay.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.snapshot,
    required this.store,
    this.onSignOut,
    this.onOpenLogin,
  });

  final AppSnapshot snapshot;
  final AppStateStore store;
  final Future<void> Function()? onSignOut;
  final VoidCallback? onOpenLogin;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  static const _destinations = [
    NavigationDestination(icon: Icon(Icons.person_outline), label: 'Players'),
    NavigationDestination(icon: Icon(Icons.groups_outlined), label: 'Teams'),
    NavigationDestination(
      icon: Icon(Icons.emoji_events_outlined),
      label: 'Competitions',
    ),
  ];

  late final PlayersController _playersController;
  late final TeamsController _teamsController;
  late final CompetitionsController _competitionsController;
  late final InMemoryPlayerRepository _playerRepository;
  late final InMemoryTeamRepository _teamRepository;
  late final InMemoryCompetitionRepository _competitionRepository;
  int _selectedIndex = 0;
  bool _suspendPersistence = false;

  @override
  void initState() {
    super.initState();
    _competitionRepository = InMemoryCompetitionRepository(
      widget.snapshot.competitions,
    );
    _teamRepository = InMemoryTeamRepository(widget.snapshot.teams);
    _playerRepository = InMemoryPlayerRepository(widget.snapshot.players);
    _competitionsController = CompetitionsController(
      _competitionRepository,
      onChanged: _persist,
    );
    _teamsController = TeamsController(
      _teamRepository,
      _competitionsController,
      onChanged: _persist,
    );
    _playersController = PlayersController(
      _playerRepository,
      _teamsController,
      onChanged: _persist,
    );
  }

  @override
  void dispose() {
    _playersController.dispose();
    _teamsController.dispose();
    _competitionsController.dispose();
    super.dispose();
  }

  void _selectPage(int index) => setState(() => _selectedIndex = index);

  void _persist() {
    if (_suspendPersistence) return;
    unawaited(
      widget.store.save(
        AppSnapshot(
          players: _playerRepository.getAll(),
          teams: _teamRepository.getAll(),
          competitions: _competitionRepository.getAll(),
        ),
      ),
    );
  }

  Future<void> _clearLocalData() async {
    _suspendPersistence = true;
    _playersController.clear();
    _teamsController.clear();
    _competitionsController.clear();
    _suspendPersistence = false;
    await widget.store.clear();
    if (mounted) setState(() => _selectedIndex = 0);
  }

  Future<void> _openSettings() => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (context) => SettingsPage(
        onClearLocalData: _clearLocalData,
        onSignOut: widget.onSignOut,
        onOpenLogin: widget.onOpenLogin,
      ),
    ),
  );

  Future<void> _showGlobalAddOverlay() async {
    final target = GlobalAddTarget.values[_selectedIndex];
    final result = await showDialog<Object>(
      context: context,
      builder: (context) => GlobalAddOverlay(
        target: target,
        players: _playersController.players,
        teams: _teamsController.teams,
      ),
    );
    switch (result) {
      case NewEntity(:final name, :final color):
        _playersController.addPlayer(name: name, color: color);
      case NewTeam(:final name, :final playerIds, :final color):
        _teamsController.addTeam(
          name: name,
          playerIds: playerIds,
          color: color,
        );
      case NewCompetition(
        :final name,
        :final mode,
        :final color,
        :final teamIds,
      ):
        _competitionsController.addCompetition(
          name: name,
          mode: mode,
          color: color,
          teamIds: teamIds,
        );
      case null:
      case _:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useNavigationRail = constraints.maxWidth >= 720;
        final content = IndexedStack(
          index: _selectedIndex,
          children: [
            PlayersPage(
              controller: _playersController,
              competitionsController: _competitionsController,
              onOpenSettings: _openSettings,
            ),
            TeamsPage(
              controller: _teamsController,
              playersController: _playersController,
              competitionsController: _competitionsController,
              onOpenSettings: _openSettings,
            ),
            CompetitionsPage(
              controller: _competitionsController,
              teams: _teamsController.teams,
              onOpenSettings: _openSettings,
            ),
          ],
        );

        return Scaffold(
          body: SafeArea(
            child: useNavigationRail
                ? Row(
                    children: [
                      NavigationRail(
                        selectedIndex: _selectedIndex,
                        onDestinationSelected: _selectPage,
                        labelType: NavigationRailLabelType.all,
                        destinations: _destinations
                            .map(
                              (destination) => NavigationRailDestination(
                                icon: destination.icon,
                                label: Text(destination.label),
                              ),
                            )
                            .toList(),
                      ),
                      const VerticalDivider(width: 1),
                      Expanded(child: content),
                    ],
                  )
                : content,
          ),
          bottomNavigationBar: useNavigationRail
              ? null
              : NavigationBar(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: _selectPage,
                  destinations: _destinations,
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: _showGlobalAddOverlay,
            tooltip: 'Add',
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}
