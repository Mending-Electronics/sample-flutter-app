import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sample_flutter_app/services/version_update_service.dart';

void main() {
  test('returns a newer stable release and its tag page', () async {
    final service = VersionUpdateService(
      client: MockClient((request) async {
        expect(
          request.url.toString(),
          'https://api.github.com/repos/Mending-Electronics/sample-flutter-app/releases/latest',
        );
        return http.Response('{"tag_name":"v1.1.0"}', 200);
      }),
    );

    final release = await service.checkForUpdate(currentVersion: '1.0.0');

    expect(release?.tagName, 'v1.1.0');
    expect(release?.version.toString(), '1.1.0');
    expect(
      release?.releaseUri.toString(),
      'https://github.com/Mending-Electronics/sample-flutter-app/releases/tag/v1.1.0',
    );
  });

  test('does not offer the current version again', () async {
    final service = VersionUpdateService(
      client: MockClient(
        (_) async => http.Response('{"tag_name":"v1.0.0"}', 200),
      ),
    );

    expect(await service.checkForUpdate(currentVersion: '1.0.0'), isNull);
  });

  test('reports an unsuccessful GitHub response', () async {
    final service = VersionUpdateService(
      client: MockClient((_) async => http.Response('Not found', 404)),
    );

    expect(service.checkForUpdate(currentVersion: '1.0.0'), throwsException);
  });
}
