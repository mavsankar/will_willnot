import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'appstate/app_state.dart';
import 'screens/home_screen.dart'; // You'll create this
import 'screens/task_list_screen.dart'; // You'll create this

void main() {
  runApp(WillWillNotApp());
}

class WillWillNotApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = AppState();
    return ChangeNotifierProvider(
      create: (context) => appState,
      child: Builder(builder: (context) {
        var builderAppState = context.watch<AppState>();
        return MaterialApp(
          title: 'Will, Will Not',
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: builderAppState.uiMode == uimode.dark
                ? ColorScheme.dark()
                : ColorScheme.light(),
          ),
          home: MainScreen(),
        );
      }),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    HomeScreen(),
    TaskListScreen(
      typeOfTask: TypeOfTask.willDo,
    ),
    TaskListScreen(
      typeOfTask: TypeOfTask.willNotDo,
    )
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    return Scaffold(
      //App Bar with title and a refresh button
      appBar: AppBar(
        title: Text('Will, Will Not'),
        elevation: 2,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              appState.loadTasksFromFile();
            },
          ),
          IconButton(
              onPressed: () {
                appState.toggleUiMode();
              },
              icon: Icon(Icons.brightness_4)),
        ],
      ),
      body: IndexedStack(
        // Use IndexedStack to maintain state of each screen
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            icon: new Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: new Icon(
              Icons.check_box,
              color: Colors.green,
            ),
            label: 'Will',
          ),
          BottomNavigationBarItem(
            // Icon for asking users to avoid this
            icon: new Icon(
              Icons.check_box,
              color: Colors.redAccent,
            ),
            label: 'Will Not',
          ),
        ],
      ),
    );
  }
}
