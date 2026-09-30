import 'package:flutter_test/flutter_test.dart';
import 'package:student_life/main.dart';

void main() {
  testWidgets('welcome page is visible', (tester) async {
    await tester.pumpWidget(const StudentLifeApp());

    expect(find.text('Student Life Hub'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
  });
}
