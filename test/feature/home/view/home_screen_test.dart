import 'package:flutter_starter/src/core/constant/constant.dart';
import 'package:flutter_starter/src/feature/home/view/home_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/helpers.dart';

void main() {
  group('HomeScreen', () {
    testWidgets('рендерится без ошибок', (tester) async {
      await tester.pumpApp(const HomeScreen());

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text(Config.appName), findsOneWidget);
    });
  });
}
