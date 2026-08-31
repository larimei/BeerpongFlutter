import 'package:flutter/material.dart';

import '../features/competitions/presentation/competitions_page.dart';
import '../features/players/presentation/players_page.dart';
import '../features/teams/presentation/teams_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  static const _pages = [PlayersPage(), TeamsPage(), CompetitionsPage()];
  static const _destinations = [
    NavigationDestination(icon: Icon(Icons.person_outline), label: 'Players'),
    NavigationDestination(icon: Icon(Icons.groups_outlined), label: 'Teams'),
    NavigationDestination(
      icon: Icon(Icons.emoji_events_outlined),
      label: 'Competitions',
    ),
  ];

  int _selectedIndex = 0;

  void _selectPage(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useNavigationRail = constraints.maxWidth >= 720;
        final content = IndexedStack(index: _selectedIndex, children: _pages);

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
        );
      },
    );
  }
}
