import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class JoystickController extends StatefulWidget {
  const JoystickController({super.key});

  @override
  State<JoystickController> createState() => _JoystickControllerState();
}

class _JoystickControllerState extends State<JoystickController> {
  late WebSocketChannel channel;

  @override
  void initState() {
    super.initState();
    channel = WebSocketChannel.connect(
      Uri.parse('ws://192.168.4.1:81'), // ESP32 AP IP
    );
  }

  void sendJoystick(double x, double y) {
    // Dead zone
    if (x.abs() < 0.1) x = 0;
    if (y.abs() < 0.1) y = 0;

    int xi = (x * 100).toInt();
    int yi = (y * 100).toInt();

    channel.sink.add('$xi,$yi');
  }

  @override
  void dispose() {
    // Stop motors before closing
    channel.sink.add('0,0');
    channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Joystick(
          listener: (details) {
            sendJoystick(details.x, details.y);
          },
          onStickDragEnd: () {
            // STOP motors when released
            channel.sink.add('0,0');
          },
        ),
      ),
    );
  }
}
