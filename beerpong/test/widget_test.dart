import 'package:beerpong/app/app.dart';
import 'package:beerpong/app/presentation/auth_gate.dart';
import 'package:beerpong/app/presentation/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('settings lets guests return to login', (tester) async {
    var openedLogin = false;
    await tester.pumpWidget(
      MaterialApp(
        home: SettingsPage(
          onClearLocalData: () async {},
          onOpenLogin: () => openedLogin = true,
        ),
      ),
    );

    await tester.tap(find.text('Sign in'));

    expect(openedLogin, isTrue);
    expect(find.text('Sign out'), findsNothing);
  });

  testWidgets('settings offers sign out for authenticated sessions', (
    tester,
  ) async {
    var signedOut = false;
    await tester.pumpWidget(
      MaterialApp(
        home: SettingsPage(
          onClearLocalData: () async {},
          onSignOut: () async => signedOut = true,
        ),
      ),
    );

    await tester.tap(find.text('Sign out'));

    expect(signedOut, isTrue);
  });

  testWidgets('guest mode warns that browser data can be lost', (tester) async {
    var startedGuestMode = false;
    await tester.pumpWidget(
      MaterialApp(
        home: AuthPage(onUseGuestMode: () => startedGuestMode = true),
      ),
    );

    await tester.tap(find.text('Continue without an account'));
    await tester.pumpAndSettle();

    expect(find.text('Continue as guest?'), findsOneWidget);
    expect(find.textContaining('only in this browser'), findsOneWidget);
    expect(find.textContaining('switch browsers'), findsOneWidget);

    await tester.tap(find.text('Continue anyway'));
    await tester.pumpAndSettle();

    expect(startedGuestMode, isTrue);
  });

  testWidgets('navigates between the primary pages', (tester) async {
    await tester.pumpWidget(const BeerpongApp());

    expect(find.text('Players'), findsWidgets);

    await tester.tap(find.byIcon(Icons.groups_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Teams'), findsWidgets);

    await tester.tap(find.byIcon(Icons.emoji_events_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Competitions'), findsWidgets);
  });

  testWidgets('global add button opens the current page overlay', (
    tester,
  ) async {
    await tester.pumpWidget(const BeerpongApp());

    await tester.tap(find.byIcon(Icons.groups_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Add'));
    await tester.pumpAndSettle();
    expect(find.text('Add team'), findsOneWidget);
    expect(find.text('Add player'), findsNothing);
    expect(find.text('No players available. Add players first.'), findsNothing);
    await tester.tap(find.text('Manage players'));
    await tester.pumpAndSettle();
    expect(
      find.text('No players available. Add players first.'),
      findsOneWidget,
    );

    await tester.tap(find.widgetWithText(TextButton, 'Cancel').last);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.emoji_events_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Add'));
    await tester.pumpAndSettle();
    expect(find.text('Add competition'), findsOneWidget);
    expect(find.text('Tournament mode'), findsOneWidget);
  });
}
