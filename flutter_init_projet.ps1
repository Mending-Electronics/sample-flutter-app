#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Script d'initialisation d'un projet Flutter de base
.DESCRIPTION
    Ce script crée un projet Flutter de base nommé "test" dans le dossier courant
    avec une configuration par défaut pour le développement cross-platform.
.NOTES
    Auteur: Alexandre JALLET
    Date: 2026-09-28
    Version: 1.0
    Requiert: PowerShell Core 7+
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$ProjectName = "test",
    
    [Parameter(Mandatory=$false)]
    [string]$Description = "Projet Flutter de test pour développement cross-platform",
    
    [Parameter(Mandatory=$false)]
    [string]$Org = "com.example"
)

# Configuration globale
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

# Variables globales
$ScriptPath = $PSScriptRoot
$LogsDir = Join-Path $ScriptPath "logs"
$LogFile = Join-Path $LogsDir "flutter_init_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
$ProjectDir = Join-Path (Get-Location).Path $ProjectName

# Fonction de logging avec support des caractères spéciaux
function Write-Log {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,
        
        [Parameter(Mandatory=$false)]
        [ValidateSet("INFO", "WARNING", "ERROR", "SUCCESS")]
        [string]$Level = "INFO",
        
        [Parameter(Mandatory=$false)]
        [switch]$NoConsole
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    [System.IO.File]::AppendAllText($LogFile, $logMessage + "`n", [System.Text.Encoding]::UTF8)
    
    if (-not $NoConsole) {
        $color = switch ($Level) {
            "INFO"    { "Cyan" }
            "WARNING" { "Yellow" }
            "ERROR"   { "Red" }
            "SUCCESS" { "Green" }
            default   { "White" }
        }
        Write-Host $logMessage -ForegroundColor $color
    }
}

# Fonction d'initialisation des logs
function Initialize-Logging {
    try {
        if (-not (Test-Path $LogsDir)) {
            New-Item -ItemType Directory -Path $LogsDir -Force | Out-Null
        }
        Write-Log "=== DÉBUT DU LOG FLUTTER INIT PROJET ===" -Level "INFO"
        Write-Log "Nom du projet: $ProjectName" -Level "INFO"
        Write-Log "Description: $Description" -Level "INFO"
        Write-Log "Organisation: $Org" -Level "INFO"
        Write-Log "Dossier de création: $ScriptPath" -Level "INFO"
    }
    catch {
        Write-Host "Erreur lors de l'initialisation des logs: $_" -ForegroundColor Red
        exit 1
    }
}

# Fonction de vérification de Flutter
function Test-FlutterInstallation {
    Write-Log "Vérification de l'installation Flutter..." -Level "INFO"
    
    try {
        $flutterCmd = Get-Command flutter -ErrorAction SilentlyContinue
        if (-not $flutterCmd) {
            Write-Log "Flutter n'est pas installé ou n'est pas dans le PATH" -Level "ERROR"
            Write-Log "Exécutez d'abord ./flutter_setup.ps1" -Level "INFO"
            return $false
        }
        
        $version = & flutter --version 2>&1
        Write-Log "Flutter installé: $version" -Level "SUCCESS"
        return $true
    }
    catch {
        Write-Log "Erreur lors de la vérification de Flutter: $_" -Level "ERROR"
        return $false
    }
}

# Fonction de vérification du dossier de projet
function Test-ProjectDirectory {
    Write-Log "Vérification du dossier de projet..." -Level "INFO"
    
    if (Test-Path $ProjectDir) {
        Write-Log "Le dossier '$ProjectName' existe déjà" -Level "ERROR"
        Write-Log "Veuillez supprimer ou renommer le dossier existant" -Level "INFO"
        return $false
    }
    
    Write-Log "Dossier disponible pour la création" -Level "SUCCESS"
    return $true
}

