import '../extensions/date_extensions.dart';

class Task {
  String title;
  bool isDone=false;
  DateTime timeStamp = DateTime.now().date();
  int streak = 0;

  Task({required this.title, required DateTime time, this.isDone = false, this.streak =0}) {
    timeStamp = time.date();
  }
}
