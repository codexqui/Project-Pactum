import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_pactum/app/project_pactum_app.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Project Pactum muestra la pantalla de inicio', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const ProviderScope(child: ProjectPactumApp()));
    await tester.pumpAndSettle();

    expect(find.text('Project Pactum'), findsOneWidget);
    expect(find.text('Control diario'), findsOneWidget);
    expect(find.byIcon(Icons.home), findsOneWidget);
  });
}
