import 'package:flutter/material.dart';
import '../appstate/app_state.dart';
import 'package:provider/provider.dart';

class TaskListScreen extends StatefulWidget {
  // Take TypeOfTask as a parameter
  final TypeOfTask typeOfTask;
  TaskListScreen({required this.typeOfTask});

  // Pass the parameter to the state
  @override
  _TaskListScreenState createState() => _TaskListScreenState();

  // Add a method to get the title of the screen
  String get title {
    return typeOfTask == TypeOfTask.willDo ? 'Will Do' : 'Will Not Do';
  }
}

class _TaskListScreenState extends State<TaskListScreen> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    var masterList = widget.typeOfTask == TypeOfTask.willDo
        ? appState.willDosMasterList
        : appState.willNotDosMasterList;
    return Scaffold(
      appBar: AppBar(
        title: Text('Daily ${widget.title}'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showAddItemDialog(context, appState),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: masterList.length,
        itemBuilder: (context, index) {
          final item = masterList[index];
          return ListTile(
            title: Text(item.title),
            leading: Checkbox(
              value: item.isDone,
              onChanged: (bool? value) {
                appState.toggleChecked(index, context, typeOfTask: widget.typeOfTask);
              },
            activeColor: widget.typeOfTask == TypeOfTask.willDo
                ? Colors.green
                : Colors.redAccent,
            ),
            //Show the streak
            subtitle: Text(
              'Streak: ${item.streak}',
              style: TextStyle(color: widget.typeOfTask == TypeOfTask.willDo
                  ? Colors.green
                  : Colors.redAccent),
            ),
            // Trailing icon button to delete the item
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () =>
                  appState.removeItem(index, typeOfTask: widget.typeOfTask),
            ),
          );
        },
      ),
    );
  }

  void _showAddItemDialog(
    BuildContext context,
    AppState appState,
  ) {
    final TextEditingController _textFieldController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add a new "${widget.title}" item'),
          content: TextField(
            controller: _textFieldController,
            decoration: InputDecoration(hintText: "Enter new item here"),
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              child: Text('CANCEL'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('ADD'),
              onPressed: () {
                if (_textFieldController.text.isNotEmpty) {
                  appState.addItem(_textFieldController.text,
                      typeOfTask: widget.typeOfTask);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}
