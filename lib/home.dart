import 'package:flutter/material.dart';
import 'package:ringgas/controller.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  String appTitle = "Checking connection...";

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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                appTitle,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await WiFiForIoTPlugin.connect(
                    "RINGGAS Boat",
                    password: "",
                    joinOnce: true,
                  );

                  loadBoat(); // re-check after connecting
                },
                child: const Text("Connect to RINGGAS"),
              ),
              ElevatedButton(onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const JoystickController()
                  )
                );
              }, child: Text('Controller'))
            ],
          ),
        ),
      ),
    );
  }
}

Future<String> checkConnection() async {
  await Permission.location.request();

  String? ssid = await WiFiForIoTPlugin.getSSID();
  debugPrint("ssid: $ssid");

  if (ssid != null && ssid.contains("RINGGAS")) {
    return "RINGGAS Connected!";
  }

  return "RINGGAS not connected.";
}