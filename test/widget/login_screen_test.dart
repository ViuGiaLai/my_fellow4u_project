import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myfellow4u/screens/login_screen.dart';

void main() {
  group('LoginScreen Widget Tests', () {
    testWidgets('should display Sign In title', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('should display email and password fields', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

      // Find text fields by hint text
      expect(find.byType(TextFormField), findsNWidgets(2));
    });

    testWidgets('should display Sign In button', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

      expect(find.text('SIGN IN'), findsOneWidget);
    });

    testWidgets('should display Forgot Password link', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

      expect(find.text('Forgot Password'), findsOneWidget);
    });

    testWidgets('should display Sign Up link', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

      expect(find.text("Don't have an account? "), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);
    });

    testWidgets('should display social login options', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

      expect(find.text('or sign in with'), findsOneWidget);
    });

    testWidgets('should display Welcome back text', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

      expect(find.text('Welcome back, Yoo Jin'), findsOneWidget);
    });

    testWidgets('should display Email label', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

      expect(find.text('Email'), findsOneWidget);
    });

    testWidgets('should display Password label', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

      expect(find.text('Password'), findsOneWidget);
    });
  });
}