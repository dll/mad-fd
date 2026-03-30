import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowledge_graph_app/presentation/pages/home/home_page.dart';
import 'package:knowledge_graph_app/presentation/pages/login/login_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Golden screenshot tests', () {
    Future<void> _pumpWithSurface(
      WidgetTester tester,
      Widget child,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1080, 1920));
      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          home: child,
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('login page golden', (WidgetTester tester) async {
      await _pumpWithSurface(tester, const LoginPage());

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/login_page.png'),
      );
    });

    testWidgets('home page golden', (WidgetTester tester) async {
      await _pumpWithSurface(
        tester,
        const HomePage(initialTabIndex: 0),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/home_page.png'),
      );
    });
  });
}
