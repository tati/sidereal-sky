import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sidereal_sky/main.dart';

import 'jpl_fixture.dart';

/// Pumps the app with [client] standing in for the network, then lets the
/// (real) async HTTP work settle.
Future<void> pumpApp(WidgetTester tester, http.Client client) async {
  // iPhone 15/16 Pro sized screen.
  tester.view.physicalSize = const Size(1179, 2556);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await http.runWithClient(() async {
    await tester.pumpWidget(const AstroDataApp());
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
    await tester.pump();
  }, () => client);
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('shows the offline view with an explainer when NASA is unreachable', (tester) async {
    await pumpApp(tester, MockClient((_) async => throw http.ClientException('offline')));

    expect(find.text('The sky is out of reach'), findsOneWidget);
    expect(find.text('Reload the sky'), findsWidgets);
    expect(find.text('Two zodiacs, one sky'), findsOneWidget);
    // No placeholder sign glyphs pretending to be data.
    expect(find.text('☀️ Sun'), findsNothing);
  });

  testWidgets('shows the offline view when NASA returns a server error', (tester) async {
    await pumpApp(tester, MockClient((_) async => http.Response('Service Unavailable', 503)));
    expect(find.text('The sky is out of reach'), findsOneWidget);
  });

  testWidgets('Reload the sky recovers once NASA is back', (tester) async {
    var online = false;
    final client = MockClient((request) async {
      if (!online) throw http.ClientException('offline');
      final isMoon = request.url.queryParameters['COMMAND'] == '301';
      // Sun at 0° and Moon at 180° tropical: a full moon.
      return http.Response(jplVectorResponse(x: isMoon ? -1e5 : 1e8, y: 0), 200);
    });

    await pumpApp(tester, client);
    expect(find.text('The sky is out of reach'), findsOneWidget);

    online = true;
    await http.runWithClient(() async {
      await tester.tap(find.text('Reload the sky').first);
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
      await tester.pump();
    }, () => client);

    expect(find.text('The sky is out of reach'), findsNothing);
    expect(find.text('☀️ Sun'), findsOneWidget);
    expect(find.textContaining('Full Moon', findRichText: true), findsOneWidget);
    expect(find.text('What is sidereal?'), findsOneWidget);
  });

  testWidgets('"What is sidereal?" opens the explainer', (tester) async {
    final client = MockClient((request) async {
      final isMoon = request.url.queryParameters['COMMAND'] == '301';
      return http.Response(jplVectorResponse(x: isMoon ? -1e5 : 1e8, y: 0), 200);
    });
    await pumpApp(tester, client);

    await tester.ensureVisible(find.text('What is sidereal?'));
    await tester.tap(find.text('What is sidereal?'));
    await tester.pumpAndSettle();
    expect(find.text('The wobble that moved the stars'), findsOneWidget);
  });
}
