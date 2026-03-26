import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neo_cord_v2/main.dart';

void main() {
  testWidgets('App initialization smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: NeoCardApp()));

    // Verify that the initial text is displayed.
    // GoRouter is asynchronous but for a direct initialLocation without async redirects it should render immediately.
    await tester.pumpAndSettle();
    expect(find.text('Neo Card Initializing...'), findsOneWidget);
  });
}
