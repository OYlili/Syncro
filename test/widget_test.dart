import 'package:flutter_test/flutter_test.dart';
import 'package:syncro/main.dart';

void main() {
  testWidgets('App loads correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const SyncroApp());
    await tester.pumpAndSettle();
    
    expect(find.text('房间'), findsOneWidget);
    expect(find.text('我的'), findsOneWidget);
    expect(find.text('设置'), findsOneWidget);
  });
}
