import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:will_willnot/configuration/ads_config.dart';
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
  InterstitialAd? _interstitialAd;

  void loadAd() {
    InterstitialAd.load(
        adUnitId: AdsConfig.interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          // Called when an ad is successfully received.
          onAdLoaded: (ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
                // Called when the ad showed the full screen content.
                onAdShowedFullScreenContent: (ad) {},
                // Called when an impression occurs on the ad.
                onAdImpression: (ad) {},
                // Called when the ad failed to show full screen content.
                onAdFailedToShowFullScreenContent: (ad, err) {
                  // Dispose the ad here to free resources.
                  ad.dispose();
                },
                // Called when the ad dismissed full screen content.
                onAdDismissedFullScreenContent: (ad) {
                  // Dispose the ad here to free resources.
                  ad.dispose();
                  loadAd();
                },
                // Called when a click is recorded for an ad.
                onAdClicked: (ad) {});

            debugPrint('$ad loaded.');
            // Keep a reference to the ad so you can show it later.
            _interstitialAd = ad;
          },
          // Called when an ad request failed.
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('InterstitialAd failed to load: $error');
          },
        ));
  }

  @override
  void initState() {
    super.initState();
    loadAd();
  }
  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<WillWillNotAppState>();
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
              onChanged: (bool? value) async {
                appState.toggleChecked(index, context,
                    typeOfTask: widget.typeOfTask);
                if(widget.typeOfTask == TypeOfTask.willNotDo && item.isDone){
                  if (_interstitialAd != null) {
                    await Future.delayed(const Duration(seconds: 2));
                    _interstitialAd!.show();
                  } else {
                    debugPrint('InterstitialAd is null');
                  }
                }
              },
              activeColor: widget.typeOfTask == TypeOfTask.willDo
                  ? Colors.green
                  : Colors.redAccent,
            ),
            //Show the streak
            subtitle: Text(
              'Streak: ${item.streak}',
              style: TextStyle(
                  color: widget.typeOfTask == TypeOfTask.willDo
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
    WillWillNotAppState appState,
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
