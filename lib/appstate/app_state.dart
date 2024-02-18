import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:will_willnot/extensions/date_extensions.dart';
import '../models/task.dart';

enum TypeOfTask { willDo, willNotDo }
enum uimode { dark, light }

class AppState extends ChangeNotifier {
  var willDosMasterList = <Task>[];
  var willNotDosMasterList = <Task>[];
  var uiMode = uimode.light;

  AppState() {
    loadTasksFromFile();
    var brightness =
    SchedulerBinding.instance.platformDispatcher.platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;
    uiMode = isDarkMode ? uimode.dark : uimode.light;
    
  }

  void toggleUiMode() {
    uiMode = uiMode == uimode.dark ? uimode.light : uimode.dark;
    notifyListeners();
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _willDoLocalFile async {
    final path = await _localPath;
    var file = File('$path/willDo.txt');
    bool fileExists = file.existsSync();

    if (!fileExists) {
      // File does not exist, create it
      file.createSync(
          recursive:
              true); // 'recursive: true' creates the directory path if it doesn't exist
    }
    return file;
  }

  Future<File> get _willNotDoLocalFile async {
    final path = await _localPath;
    var file =  File('$path/willNotDo.txt');
    bool fileExists = file.existsSync();

    if (!fileExists) {
      // File does not exist, create it
      file.createSync(
          recursive:
              true); // 'recursive: true' creates the directory path if it doesn't exist
    }
    return file;

  }

  void writeListToFile(
      Future<File> fileHandler, List<Task> willDosToBeWritten) {
    fileHandler.then((file) {
      file.writeAsStringSync('', mode: FileMode.write);
      for (var i = 0; i < willDosToBeWritten.length; i++) {
        file.writeAsStringSync(
            '${willDosToBeWritten[i].title},${willDosToBeWritten[i].timeStamp},${willDosToBeWritten[i].isDone},${willDosToBeWritten[i].streak}\n',
            mode: FileMode.append);
      }
    });
  }

  void addItem(String title, {TypeOfTask typeOfTask = TypeOfTask.willDo}) {
    if (typeOfTask == TypeOfTask.willDo) {
      willDosMasterList.add(Task(title: title, time: DateTime.now()));
      writeListToFile(_willDoLocalFile, willDosMasterList);
    } else {
      willNotDosMasterList.add(Task(title: title, time: DateTime.now()));
      writeListToFile(_willNotDoLocalFile, willNotDosMasterList);
    }
    notifyListeners();
  }

  void removeItem(int index, {TypeOfTask typeOfTask = TypeOfTask.willDo}) {
    if (typeOfTask == TypeOfTask.willDo) {
      willDosMasterList.removeAt(index);
      writeListToFile(_willDoLocalFile, willDosMasterList);
    } else {
      willNotDosMasterList.removeAt(index);
      writeListToFile(_willNotDoLocalFile, willNotDosMasterList);
    }
    notifyListeners();
  }

  void toggleChecked(int index, BuildContext context, {TypeOfTask typeOfTask = TypeOfTask.willDo}) {
    var itemToBeToggled = typeOfTask == TypeOfTask.willDo
        ? willDosMasterList[index]
        : willNotDosMasterList[index];
    itemToBeToggled.isDone = !itemToBeToggled.isDone;
    if (itemToBeToggled.isDone) {
      itemToBeToggled.streak++;
      itemToBeToggled.timeStamp = DateTime.now().date();
      var message = typeOfTask == TypeOfTask.willDo
          ? 'Great job! Keep it up!'
          : 'It\'s okay, try again not to do it tomorrow!';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 1),
        ),
      );
    } else if (itemToBeToggled.timeStamp == DateTime.now().date()) {
      itemToBeToggled.streak--;
      itemToBeToggled.timeStamp =
          DateTime.now().date().subtract(const Duration(days: 1));
    }
    // Update the local file
    if (typeOfTask == TypeOfTask.willDo) {
      writeListToFile(_willDoLocalFile, willDosMasterList);
    } else {
      writeListToFile(_willNotDoLocalFile, willNotDosMasterList);
    }
    notifyListeners();
  }

  void loadTasksFromFile() {
    _willDoLocalFile.then((file) {
      List<Task> masterCopy = loadContentFromFile(file);
      willDosMasterList = [...masterCopy];
      notifyListeners();
    });
    _willNotDoLocalFile.then((file) {
      List<Task> masterCopy = loadContentFromFile(file);
      willNotDosMasterList = [...masterCopy];
      notifyListeners();
    });
  }

  List<Task> loadContentFromFile(File file) {
    String fileContents = file.readAsStringSync();
    List<String> fileContentsList = fileContents.split('\n');
    var masterCopy = <Task>[];
    for (var i = 0; i < fileContentsList.length; i++) {
      if (fileContentsList[i].isNotEmpty) {
        var taskData = fileContentsList[i].split(',');
        var time = DateTime.parse(taskData[1]);
        var streak = int.parse(taskData[3]);
        var isDone = taskData[2] == 'true' ? true : false;

        if (time.isBefore(
            DateTime.now().date().subtract(const Duration(days: 1)))) {
          streak = 0;
        }

        if (time.isBefore(DateTime.now().date())) {
          isDone = false;
        }

        masterCopy.add(
          Task(title: taskData[0], time: time, isDone: isDone, streak: streak),
        );
      }
    }
    return masterCopy;
  }
}
