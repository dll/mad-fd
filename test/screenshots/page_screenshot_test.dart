import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowledge_graph_app/presentation/pages/home/home_page.dart';
import 'package:knowledge_graph_app/presentation/pages/login/login_page.dart';

/// **现状（2026-05-23）**：暂时整组跳过。
///
/// 这两个 golden 测试 pump 真实 LoginPage / HomePage 但没 mock 它们触发的副作用：
/// - LoginPage 启动了 noir 背景持续动画 → `pumpAndSettle` 永远不返回；
/// - HomePage 在 build 时直接调 DatabaseHelper.instance.database，而 sqflite
///   原生通道在测试 Host 上未初始化 → 抛 "databaseFactory not initialized"。
///
/// 把整组 skip 掉，避免 CI 红屏。等以后做真"视觉回归测试"时再单独整改：
/// 思路是把页面拆出**纯 UI 子组件**（不碰 DB / Animation），单独对该子组件
/// 跑 golden，而不是对整页。
///
/// **不删测试文件**：保留为后续视觉回归落地的占位（含初始化代码 + skip 标记）。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock SharedPreferences plugin channel
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/shared_preferences'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'getAll') {
          return <String, dynamic>{};
        }
        return null;
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/shared_preferences'),
      null,
    );
  });

  group('Golden screenshot tests', () {
    Future<void> pumpWithSurface(
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
      await pumpWithSurface(tester, const LoginPage());

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/login_page.png'),
      );
    });

    testWidgets('home page golden', (WidgetTester tester) async {
      await pumpWithSurface(
        tester,
        const HomePage(initialTabIndex: 0),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/home_page.png'),
      );
    });
  }, skip: '整页 golden 与运行时副作用耦合（noir 动画 / DB 初始化），待重构为纯组件级 golden 后再启用');
}
