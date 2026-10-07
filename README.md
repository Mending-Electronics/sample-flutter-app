# Sample Flutter App - Complete GitHub Actions CI/CD Demo

A demo Flutter project showcasing a complete GitHub Actions CI/CD workflow.

This repository demonstrates how to automatically:

- ✅ Run unit tests
- ✅ Enforce code quality and static analysis
- ✅ Perform SonarQube Cloud analysis
- ✅ Build Flutter applications for all supported platforms
- ✅ Generate downloadable build artifacts
- ✅ Publish GitHub Releases automatically on version tags

---



## Code Base
![Dart](https://img.shields.io/badge/Dart-0175C2?logo=dart&logoColor=white)
![Flutter](https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white)

## Workflow CI/CD

[![GitHub Actions](https://gitlegacy.co/api/badge/shield?name=GitHub%20Actions&color=2088FF&style=for-the-badge&logo=githubactions&logoColor=white)](https://gitlegacy.co/tools/github-badges)

---

## Automatic Build For



### Desktop

![Windows](https://img.shields.io/badge/Windows-0078D6?logo=windows&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-FCC624?logo=linux&logoColor=black)
![macOS](https://img.shields.io/badge/macOS-000000?logo=apple&logoColor=white)

### Mobile

![Android Phone](https://img.shields.io/badge/Android_Phone-3DDC84?logo=android&logoColor=white)
![Android Tablet](https://img.shields.io/badge/Android_Tablet-3DDC84?logo=android&logoColor=white)
![Android TV](https://img.shields.io/badge/Android_TV-3DDC84?logo=android&logoColor=white)
![Wear OS](https://img.shields.io/badge/Wear_OS-3DDC84?logo=wearos&logoColor=white)
![iOS](https://img.shields.io/badge/iOS-000000?logo=apple&logoColor=white)

### Web

![Web](https://img.shields.io/badge/Web-4285F4?logo=googlechrome&logoColor=white)

---

## Workflow Features

### 1. Automated Testing

Every push and pull request automatically triggers:

- Flutter dependency restoration
- Unit tests execution
- Build validation

```bash
flutter test
```

---

### 2. Code Quality Analysis

Optional SonarQube Cloud integration provides:

- Code smells detection
- Maintainability metrics
- Technical debt tracking
- Security hotspot analysis
- Coverage integration

Required repository variables:

```text
SONAR_ORGANIZATION
SONAR_PROJECT_KEY
```

Required repository secret:

```text
SONAR_TOKEN
```

---

### 3. Multi-Platform Builds

The workflow automatically builds release artifacts for:

| Platform | Runner |
|-----------|-----------|
| Android APK | Ubuntu |
| Linux | Ubuntu |
| Windows | Windows |
| macOS | macOS |
| iOS (No Code Sign) | macOS |
| Web | Ubuntu |

Generated artifacts are stored using GitHub Artifacts and kept for 7 days.

---

### 4. Automated Release Creation

When a tag matching:

```text
v*
```

is pushed, GitHub Actions automatically:

1. Downloads all build artifacts
2. Compresses artifacts as ZIP archives
3. Creates a GitHub Release
4. Uploads all generated packages

Pushing a new SemVer version in `sample_flutter_app/pubspec.yaml` to `main`
also creates the matching `vX.Y.Z` tag and publishes the release in that same
workflow run. Only the SemVer portion is used; changing only the `+build`
number does not create another release. The tag is created after successful
tests and builds, and the release job requires `contents: write` permission.

To release by changing the manifest:

```bash
# Set version: 1.1.0+1 in sample_flutter_app/pubspec.yaml
git add sample_flutter_app/pubspec.yaml
git commit -m "Release v1.1.0"
git push origin main
```

You can also continue to create and push a `v*` tag manually; that tag still
triggers the release workflow:

```bash
git tag v1.1.0
git push origin v1.1.0
```

Result:

- Release v1.1.0 created automatically
- All compiled binaries attached to the release page, with archives named
  `flutter-<platform>-v1.1.0.zip`
- The application reports `v1.1.0` as its version and checks for a newer stable release

Use `vX.Y.Z` for stable releases and suffixes such as `vX.Y.Z-beta.1`,
`vX.Y.Z-alpha.1`, or `vX.Y.Z-rc.1` for prereleases. The release workflow marks
hyphenated tags as prereleases.

The Flutter `pubspec.yaml` version is the canonical local version and is read
from the platform metadata. Tagged GitHub builds inject the tag as the displayed
app version, use its numeric SemVer portion for the native app version, and
derive the displayed release channel from the tag. Debug runs identify
themselves as `Debug`.

The app checks GitHub's public latest-release API on startup. It only announces
a newer stable release; when one is available, its badge links to that release's
tag page. This check needs no GitHub token.

---

## Workflow Overview

```text
Push / Pull Request
          │
          ▼
      Test Job
          │
          ▼
   Build Matrix Job
          │
          ├──────── Android APK
          ├──────── Linux
          ├──────── Windows
          ├──────── macOS
          ├──────── iOS
          └──────── Web
          │
          ▼
   SonarQube Analysis
          │
          ▼
      GitHub Release
      (on version tag)
```

---

## GitHub Actions Workflow

Workflow file:

```text
.github/workflows/flutter-build.yml
```

Main triggers:

```yaml
on:
  push:
    branches:
      - main
    tags:
      - "v*"

  pull_request:

  workflow_dispatch:
```

---

## Repository Goal

The purpose of this repository is to provide a simple and reusable reference implementation for Flutter developers who want to:

- Learn GitHub Actions
- Set up CI/CD quickly
- Produce builds for every Flutter platform
- Integrate SonarQube Cloud
- Automate releases
- Publish release artifacts with zero manual intervention

---

## License

MIT License
