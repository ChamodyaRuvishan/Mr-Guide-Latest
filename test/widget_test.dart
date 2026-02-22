import 'package:flutter_test/flutter_test.dart';
import 'package:mr_guide/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MrGuideApp());
    expect(find.text('Mr. Guide'), findsWidgets);
  });
}
