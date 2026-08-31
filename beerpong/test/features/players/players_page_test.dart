import 'package:beerpong/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

void main() {
  testWidgets('adds a player and opens details from a two-column card', (
    tester,
  ) async {
    await tester.pumpWidget(const BeerpongApp());
    expect(find.text('No players yet'), findsOneWidget);

    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
    await tester.tap(find.byTooltip('Add'));
    await tester.pumpAndSettle();
    expect(find.text('Add player'), findsOneWidget);
    expect(find.text('Add Team'), findsNothing);
    expect(find.text('Add Competition'), findsNothing);
    await tester.tap(find.widgetWithText(FilledButton, 'Add'));
    await tester.pump();
    expect(find.text('Enter a player name'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'Lara');
    await tester.tap(find.widgetWithText(FilledButton, 'Add'));
    await tester.pumpAndSettle();

    final grid = tester.widget<GridView>(find.byType(GridView));
    final delegate =
        grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
    expect(delegate.crossAxisCount, 2);
    expect(delegate.childAspectRatio, 1);
    expect(find.text('Won games'), findsNothing);
    expect(find.text('Lost games'), findsNothing);
    expect(find.text('Delete player'), findsNothing);

    await tester.tap(find.text('Lara'));
    await tester.pumpAndSettle();
    expect(find.text('Player details'), findsOneWidget);
    expect(find.text('Won games'), findsOneWidget);
    expect(find.text('Lost games'), findsOneWidget);
    expect(find.text('0'), findsNWidgets(2));
    expect(find.text('Delete player'), findsOneWidget);
    expect(find.byKey(const Key('player-details-surface')), findsOneWidget);
    final detailsBackground = tester.widget<Container>(
      find.byKey(const Key('player-details-background')),
    );
    final detailsDecoration = detailsBackground.decoration as BoxDecoration;
    final detailsGradient = detailsDecoration.gradient as LinearGradient;
    expect(detailsGradient.colors, [const Color(0xFFFFD95A), Colors.white]);
    expect(find.byKey(const Key('player-avatar')), findsOneWidget);
    final avatar = tester.widget<Container>(
      find.byKey(const Key('player-avatar')),
    );
    final avatarDecoration = avatar.decoration as BoxDecoration;
    expect(avatarDecoration.boxShadow, isNull);
    final detailsIcon = tester.widget<Icon>(
      find.byKey(const Key('player-details-icon')),
    );
    expect(detailsIcon.color, const Color(0xFFFFD95A));
  });

  testWidgets('edits and deletes a player from details only', (tester) async {
    await tester.pumpWidget(const BeerpongApp());
    await tester.tap(find.byTooltip('Add'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Jonathan');
    await tester.tap(find.widgetWithText(FilledButton, 'Add'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Jonathan'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Edit player'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), '  Marcel  ');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();
    expect(find.text('Marcel'), findsOneWidget);

    await tester.ensureVisible(find.text('Delete player'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete player'));
    await tester.pumpAndSettle();
    expect(
      find.text('Are you sure you want to delete Marcel?'),
      findsOneWidget,
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();
    expect(find.text('No players yet'), findsOneWidget);
  });

  testWidgets('color picker shows a preview and requires confirmation', (
    tester,
  ) async {
    await tester.pumpWidget(const BeerpongApp());
    await tester.tap(find.byTooltip('Add'));
    await tester.pumpAndSettle();

    final background = tester.widget<Container>(
      find.byKey(const Key('add-player-background')),
    );
    final backgroundDecoration = background.decoration as BoxDecoration;
    final gradient = backgroundDecoration.gradient as LinearGradient;
    expect(gradient.colors, [const Color(0xFFFFD95A), Colors.white]);
    expect(find.byKey(const Key('selected-color-preview')), findsOneWidget);
    await tester.tap(find.text('Choose color'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('player-color-wheel')), findsOneWidget);
    expect(find.byKey(const Key('color-picker-preview')), findsOneWidget);
    expect(find.text('Use color'), findsOneWidget);

    final wheel = tester.widget<HueRingPicker>(
      find.byKey(const Key('player-color-wheel')),
    );
    wheel.onColorChanged(Colors.blue);
    await tester.pump();
    final pickerIcon = tester.widget<Icon>(
      find.byKey(const Key('color-picker-player-icon')),
    );
    expect(pickerIcon.color, Colors.blue);

    await tester.tap(find.text('Use color'));
    await tester.pumpAndSettle();
    final addIcon = tester.widget<Icon>(
      find.byKey(const Key('add-player-icon')),
    );
    expect(addIcon.color, Colors.blue);
  });
}
