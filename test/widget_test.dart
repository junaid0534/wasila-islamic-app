import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wasila/main.dart';

void main() {
  testWidgets('Wasila smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: WasilaApp(),
      ),
    );
    expect(find.text('Assalamu Alaikum'), findsOneWidget);
  });
}