# Fonction de création du projet Flutter
function New-FlutterProject {
    Write-Log "Création du projet Flutter..." -Level "INFO"
    
    try {
        $arguments = @(
            "create",
            "--project-name", $ProjectName,
            "--org", $Org,
            "--description", $Description,
            "--platforms", "android,linux,web,windows",
            $ProjectName
        )
        
        Write-Log "Exécution: flutter $($arguments -join ' ')" -Level "INFO"
        & flutter @arguments 2>&1 | Tee-Object -FilePath $LogFile -Append | Out-Null
        
        if ($LASTEXITCODE -eq 0) {
            Write-Log "Projet Flutter créé avec succès" -Level "SUCCESS"
            return $true
        }
        else {
            Write-Log "Erreur lors de la création du projet Flutter" -Level "ERROR"
            return $false
        }
    }
    catch {
        Write-Log "Erreur lors de la création du projet: $_" -Level "ERROR"
        return $false
    }
}

# Fonction de configuration du projet
function Set-ProjectConfiguration {
    Write-Log "Configuration du projet..." -Level "INFO"
    
    try {
        # Modification du pubspec.yaml pour ajouter des dépendances utiles
        $pubspecPath = Join-Path $ProjectDir "pubspec.yaml"
        
        if (Test-Path $pubspecPath) {
            Write-Log "Modification de pubspec.yaml..." -Level "INFO"
            
            $pubspecContent = Get-Content $pubspecPath -Raw
            
            # Ajout de dépendances de développement
            $devDependenciesSection = @"

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
"@
            
            if ($pubspecContent -notmatch "dev_dependencies:") {
                $pubspecContent = $pubspecContent + $devDependenciesSection
                Set-Content -Path $pubspecPath -Value $pubspecContent -Encoding UTF8
                Write-Log "Dépendances de développement ajoutées" -Level "SUCCESS"
            }
        }
        
        # Création d'un fichier README personnalisé
        $readmePath = Join-Path $ProjectDir "README.md"
        $readmeContent = @"
# $ProjectName

$Description

## Configuration du projet

Ce projet Flutter a été créé pour le développement cross-platform sur Fedora Workstation 44.

### Plateformes configurées

- **Android**: Compilation APK via Gradle + Android SDK
- **Linux**: Compilation native via GCC
- **Web**: Compilation JavaScript via dart2js (compatible Microsoft Edge)
- **Windows**: Compilation à exécuter dans une VM Windows configurée avec Visual Studio Build Tools

### Scripts de test

Utilisez les scripts suivants pour tester chaque plateforme:

- `./flutter_test_droid.ps1` - Test de compilation Android
- `./flutter_test_linux.ps1` - Test de compilation Linux
- `./flutter_test_web.ps1` - Test de compilation Web
- `./flutter_test_win.ps1` - Test de compilation Windows
- `./flutter_test_exe.ps1` - Test d'exécution EXE via winBridge

### Développement

Pour démarrer le développement:

\`\`\`bash
cd $ProjectName
flutter pub get
flutter run -d linux    # Pour Linux
flutter run -d chrome   # Pour Web
flutter run -d android  # Pour Android (émulateur ou appareil)
\`\`\`

### Build

Pour compiler le projet:

\`\`\`bash
flutter build apk          # Android APK
flutter build linux        # Linux executable
flutter build web          # Web application
# Depuis Windows, avec Visual Studio Build Tools installés :
flutter build windows
\`\`\`

---

Généré automatiquement par flutter_init_projet.ps1
Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
"@
        
        Set-Content -Path $readmePath -Value $readmeContent -Encoding UTF8
        Write-Log "README.md personnalisé créé" -Level "SUCCESS"
        
        # Création d'un fichier .gitignore personnalisé
        $gitignorePath = Join-Path $ProjectDir ".gitignore"
        $gitignoreContent = @"
# Fichiers générés par Flutter
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.packages
.pub-cache/
.pub/
build/

# Fichiers de logs
logs/
*.log

# IDE
.idea/
.vscode/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db

# winBridge
winbridge/
*.iso
*.qcow2
"@
        
        Set-Content -Path $gitignorePath -Value $gitignoreContent -Encoding UTF8
        Write-Log ".gitignore personnalisé créé" -Level "SUCCESS"
        
        return $true
    }
    catch {
        Write-Log "Erreur lors de la configuration du projet: $_" -Level "ERROR"
        return $false
    }
}

# Fonction de récupération des dépendances
function Update-FlutterDependencies {
    Write-Log "Récupération des dépendances Flutter..." -Level "INFO"
    
    try {
        Push-Location $ProjectDir
        & flutter pub get 2>&1 | Tee-Object -FilePath $LogFile -Append | Out-Null
        Pop-Location
        
        if ($LASTEXITCODE -eq 0) {
            Write-Log "Dépendances récupérées avec succès" -Level "SUCCESS"
            return $true
        }
        else {
            Write-Log "Erreur lors de la récupération des dépendances" -Level "ERROR"
            return $false
        }
    }
    catch {
        Write-Log "Erreur lors de la récupération des dépendances: $_" -Level "ERROR"
        return $false
    }
}

# Fonction de vérification finale
function Test-ProjectSetup {
    Write-Log "Vérification finale du projet..." -Level "INFO"
    
    $requiredFiles = @(
        "pubspec.yaml",
        "lib/main.dart",
        "README.md",
        ".gitignore"
    )
    
    $allFilesPresent = $true
    
    foreach ($file in $requiredFiles) {
        $filePath = Join-Path $ProjectDir $file
        if (Test-Path $filePath) {
            Write-Log "✓ $file présent" -Level "SUCCESS"
        }
        else {
            Write-Log "✗ $file manquant" -Level "ERROR"
            $allFilesPresent = $false
        }
    }
    
    return $allFilesPresent
}

# Fonction de rapport final
function Show-FinalReport {
    Write-Log "`n========================================" -Level "INFO"
    Write-Log "=== RAPPORT DE CRÉATION DE PROJET ===" -Level "INFO"
    Write-Log "========================================" -Level "INFO"
    Write-Log "Projet: $ProjectName" -Level "INFO"
    Write-Log "Emplacement: $ProjectDir" -Level "INFO"
    Write-Log "========================================" -Level "INFO"
    
    Write-Log "`nProchaines étapes:" -Level "INFO"
    Write-Log "1. cd $ProjectName" -Level "INFO"
    Write-Log "2. flutter pub get" -Level "INFO"
    Write-Log "3. flutter run -d <plateforme>" -Level "INFO"
    Write-Log "`nPour tester les compilations, utilisez les scripts flutter_test_*.ps1" -Level "INFO"
}

# Point d'entrée principal
function Main {
    try {
        Initialize-Logging
        
        Write-Log "Début de l'initialisation du projet Flutter..." -Level "INFO"
        
        # Vérifications préalables
        if (-not (Test-FlutterInstallation)) {
            exit 1
        }
        
        if (-not (Test-ProjectDirectory)) {
            exit 1
        }
        
        # Création du projet
        if (-not (New-FlutterProject)) {
            exit 1
        }
        
        # Configuration
        if (-not (Set-ProjectConfiguration)) {
            Write-Log "Erreur lors de la configuration, mais le projet a été créé" -Level "WARNING"
        }
        
        # Dépendances
        if (-not (Update-FlutterDependencies)) {
            Write-Log "Erreur lors de la récupération des dépendances" -Level "WARNING"
        }
        
        # Vérification finale
        if (Test-ProjectSetup) {
            Write-Log "Projet Flutter initialisé avec succès!" -Level "SUCCESS"
            Show-FinalReport
            Write-Log "Logs disponibles dans: $LogsDir" -Level "INFO"
            exit 0
        }
        else {
            Write-Log "Projet créé mais avec des fichiers manquants" -Level "ERROR"
            exit 1
        }
    }
    catch {
        Write-Log "Erreur critique lors de l'initialisation: $_" -Level "ERROR"
        Write-Log "Stack trace: $($_.ScriptStackTrace)" -Level "ERROR"
        exit 1
    }
}

# Exécution
Main
