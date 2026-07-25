import 'package:flutter_test/flutter_test.dart';
import 'package:frotas_helper/main.dart';

void main() {
  testWidgets('Frotas Helper abre o dashboard', (tester) async {
    await tester.pumpWidget(const FrotasHelperApp());
    await tester.pumpAndSettle();

    expect(find.text('Frotas Helper'), findsOneWidget);
    expect(find.text('Controle da sua frota'), findsOneWidget);
  });
}