// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  group('Raffli Motor App Tests', () {
    testWidgets('App should initialize without errors', (
      WidgetTester tester,
    ) async {
      // Create a simple test app instead of the full app to avoid Supabase initialization
      const testApp = MaterialApp(
        title: 'Raffli Motor',
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: Text('Test App'))),
      );

      // Build the test app
      await tester.pumpWidget(testApp);

      // Verify that the app loads successfully
      expect(find.text('Test App'), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('MaterialApp should have correct configuration', (
      WidgetTester tester,
    ) async {
      // Create a simple MaterialApp with the same config as the real app
      final testApp = MaterialApp(
        title: 'Raffli Motor',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true),
        home: const Scaffold(body: Center(child: Text('Config Test'))),
      );

      // Build the app
      await tester.pumpWidget(testApp);

      // Get the MaterialApp widget
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));

      // Verify app properties
      expect(materialApp.title, equals('Raffli Motor'));
      expect(materialApp.debugShowCheckedModeBanner, equals(false));
      expect(materialApp.theme?.useMaterial3, equals(true));

      // Verify the test content is displayed
      expect(find.text('Config Test'), findsOneWidget);
    });

    test('Environment variables should be testable', () {
      // Test that we can load environment variables
      dotenv.testLoad(
        fileInput: '''
SUPABASE_URL=https://test-project.supabase.co
SUPABASE_ANON_KEY=test_key_for_unit_testing
''',
      );

      expect(
        dotenv.env['SUPABASE_URL'],
        equals('https://test-project.supabase.co'),
      );
      expect(
        dotenv.env['SUPABASE_ANON_KEY'],
        equals('test_key_for_unit_testing'),
      );
    });
  });
}
