import 'package:flutter_test/flutter_test.dart';
import 'package:expidus/expidus.dart';
import 'package:expidus/expidus_platform_interface.dart';
import 'package:expidus/expidus_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockExpidusPlatform
    with MockPlatformInterfaceMixin
    implements ExpidusPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final ExpidusPlatform initialPlatform = ExpidusPlatform.instance;

  test('$MethodChannelExpidus is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelExpidus>());
  });

  test('getPlatformVersion', () async {
    Expidus expidusPlugin = Expidus();
    MockExpidusPlatform fakePlatform = MockExpidusPlatform();
    ExpidusPlatform.instance = fakePlatform;

    expect(await expidusPlugin.getPlatformVersion(), '42');
  });
}
