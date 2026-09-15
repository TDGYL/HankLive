import 'package:flutter_test/flutter_test.dart';
import 'package:hanklive/main.dart';

void main() {
  testWidgets('App renders with bottom nav bar', (WidgetTester tester) async {
    await tester.pumpWidget(const HankLiveApp());

    // 验证底部导航栏4个Tab标题存在
    expect(find.text('比赛'), findsOneWidget);
    expect(find.text('资讯'), findsOneWidget);
    expect(find.text('社区'), findsOneWidget);
    expect(find.text('我的'), findsOneWidget);
  });
}
