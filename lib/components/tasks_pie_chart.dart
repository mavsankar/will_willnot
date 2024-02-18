import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class TasksPieChart extends StatelessWidget {
  final int doneTasksCount;
  final int pendingTasksCount;
  final String doneText;
  final String pendingText;

  const TasksPieChart({
    Key? key,
    required this.doneTasksCount,
    required this.pendingTasksCount,
    required this.doneText,
    required this.pendingText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<PieChartSectionData> sections = [
      PieChartSectionData(
        color: Colors.green,
        value: doneTasksCount.toDouble(),
        title: '$doneTasksCount',
        radius: 50,
        titleStyle: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      PieChartSectionData(
        color: Colors.red,
        value: pendingTasksCount.toDouble(),
        title: '$pendingTasksCount',
        radius: 50,
        titleStyle: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    ];

    return Column(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 30,
              sectionsSpace: 0,
              pieTouchData: PieTouchData(
                touchCallback: (touchEvent, pieTouchResponse) {
                  // Implement touch event
                },
              ),
              // Center Space Make it dark mode agnostic
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Indicator(
              color: Colors.green,
              text: doneText,
              isSquare: true,
            ),
            Indicator(
              color: Colors.red,
              text: pendingText,
              isSquare: true,
            ),
          ],
        ),
      ],
    );
  }
}

class Indicator extends StatelessWidget {
  final Color color;
  final String text;
  final bool isSquare;

  const Indicator({
    Key? key,
    required this.color,
    required this.text,
    this.isSquare = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(
          width: 4,
        ),
        Text(text, style: const TextStyle(fontSize: 16)),
      ],
    );
  }
}
