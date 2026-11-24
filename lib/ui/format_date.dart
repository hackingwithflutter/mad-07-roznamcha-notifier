// How the app writes a date on the screen. This function lives in the ui
// folder because it decides how something looks, not what the data is.

const _months = [
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

/// Turns a date into text such as `20 Nov 2026`. `date.month` counts from 1,
/// and a list's indexes count from 0, so the month's name is at `month - 1`.
String formatDate(DateTime date) {
  return '${date.day} ${_months[date.month - 1]} ${date.year}';
}
