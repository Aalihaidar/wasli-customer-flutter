import 'package:flutter/widgets.dart';
import 'package:wasli_customer/core/l10n/app_locales.dart';

/// Dubai is UTC+4 all year with no daylight saving, so a fixed offset is enough and no timezone package is needed.
const Duration dubaiOffset = Duration(hours: 4);

/// The wall-clock time in Dubai for the instant [utc].
///
/// Dart has no value for "a time in another zone", so the result is a UTC-flagged [DateTime] whose fields (`hour`,
/// `day`, ...) are the Dubai ones. It is for reading those fields and displaying them, never for comparing instants.
DateTime toDubaiTime(DateTime utc) => utc.toUtc().add(dubaiOffset);

/// The time of day in Dubai, 24-hour with Western digits, for example `14:05`.
String formatTime(DateTime utc) {
  final dubai = toDubaiTime(utc);
  return '${_two(dubai.hour)}:${_two(dubai.minute)}';
}

/// The date in Dubai with the month written out, for example `25 Nov 2026` and `25 نوفمبر 2026`, Western digits.
String formatDate(DateTime utc, {required Locale locale}) {
  final dubai = toDubaiTime(utc);
  final months = AppLocales.directionOf(locale) == TextDirection.rtl ? _arabicMonths : _englishMonths;
  return '${dubai.day} ${months[dubai.month - 1]} ${dubai.year}';
}

/// The date and the time of day in Dubai, for example `25 Nov 2026, 14:05`.
String formatDateTime(DateTime utc, {required Locale locale}) {
  final separator = AppLocales.directionOf(locale) == TextDirection.rtl ? '،' : ',';
  return '${formatDate(utc, locale: locale)}$separator ${formatTime(utc)}';
}

String _two(int value) => value.toString().padLeft(2, '0');

const List<String> _englishMonths = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

const List<String> _arabicMonths = [
  'يناير',
  'فبراير',
  'مارس',
  'أبريل',
  'مايو',
  'يونيو',
  'يوليو',
  'أغسطس',
  'سبتمبر',
  'أكتوبر',
  'نوفمبر',
  'ديسمبر',
];
