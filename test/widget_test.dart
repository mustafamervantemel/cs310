// This is a basic Flutter widget test.

import 'package:flutter_test/flutter_test.dart';
import 'package:cs310sunote/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const SuNoteApp());
    
    // Verify app loads (basic smoke test)
    expect(find.text('SuNote'), findsOneWidget);
  });
}
