import 'package:flutter_test/flutter_test.dart';
import 'package:mr_guide/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App launches smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MrGuideApp());
    await tester.pumpAndSettle();
    expect(find.text('Mr Guide'), findsOneWidget);
  });

  testWidgets('Home screen shows recent searches when saved', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'hasSeenOnboarding': true,
      'recent_searches': ['Anuradhapura', 'Hikkaduwa Beach'],
    });

    await tester.pumpWidget(const MrGuideApp());
    await tester.pumpAndSettle();

    expect(find.text('Recent Searches'), findsOneWidget);
    expect(find.text('Anuradhapura'), findsOneWidget);
    expect(find.text('Hikkaduwa Beach'), findsOneWidget);
  });
}
