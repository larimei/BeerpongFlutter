import 'package:beerpong/app/data/app_snapshot.dart';
import 'package:beerpong/features/competitions/application/competitions_controller.dart';
import 'package:beerpong/features/competitions/data/competition_repository.dart';
import 'package:beerpong/features/competitions/domain/competition.dart';
import 'package:beerpong/features/competitions/presentation/competition_details_page.dart';
import 'package:beerpong/features/competitions/presentation/widgets/round_robin_tournament_tab.dart';
import 'package:beerpong/features/competitions/presentation/widgets/tournament_match_card.dart';
import 'package:beerpong/features/teams/domain/team.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('generates each round-robin team pairing exactly once', () {
    final controller = CompetitionsController(
      InMemoryCompetitionRepository(const [
        Competition(
          id: 'league',
          name: 'League',
          mode: TournamentMode.roundRobin,
          color: Colors.blue,
          teamIds: ['red', 'blue', 'green'],
        ),
      ]),
    );
    addTearDown(controller.dispose);

    expect(controller.generateRoundRobinTournament('league'), isTrue);

    final tournament = controller
        .competitionById('league')!
        .roundRobinTournament!;
    expect(tournament.matches, hasLength(3));
    expect(
      tournament.matches.map(
        (match) => (List<String>.of(match.teamIds)..sort()).join('-'),
      ),
      unorderedEquals(['blue-red', 'green-red', 'blue-green']),
    );
  });

  test('spreads teams across consecutive round-robin games', () {
    final tournament = RoundRobinTournament.generate([
      'red',
      'blue',
      'green',
      'yellow',
      'purple',
      'orange',
    ]);

    for (var index = 1; index < tournament.matches.length; index++) {
      expect(
        tournament.matches[index - 1].teamIds.toSet().intersection(
          tournament.matches[index].teamIds.toSet(),
        ),
        isEmpty,
      );
    }
  });

  test('updates standings and completes after every game has a winner', () {
    final controller = CompetitionsController(
      InMemoryCompetitionRepository(const [
        Competition(
          id: 'league',
          name: 'League',
          mode: TournamentMode.roundRobin,
          color: Colors.blue,
          teamIds: ['red', 'blue'],
        ),
      ]),
    );
    addTearDown(controller.dispose);
    controller.generateRoundRobinTournament('league');
    final match = controller
        .competitionById('league')!
        .roundRobinTournament!
        .matches
        .single;

    expect(
      controller.confirmRoundRobinMatchWinner(
        competitionId: 'league',
        matchId: match.id,
        winnerTeamId: 'red',
      ),
      isTrue,
    );

    final tournament = controller
        .competitionById('league')!
        .roundRobinTournament!;
    expect(tournament.standings.map((standing) => standing.teamId), [
      'red',
      'blue',
    ]);
    expect(tournament.isComplete, isTrue);
    expect(tournament.winnerTeamId, 'red');
  });

  test('clears a confirmed round-robin game', () {
    final controller = CompetitionsController(
      InMemoryCompetitionRepository(const [
        Competition(
          id: 'league',
          name: 'League',
          mode: TournamentMode.roundRobin,
          color: Colors.blue,
          teamIds: ['red', 'blue'],
        ),
      ]),
    );
    addTearDown(controller.dispose);
    controller.generateRoundRobinTournament('league');
    final match = controller
        .competitionById('league')!
        .roundRobinTournament!
        .matches
        .single;
    controller.confirmRoundRobinMatchWinner(
      competitionId: 'league',
      matchId: match.id,
      winnerTeamId: 'red',
    );

    expect(
      controller.clearRoundRobinMatchOutcome(
        competitionId: 'league',
        matchId: match.id,
      ),
      isTrue,
    );
    expect(
      controller
          .competitionById('league')!
          .roundRobinTournament!
          .matches
          .single
          .winnerTeamId,
      isNull,
    );
  });

  test(
    'uses persisted draw order when head-to-head comparison remains tied',
    () {
      const tournament = RoundRobinTournament(
        drawOrder: ['red', 'blue', 'green'],
        matches: [
          RoundRobinMatch(
            id: 'red-blue',
            teamIds: ['red', 'blue'],
            winnerTeamId: 'red',
          ),
          RoundRobinMatch(
            id: 'blue-green',
            teamIds: ['blue', 'green'],
            winnerTeamId: 'blue',
          ),
          RoundRobinMatch(
            id: 'green-red',
            teamIds: ['green', 'red'],
            winnerTeamId: 'green',
          ),
        ],
      );

      expect(tournament.standings.map((standing) => standing.teamId), [
        'red',
        'blue',
        'green',
      ]);
    },
  );

  test('uses direct comparison before draw order for equal wins', () {
    const tournament = RoundRobinTournament(
      drawOrder: ['blue', 'red', 'green', 'yellow'],
      matches: [
        RoundRobinMatch(
          id: 'red-blue',
          teamIds: ['red', 'blue'],
          winnerTeamId: 'red',
        ),
        RoundRobinMatch(
          id: 'red-green',
          teamIds: ['red', 'green'],
          winnerTeamId: 'red',
        ),
        RoundRobinMatch(
          id: 'red-yellow',
          teamIds: ['red', 'yellow'],
          winnerTeamId: 'yellow',
        ),
        RoundRobinMatch(
          id: 'blue-green',
          teamIds: ['blue', 'green'],
          winnerTeamId: 'blue',
        ),
        RoundRobinMatch(
          id: 'blue-yellow',
          teamIds: ['blue', 'yellow'],
          winnerTeamId: 'blue',
        ),
        RoundRobinMatch(
          id: 'green-yellow',
          teamIds: ['green', 'yellow'],
          winnerTeamId: 'green',
        ),
      ],
    );

    expect(tournament.standings.map((standing) => standing.teamId), [
      'red',
      'blue',
      'green',
      'yellow',
    ]);
  });

  testWidgets('shows all games with the shared tournament match card', (
    tester,
  ) async {
    final controller = CompetitionsController(
      InMemoryCompetitionRepository(const [
        Competition(
          id: 'league',
          name: 'League',
          mode: TournamentMode.roundRobin,
          color: Colors.blue,
          teamIds: ['red', 'blue', 'green'],
        ),
      ]),
    );
    addTearDown(controller.dispose);
    controller.generateRoundRobinTournament('league');

    await tester.pumpWidget(
      MaterialApp(
        home: RoundRobinTournamentTab(
          competition: controller.competitionById('league')!,
          teams: const [
            Team(id: 'red', name: 'Red', playerIds: [], color: Colors.red),
            Team(id: 'blue', name: 'Blue', playerIds: [], color: Colors.blue),
            Team(
              id: 'green',
              name: 'Green',
              playerIds: [],
              color: Colors.green,
            ),
          ],
          onConfirmWinner: (_, _) => false,
        ),
      ),
    );

    expect(find.byType(TournamentMatchCard), findsNWidgets(3));
    final background = tester.widget<Container>(
      find.byKey(const Key('round-robin-tournament-background')),
    );
    expect(background.decoration, isA<BoxDecoration>());
  });

  testWidgets('uses detail-style team chips and labels bye opponents', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TournamentMatchCard(
            teamIds: const ['red', null],
            names: const {'red': 'Red Rockets'},
            colors: const {'red': Colors.red},
            selectedWinnerId: null,
            onWinnerSelected: (_) {},
            onConfirm: () {},
            isBye: true,
          ),
        ),
      ),
    );

    expect(find.text('Freilos'), findsOneWidget);
    expect(find.text('BYE'), findsNothing);
    expect(find.text('To be decided'), findsNothing);
    expect(find.byType(Chip), findsNWidgets(2));
    expect(find.byType(Radio<String>), findsNothing);
    final cardRect = tester.getRect(find.byType(Card));
    final chips = find.byType(Chip);
    expect(
      tester.getRect(chips.first).left,
      moreOrLessEquals(cardRect.left + 16),
    );
    expect(
      tester.getRect(chips.last).right,
      moreOrLessEquals(cardRect.right - 16),
    );
  });

  testWidgets('uses the full-width winner action style for corrections', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TournamentMatchCard(
            teamIds: const ['red', 'blue'],
            names: const {'red': 'Red', 'blue': 'Blue'},
            colors: const {'red': Colors.red, 'blue': Colors.blue},
            selectedWinnerId: null,
            onWinnerSelected: (_) {},
            onConfirm: () {},
            winnerTeamId: 'red',
            onCorrectResult: () {},
          ),
        ),
      ),
    );

    final button = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, 'Correct result'),
    );
    expect(button.onPressed, isNotNull);
    expect(button.style, isNotNull);
    expect(
      tester
          .getRect(find.widgetWithText(OutlinedButton, 'Correct result'))
          .width,
      greaterThan(300),
    );
  });

  testWidgets('keeps the game card height after confirming a winner', (
    tester,
  ) async {
    Widget game({String? winnerTeamId, VoidCallback? onCorrectResult}) =>
        MaterialApp(
          home: Scaffold(
            body: TournamentMatchCard(
              teamIds: const ['red', 'blue'],
              names: const {'red': 'Red', 'blue': 'Blue'},
              colors: const {'red': Colors.red, 'blue': Colors.blue},
              selectedWinnerId: null,
              onWinnerSelected: (_) {},
              onConfirm: () {},
              winnerTeamId: winnerTeamId,
              onCorrectResult: onCorrectResult,
            ),
          ),
        );

    await tester.pumpWidget(game());
    final openHeight = tester.getSize(find.byType(Card)).height;
    await tester.pumpWidget(game(winnerTeamId: 'red', onCorrectResult: () {}));

    expect(tester.getSize(find.byType(Card)).height, openHeight);
  });

  testWidgets('uses the full placeholder label for undecided teams', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TournamentMatchCard(
            teamIds: const [null, null],
            names: const {},
            colors: const {},
            selectedWinnerId: null,
            onWinnerSelected: (_) {},
            onConfirm: () {},
            isPlayable: false,
          ),
        ),
      ),
    );

    expect(find.text('To be decided'), findsNWidgets(2));
    expect(find.text('To be'), findsNothing);
  });

  testWidgets('plays a game and shows the completed winner', (tester) async {
    final controller = CompetitionsController(
      InMemoryCompetitionRepository(const [
        Competition(
          id: 'league',
          name: 'League',
          mode: TournamentMode.roundRobin,
          color: Colors.blue,
          teamIds: ['red', 'blue'],
        ),
      ]),
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: CompetitionDetailsPage(
          competitionId: 'league',
          controller: controller,
          teams: const [
            Team(id: 'red', name: 'Red', playerIds: [], color: Colors.red),
            Team(id: 'blue', name: 'Blue', playerIds: [], color: Colors.blue),
          ],
        ),
      ),
    );
    await tester.tap(find.text('Generate tournament'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tournament'));
    await tester.pumpAndSettle();

    expect(find.text('Games'), findsOneWidget);
    await tester.tap(find.text('Red').first);
    await tester.pump();
    await tester.tap(find.text('Confirm winner'));
    await tester.pumpAndSettle();

    expect(find.text('Winner: Red'), findsOneWidget);
    expect(find.text('1 wins'), findsOneWidget);
    expect(find.byIcon(Icons.emoji_events_outlined), findsOneWidget);
    expect(
      tester.widget<Icon>(find.byIcon(Icons.emoji_events_outlined)).color,
      Colors.amber.shade700,
    );
    expect(tester.widgetList<Card>(find.byType(Card)).first.color, Colors.blue);
    expect(find.text('Correct result'), findsOneWidget);
    await tester.tap(find.text('Correct result'));
    await tester.pumpAndSettle();
    expect(find.text('Confirm winner'), findsOneWidget);
  });

  test('persists generated games, outcomes, and draw order', () {
    const tournament = RoundRobinTournament(
      drawOrder: ['red', 'blue'],
      matches: [
        RoundRobinMatch(
          id: 'game-0',
          teamIds: ['red', 'blue'],
          winnerTeamId: 'red',
        ),
      ],
    );

    final restored = AppSnapshot.tryDecode(
      AppSnapshot(
        players: const [],
        teams: const [],
        competitions: const [
          Competition(
            id: 'league',
            name: 'League',
            mode: TournamentMode.roundRobin,
            color: Colors.blue,
            teamIds: ['red', 'blue'],
            roundRobinTournament: tournament,
          ),
        ],
      ).encode(),
    );

    expect(
      restored?.competitions.single.roundRobinTournament?.drawOrder,
      tournament.drawOrder,
    );
    expect(
      restored
          ?.competitions
          .single
          .roundRobinTournament
          ?.matches
          .single
          .winnerTeamId,
      'red',
    );
  });
}
