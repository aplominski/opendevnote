import 'package:flutter/material.dart';
import 'package:opendevnote/l10n/app_localizations.dart';

class S {
  static AppLocalizations of(BuildContext context) {
    return AppLocalizations.of(context)!;
  }

  static AppLocalizations? maybeOf(BuildContext context) {
    return AppLocalizations.of(context);
  }
}
