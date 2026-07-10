import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:budgettrip_ai/main.dart';
import 'package:budgettrip_ai/services/ai_config_store.dart';
import 'package:budgettrip_ai/services/api_service.dart';

void main() {
  testWidgets('Met U starts on login screen', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      BudgetTripApp(
        api: ApiService(baseUrl: 'https://api.budgettrip.example.com'),
        prefs: prefs,
        aiConfig: AiConfigStore(),
      ),
    );

    expect(find.text('Met U'), findsOneWidget);
    expect(find.text('이메일로 시작하기'), findsOneWidget);
  });
}
