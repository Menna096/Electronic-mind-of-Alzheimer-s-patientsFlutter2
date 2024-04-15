String convertTime(String minutes) {
  if (minutes.length == 1) {
    return "0$minutes";
  } else {
    return minutes;
  }
}
String convertDate(String date) {
  if (date.length == 1) {
    return "0$date";
  } else {
    return date;
  }
}
