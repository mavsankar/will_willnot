extension DateExtension on DateTime {
  DateTime date(){
    return DateTime(this.year, this.month, this.day);
  }
}