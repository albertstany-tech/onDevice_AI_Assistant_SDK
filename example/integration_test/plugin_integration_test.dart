import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:on_device_ai/on_device_ai.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('plugin initializes properly', (WidgetTester tester) async {
    final OnDeviceAi plugin = OnDeviceAi();
    expect(plugin, isNotNull);
  });
}
