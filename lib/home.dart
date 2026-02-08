import 'package:flutter/material.dart';
import 'package:ringgas/controller.dart';
import 'package:ringgas/homeScreen.dart';
import 'package:ringgas/settingsScreen.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  String appTitle = "Checking connection...";
  int _selectedIndex = 0;
  final ScrollController _homeController = ScrollController();

  List<Widget> widgetList = const [
    NewHomeScreen(),
    JoystickController(),
    SettingsScreen()
  ];

  @override
  void initState() {
    super.initState();
    loadBoat();
  }

  Future<void> loadBoat() async {
    String result = await checkConnection();

    setState(() {
      appTitle = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle,
      home: Scaffold(
        body: Center(
          child: widgetList[_selectedIndex],
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.blue[400],
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.monitor), label: 'RINGGAS Boat'),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings')
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.white,
          onTap: (int index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),
    );
  }
}

Future<String> checkConnection() async {
  await Permission.location.request();

  String? ssid = await WiFiForIoTPlugin.getSSID();
  debugPrint("ssid: $ssid");

  if (ssid == null) return "Not connected to WiFi";

  ssid = ssid.replaceAll('"', '');

  if (ssid == "RINGGAS_Boat") {
    return "RINGGAS Connected!";
  }

  return "RINGGAS not connected.";
}
