import 'package:calibrefit/app/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App smoke test — CalibreFitApp renders without crashing', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: CalibreFitApp()));
    // GoRouter renders asynchronously; pumpAndSettle lets it finish.
    await tester.pumpAndSettle();

    // The splash page should display the app name.
    expect(find.text('CalibreFit'), findsWidgets);
  });
}
