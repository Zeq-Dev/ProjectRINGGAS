import 'package:flutter/material.dart';
import 'package:ringgas/controller.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:permission_handler/permission_handler.dart';

class NewHomeScreen extends StatefulWidget {
  const NewHomeScreen({super.key});

  @override
  State<NewHomeScreen> createState() => _NewHomeScreenState();
}

class _NewHomeScreenState extends State<NewHomeScreen> {

  String appTitle = "Checking Connection...";

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
        appBar: AppBar(
          title: const Text("Home"),
          backgroundColor: Colors.blue[400],
        ),
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
                  await Permission.location.request();

                  await WiFiForIoTPlugin.connect(
                    "RINGGAS_Boat",
                    security: NetworkSecurity.NONE,
                    joinOnce: true,
                    withInternet: false,
                  );

                  // Wait for Android to switch networks
                  await Future.delayed(const Duration(seconds: 2));

                  await loadBoat(); // re-check SSID
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

  // if (ssid == null) return "RINGGAS not connected.";

  // ssid = ssid.replaceAll('"', '');

  if (ssid == "RINGGAS_Boat") {
    return "RINGGAS Connected!";
  }
  await Future.delayed(const Duration(milliseconds: 2000));
  return "RINGGAS not connected.";
}
