// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:sample_flutter_app/main.dart';
import 'package:sample_flutter_app/services/version_update_service.dart';

void main() {
  setUp(() {
    PackageInfo.setMockInitialValues(
      appName: 'sample_flutter_app',
      packageName: 'sample_flutter_app',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
  });

  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    final releaseService = VersionUpdateService(
      client: MockClient(
        (_) async => http.Response(
          '{"tag_name":"v1.0.0"}',
          200,
          headers: {'content-type': 'application/json'},
        ),
      ),
    );
    await tester.pumpWidget(MyApp(releaseService: releaseService));

    await tester.pumpAndSettle();
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);
    expect(find.text('Version 1.0.0'), findsOneWidget);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('shows a badge when a newer release is available', (
    WidgetTester tester,
  ) async {
    final releaseService = VersionUpdateService(
      client: MockClient(
        (_) async => http.Response('{"tag_name":"v1.1.0"}', 200),
      ),
    );

    await tester.pumpWidget(MyApp(releaseService: releaseService));
    await tester.pumpAndSettle();

    expect(find.text('Nouvelle version disponible v1.1.0'), findsOneWidget);
    expect(find.text('Voir la release GitHub'), findsOneWidget);
  });
}
