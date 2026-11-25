/// A time left as minutes and seconds with Western digits, for example `0:42` or `10:00`. Less than zero counts as zero.
String formatCountdown(Duration left) {
  final totalSeconds = left.isNegative ? 0 : (left.inMilliseconds + 999) ~/ 1000;
  final minutes = totalSeconds ~/ 60;
  final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}
