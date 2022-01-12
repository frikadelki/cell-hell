import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:puffy_playground/src/common/res.dart';

abstract class AboutRes {
  static const text = 'developed by frikadelki';
  static const appIcon = 'assets/about_app_icon.png';

  AboutRes._();
}

void showAboutCellHell(BuildContext context) async {
  _ensureLicensesAdded();
  final info = await PackageInfo.fromPlatform();
  final version = '${info.version} (${info.buildNumber})';
  showAboutDialog(
      context: context,
      applicationName: AppStrings.appName,
      applicationIcon: Image.asset(
        AboutRes.appIcon,
        width: 44.0,
        height: 44.0,
      ),
      applicationVersion: version,
      children: [
        const Text(
          AboutRes.text,
          textAlign: TextAlign.center,
        ),
      ]);
}

var _licensesAdded = false;

void _ensureLicensesAdded() {
  if (_licensesAdded) {
    return;
  }
  _licensesAdded = true;
  LicenseRegistry.addLicense(() => Stream.value(_iconsLicenceEntry));
}

const _iconsLicenceEntry = LicenseEntryWithLineBreaks(
  ['https://game-icons.net/'],
  'Icons provided by good folks at https://game-icons.net/ under CC BY 3.0 \n'
  '\n'
  'This work is licensed under the Creative Commons Attribution 3.0 Unported '
  'License. To view a copy of this license, visit '
  'http://creativecommons.org/licenses/by/3.0/ or send a letter to '
  'Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.',
);
