// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:hsavings/main.dart';
import 'package:hsavings/src/screens/financial_plan_screen.dart';

void main() {
  testWidgets('Home screen loads', (WidgetTester tester) async {
    await tester.pumpWidget(const HSavingsApp());

    expect(find.text('Olá, Gabriel 👋'), findsOneWidget);
    expect(find.text('Saldo total'), findsOneWidget);
    expect(find.text('Visão geral'), findsOneWidget);
  });

  testWidgets('Financial plan screen opens from Plano navigation', (WidgetTester tester) async {
    await tester.pumpWidget(const HSavingsApp());

    await tester.tap(find.text('Plano'));
    await tester.pumpAndSettle();

    expect(find.byType(FinancialPlanScreen), findsOneWidget);
    expect(find.text('Plano financeiro'), findsOneWidget);
  });
}
