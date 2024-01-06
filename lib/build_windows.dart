import 'dart:io';

import 'package:innosetup/innosetup.dart';
import 'package:version/version.dart';

void main() {
  InnoSetup(
    name: const InnoSetupName(
      'Banano Keeper Installer',
    ),
    app: InnoSetupApp(
      name: 'Banano Keeper',
      version: Version.parse('0.9.5.2'),
      publisher: 'Somoon',
      urls: InnoSetupAppUrls(
        homeUrl: Uri.parse('https://moonano.net'),
        publisherUrl: Uri.parse('https://moonano.net'),
        supportUrl: Uri.parse('https://moonano.net'),
// updatesUrl: Uri.parse('https://moonano.net'),
      ),
    ),
    files: InnoSetupFiles(
      executable: File('build/windows/runner/Release/bananokeeper.exe'),
      location: Directory('build/windows/runner/Release'),
    ),
    location: InnoSetupInstallerDirectory(
      Directory('build/windows'),
    ),
    icon: InnoSetupIcon(
      File('images/icon.png'),
    ),
    runAfterInstall: false,
    compression: InnoSetupCompressions().lzma2(
      InnoSetupCompressionLevel.ultra64,
    ),
    // languages: InnoSetupLanguage('armenian'),
    // languages: InnoSetupLanguages().all,
    // license: InnoSetupLicense(
    //   File('LICENSE'),
    // ),
  ).make();
}
