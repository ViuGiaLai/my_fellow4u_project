import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myfellow4u/widgets/custom_text_field.dart';

void main() {
  group('CustomTextField Widget Tests', () {
    testWidgets('should display hint text', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomTextField(hintText: 'Enter email'),
          ),
        ),
      );

      expect(find.text('Enter email'), findsOneWidget);
    });

    testWidgets('should display label text', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomTextField(labelText: 'Email'),
          ),
        ),
      );

      expect(find.text('Email'), findsOneWidget);
    });

    testWidgets('should be editable', (WidgetTester tester) async {
      final controller = TextEditingController();
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(controller: controller),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'test@example.com');
      expect(controller.text, 'test@example.com');
    });

    testWidgets('should respect enabled property', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomTextField(enabled: false),
          ),
        ),
      );

      final textField = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textField.enabled, false);
    });

    testWidgets('should support multiple lines', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomTextField(maxLines: 3),
          ),
        ),
      );

      // Verify the widget renders without error
      expect(find.byType(TextFormField), findsOneWidget);
    });
  });

  group('CustomPasswordField Widget Tests', () {
    testWidgets('should display hint text', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomPasswordField(hintText: 'Enter password'),
          ),
        ),
      );

      expect(find.text('Enter password'), findsOneWidget);
    });

    testWidgets('should have visibility toggle button', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomPasswordField(),
          ),
        ),
      );

      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });

    testWidgets('should toggle visibility on tap', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomPasswordField(),
          ),
        ),
      );

      // Initially hidden
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);

      // Tap toggle button
      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pump();

      // Now visible
      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('should obscure text by default', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomPasswordField(),
          ),
        ),
      );

      // Verify the widget renders with password field
      expect(find.byType(TextFormField), findsOneWidget);
      // Initially should show visibility_off icon (hidden)
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });
  });
}