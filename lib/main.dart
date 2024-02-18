import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:will_willnot/configuration/ads_config.dart';
import 'appstate/app_state.dart';
import 'screens/home_screen.dart'; // You'll create this
import 'screens/task_list_screen.dart'; // You'll create this

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  unawaited(MobileAds.instance.initialize());
  runApp(WillWillNotApp());
}

class WillWillNotApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = WillWillNotAppState();
    return ChangeNotifierProvider(
      create: (context) => appState,
      child: Builder(builder: (context) {
        var builderAppState = context.watch<WillWillNotAppState>();
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
  final AdSize adSize = AdSize.banner;
  final String adUnitId = AdsConfig.bannerAdUnitId;

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

  BannerAd? _bannerAd;

  /// Loads a banner ad.
  void _loadAd() {
    final bannerAd = BannerAd(
      size: widget.adSize,
      adUnitId: widget.adUnitId,
      request: const AdRequest(),
      listener: BannerAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _bannerAd = ad as BannerAd;
          });
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (ad, error) {
          debugPrint('BannerAd failed to load: $error');
          ad.dispose();
        },
      ),
    );

    // Start loading.
    bannerAd.load();
  }

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<WillWillNotAppState>();
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
      // Show the ad at the bottom of the screen below navigation bar
      bottomSheet: _bannerAd == null
          ? SizedBox(height: 50)
          : Container(
              alignment: Alignment.bottomCenter,
              child: AdWidget(ad: _bannerAd!),
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
            ),
    );
  }
}
