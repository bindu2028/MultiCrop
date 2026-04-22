import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobile_app/app/app.dart';

void main() {
  testWidgets('App opens auth screen when no session exists', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    await tester.pumpWidget(const PlantLensApp());
    await tester.pumpAndSettle();

    expect(find.text('PlantLens'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}
