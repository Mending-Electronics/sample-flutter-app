import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pub_semver/pub_semver.dart';

class AppVersion {
  static const tag = String.fromEnvironment(
    'APP_VERSION',
  );
  static const _releaseChannel = String.fromEnvironment(
    'APP_RELEASE_CHANNEL',
    defaultValue: 'released',
  );

  static String get channel => kDebugMode ? 'debug' : _releaseChannel;

  static String get channelLabel => switch (channel) {
    'released' => 'Release stable',
    'pre-release' => 'Pre-release',
    'alpha' => 'Alpha',
    'beta' => 'Beta',
    'rc' => 'Release candidate',
    'development' => 'Développement',
    'debug' => 'Debug',
    _ => channel,
  };
}

class GitHubRelease {
  const GitHubRelease({required this.tagName, required this.version});

  final String tagName;
  final Version version;

  Uri get releaseUri {
    final repository = const String.fromEnvironment(
      'APP_REPOSITORY',
      defaultValue: 'Mending-Electronics/sample-flutter-app',
    );
    return Uri.parse(
      'https://github.com/$repository/releases/tag/${Uri.encodeComponent(tagName)}',
    );
  }
}

class VersionUpdateService {
  const VersionUpdateService({this.client});

  final http.Client? client;

  Future<GitHubRelease?> checkForUpdate({
    required String currentVersion,
  }) async {
    const repository = String.fromEnvironment(
      'APP_REPOSITORY',
      defaultValue: 'Mending-Electronics/sample-flutter-app',
    );
    final uri = Uri.https(
      'api.github.com',
      '/repos/$repository/releases/latest',
    );
    final response = await (client?.get ?? http.get)(
      uri,
      headers: const {
        'Accept': 'application/vnd.github+json',
        'User-Agent': 'sample_flutter_app',
        'X-GitHub-Api-Version': '2022-11-28',
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('GitHub returned HTTP ${response.statusCode}.');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic> || decoded['tag_name'] is! String) {
      throw const FormatException('GitHub returned an invalid release.');
    }

    final tagName = decoded['tag_name'] as String;
    final latestVersion = _parseTag(tagName);
    final installedVersion = _parseTag(currentVersion);
    if (latestVersion <= installedVersion) {
      return null;
    }

    return GitHubRelease(tagName: tagName, version: latestVersion);
  }

  Version _parseTag(String tag) {
    final normalizedTag = tag.startsWith('v') ? tag.substring(1) : tag;
    return Version.parse(normalizedTag);
  }
}
