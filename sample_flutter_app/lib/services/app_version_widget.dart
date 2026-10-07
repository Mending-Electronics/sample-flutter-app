import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sample_flutter_app/services/version_update_service.dart';
import 'package:url_launcher/url_launcher.dart';

class AppVersionWidget extends StatefulWidget {
  const AppVersionWidget({
    super.key,
    this.releaseService = const VersionUpdateService(),
  });

  final VersionUpdateService releaseService;

  @override
  State<AppVersionWidget> createState() => _AppVersionWidgetState();
}

class _AppVersionWidgetState extends State<AppVersionWidget> {
  bool _checking = true;
  Exception? _error;
  GitHubRelease? _release;
  String? _version;

  @override
  void initState() {
    super.initState();
    _checkForUpdate();
  }

  Future<void> _checkForUpdate({bool retry = false}) async {
    if (retry) {
      setState(() {
        _checking = true;
        _error = null;
      });
    }

    try {
      final version = AppVersion.tag.isNotEmpty
          ? AppVersion.tag
          : (await PackageInfo.fromPlatform()).version;
      final release = await widget.releaseService.checkForUpdate(
        currentVersion: version,
      );
      if (!mounted) return;
      setState(() {
        _version = version;
        _release = release;
        _checking = false;
      });
    } on Exception catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _checking = false;
      });
    }
  }

  Future<void> _openRelease(Uri uri) async {
    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened && mounted) {
        _showOpenError();
      }
    } on PlatformException {
      if (mounted) {
        _showOpenError();
      }
    }
  }

  void _showOpenError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Impossible d’ouvrir la page GitHub.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_version case final version?)
              Text(
                'Version $version',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            Text(AppVersion.channelLabel),
            if (_checking) ...[
              const SizedBox(height: 12),
              const LinearProgressIndicator(),
              const SizedBox(height: 8),
              const Text('Recherche de mise à jour…'),
            ] else if (_error case final error?) ...[
              const SizedBox(height: 8),
              Text(
                'Vérification impossible : $error',
                style: TextStyle(color: colors.error),
              ),
              TextButton(
                onPressed: () => _checkForUpdate(retry: true),
                child: const Text('Réessayer'),
              ),
            ] else if (_release case final release?) ...[
              const SizedBox(height: 12),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nouvelle version disponible ${release.tagName}',
                        style: TextStyle(
                          color: colors.onSecondaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => _openRelease(release.releaseUri),
                        icon: const Icon(Icons.open_in_new),
                        label: const Text('Voir la release GitHub'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
