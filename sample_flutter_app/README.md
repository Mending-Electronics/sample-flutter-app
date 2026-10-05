# sample_flutter_app

Sample Flutter application for Android, Linux and Windows

## Configuration du projet

Ce projet Flutter a été créé pour le développement cross-platform sur Fedora Workstation 44.

### Plateformes configurées

- **Android**: Compilation APK via Gradle + Android SDK
- **Linux**: Compilation native via GCC
- **Web**: Compilation JavaScript via dart2js (compatible Microsoft Edge)
- **Windows**: Compilation à exécuter dans une VM Windows configurée avec Visual Studio Build Tools

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
