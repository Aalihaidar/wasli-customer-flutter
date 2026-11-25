import 'package:flutter/widgets.dart';
import 'package:wasli_customer/core/format/western_digits.dart';
import 'package:wasli_customer/core/l10n/app_locales.dart';
import 'package:wasli_customer/core/l10n/bidi_isolate.dart';

final RegExp _whitespace = RegExp(r'\s+');

/// A car plate as the customer typed it, cleaned for checking and sending: trimmed, runs of spaces collapsed to one,
/// Arabic-Indic digits turned into Western ones and Latin letters in upper case. Arabic letters are kept as typed.
///
/// The server has the last word on what a plate may contain; this only removes differences that are not the customer's
/// intent.
String normalizePlate(String input) => toWesternDigits(input.trim().replaceAll(_whitespace, ' ')).toUpperCase();

/// The text the customer sees for a plate: [plate] as it is, kept left to right.
///
/// A plate reads left to right in both languages, so in Arabic it is wrapped in a left-to-right isolate and cannot be
/// reordered by the right-to-left text around it.
String formatPlate(String plate, {required Locale locale}) =>
    AppLocales.directionOf(locale) == TextDirection.rtl ? isolateLeftToRight(plate) : plate;
