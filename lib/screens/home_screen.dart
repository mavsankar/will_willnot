import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../appstate/app_state.dart';
import '../components/tasks_pie_chart.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    var willDoTasks = appState.willDosMasterList;
    var willNotDoTasks = appState.willNotDosMasterList;

    // Counting done and pending tasks for willDoTasks
    int doneWillDoTasksCount = willDoTasks.where((task) => task.isDone).length;
    int pendingWillDoTasksCount = willDoTasks.length - doneWillDoTasksCount;

    // Counting done and pending tasks for willNotDoTasks
    int doneWillNotDoTasksCount =
        willNotDoTasks.where((task) => !task.isDone).length;
    int pendingWillNotDoTasksCount =
        willNotDoTasks.length - doneWillNotDoTasksCount;

    // Sort tasks based on the streak
    var topWillDoTasks =
        willDoTasks.where((element) => element.streak > 7).toList();
    topWillDoTasks.sort((a, b) => b.streak.compareTo(a.streak));

    // For breaking a habit either the streak should be zero or the timestamp should be older than 7 days
    var topWillNotDoTasks = willNotDoTasks.where((element) => element.timeStamp
        .isBefore(DateTime.now().subtract(const Duration(days: 7))));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Today\'s Overview'),
      ),
      body: SingleChildScrollView(
        // Ensure the page is scrollable for smaller devices
        child: Center(
          child: Padding(
            // Add padding for better layout
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const TextWithToolTip(
                  text: 'Will Do Tasks',
                  tooltipMessage:
                      'These habits should be done daily to form a streak. Try to checkbox these daily.',
                  color: Colors.green,
                ),
                SizedBox(
                  height: 200,
                  width: 200,
                  child: TasksPieChart(
                    doneTasksCount: doneWillDoTasksCount,
                    pendingTasksCount: pendingWillDoTasksCount,
                    doneText: 'Completed',
                    pendingText: 'Pending',
                  ),
                ),
                const SizedBox(
                    height: 30), // Increased for better section separation
                const TextWithToolTip(
                    text: 'Will Not Do Tasks',
                    tooltipMessage:
                        'These habits should have minimal or no streak at all. Avoid checkboxing these.',
                    color: Colors.redAccent),
                SizedBox(
                  height: 200,
                  width: 200,
                  child: TasksPieChart(
                    doneTasksCount: doneWillNotDoTasksCount,
                    pendingTasksCount: pendingWillNotDoTasksCount,
                    doneText: 'Avoided',
                    pendingText: 'Gave In',
                  ),
                ),
                const SizedBox(height: 40), // For final section spacing
                const TextWithToolTip(
                  text: 'Top Habits Being Formed',
                  tooltipMessage: 'Habits with the more than 7 days streak',
                  color: Colors.green,
                ),
                Column(
                  children: topWillDoTasks
                      .map((task) =>
                          Text('${task.title} - Streak: ${task.streak}',
                              style: const TextStyle(
                                fontSize: 18,
                              )))
                      .toList(),
                ),
                SizedBox(height: 30),
                const TextWithToolTip(
                    text: 'Top Habits Being Broken',
                    tooltipMessage: 'Habits avoided for more than 7 days',
                    color: Colors.redAccent),
                Column(
                  children: topWillNotDoTasks
                      .map((task) =>
                          Text('${task.title} - Streak: ${task.streak}',
                              style: const TextStyle(
                                fontSize: 18,
                              )))
                      .toList(),
                ),
                const SizedBox(height: 40),
                // Consider adding graphical representations like pie charts or progress bars here.
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TextWithToolTip extends StatelessWidget {
  final String text;
  final String tooltipMessage;
  final Color color;

  const TextWithToolTip(
      {super.key,
      required this.text,
      required this.tooltipMessage,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.center, // Align text and icon vertically
      children: [
        Expanded(
          // Use Expanded to ensure Text widget takes the available space
          child: Text(
            this.text,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: this.color,
            ),
            overflow: TextOverflow.ellipsis, // Prevent text from overflowing
          ),
        ),
        Tooltip(
          message: this.tooltipMessage, // Tooltip text
          child: IconButton(
            icon:
                Icon(Icons.info_outline, color: this.color), // Icon for tooltip
            onPressed: () {
              // Define action when icon is pressed, if necessary
            },
          ),
        ),
      ],
    );
  }
}
