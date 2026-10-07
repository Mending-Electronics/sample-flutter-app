# sample_flutter_app

Sample Flutter application for Android, Linux and Windows

## Configuration du projet

Ce projet Flutter a été créé pour le développement cross-platform sur Fedora Workstation 44.

### Plateformes configurées

- **Android**: Compilation APK via Gradle + Android SDK
- **Linux**: Compilation native via GCC
- **Web**: Compilation JavaScript via dart2js (compatible Microsoft Edge)
- **Windows**: Compilation à exécuter dans une VM Windows configurée avec Visual Studio Build Tools
- **macOS**: Compilation via GitHub Actions sur un runner macOS
- **iOS**: Compilation via GitHub Actions sur un runner macOS, sans signature

Le workflow GitHub Actions compile Android, Linux, Windows, macOS, iOS et Web.
Lorsqu'une nouvelle version SemVer de `pubspec.yaml` est poussée sur `main`, le
workflow crée le tag `vX.Y.Z` après la réussite des tests et des builds, puis publie
la release et les archives des six builds dans la même exécution. Seule la partie
SemVer est utilisée : modifier uniquement le numéro `+build` ne crée pas de nouvelle
release. Les tags `v*` poussés manuellement continuent également à déclencher une
release. Le build iOS est non signé; la signature et la distribution sur appareil
nécessitent un certificat et un profil de provisioning Apple.

Pour publier en modifiant le manifeste, mettez par exemple `version: 1.2.0+1` dans
`pubspec.yaml`, puis committez et poussez sur `main`. Le job de publication crée le
tag et la release avec la permission `contents: write`.

`pubspec.yaml` est la source canonique de la version locale, lue depuis les
métadonnées de la plateforme. Les builds CI issus d'un tag SemVer injectent le tag
complet dans l'application, utilisent sa partie numérique comme version native
et affichent son canal (`released`, `beta`, `alpha`, `rc` ou `pre-release`). Un
build exécuté en mode debug affiche `Debug`. Les archives de release portent le
tag en suffixe, par exemple `flutter-apk-v1.2.0.zip`. Les tags avec suffixe
(`v1.2.0-beta.1`) sont publiés en tant que prereleases.

Au démarrage, l'application interroge l'API publique GitHub pour rechercher une
release stable plus récente. Si elle existe, un badge donne accès à sa page de tag.
Les plateformes Android et macOS autorisent explicitement l'accès réseau sortant.
Une vérification qui échoue est signalée dans l'interface et peut être relancée.

Pour activer l'analyse SonarQube Cloud, définir les variables de dépôt
`SONAR_ORGANIZATION` et `SONAR_PROJECT_KEY`, ainsi que le secret `SONAR_TOKEN`.
Le job est ignoré tant que les deux variables ne sont pas définies; le secret est
également nécessaire pour que l'analyse réussisse.

### Scripts de test

Utilisez les scripts suivants pour tester chaque plateforme:

- ./flutter_test_droid.ps1 - Test de compilation Android
- ./flutter_test_linux.ps1 - Test de compilation Linux
- ./flutter_test_web.ps1 - Test de compilation Web
- ./flutter_test_win.ps1 - Test de compilation Windows
- ./flutter_test_exe.ps1 - Test d'exécution EXE via winBridge

### Développement

Pour démarrer le développement:

\\\ash
cd sample_flutter_app
flutter pub get
flutter run -d linux    # Pour Linux
flutter run -d chrome   # Pour Web
flutter run -d android  # Pour Android (émulateur ou appareil)
\\\

### Build

Pour compiler le projet:

\\\ash
flutter build apk          # Android APK
flutter build linux        # Linux executable
flutter build web          # Web application
# Depuis Windows, avec Visual Studio Build Tools installés :
flutter build windows
\\\

---

Généré automatiquement par flutter_init_projet.ps1
Date: 2026-10-05 23:38:49
