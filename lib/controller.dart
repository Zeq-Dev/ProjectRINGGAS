import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_mjpeg/flutter_mjpeg.dart';

class JoystickController extends StatefulWidget {
  const JoystickController({super.key});

  @override
  State<JoystickController> createState() => _JoystickControllerState();
}

double leftMotor = 0;
double rightMotor = 0;

class _JoystickControllerState extends State<JoystickController> {
  late WebSocketChannel channel;

  @override
  void initState() {
    super.initState();
    channel = WebSocketChannel.connect(
      Uri.parse('ws://192.168.4.1:81'), // ESP32 AP IP
    );
  }

  // void sendJoystick(double x, double y) {
  //   // Dead zone
  //   if (x.abs() < 0.1) x = 0;
  //   if (y.abs() < 0.1) y = 0;

  //   int xi = (x * 100).toInt();
  //   int yi = (y * 100).toInt();

  //   channel.sink.add('$xi,$yi');
  // }

  @override
  void dispose() {
    // Stop motors before closing
    channel.sink.add('0,0');
    channel.sink.close();
    super.dispose();
  }

  void sendMotorValues(double left, double right) {
    // Map -1.0 → 1.0 to -255 → 255
    int leftSpeed = (left * 255).toInt();
    int rightSpeed = (right * 255).toInt();

    // Send to ESP32 via WebSocket
    channel.sink.add("L:$leftSpeed,R:$rightSpeed");
  }

  bool conveyor = false;
  
  Future<bool> isStreamActive() async {
    try {
      final response = await http
          .get(Uri.parse('http://192.168.4.2/capture'))
          .timeout(const Duration(seconds: 2));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OrientationBuilder(builder: (context, orientation) {
       if (orientation == Orientation.portrait) {
        return portraitLayout();
       } else {
        return landscapeLayout();
       }
      }),
    );
  }

  double _value = 100;

  Widget landscapeLayout() {
    return Scaffold(
      bottomNavigationBar: null,
      body: Center(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Slider(
                  min: 0,
                  max: 140,
                  divisions: 140,
                  value: _value,
                  onChanged: (newValue) {
                    setState(() {
                      _value = newValue;
                      channel.sink.add('C_s,${_value.toInt()},');
                    });
                  }
                ),
                Joystick(
                  mode: JoystickMode.vertical,
                  base: JoystickBase(
                    decoration: JoystickBaseDecoration(
                      middleCircleColor: Colors.grey[500],
                      innerCircleColor: Colors.blueAccent,
                      drawOuterCircle: false,
                      drawInnerCircle: false,
                    ),
                  ),
                  listener: (details) {
                    leftMotor = details.y; // -1.0 to 1.0
                    sendMotorValues(leftMotor, rightMotor);
                  },
                  onStickDragEnd: () {
                    leftMotor = 0;
                    sendMotorValues(leftMotor, rightMotor);
                  },
                ),
              ],
            ),
            
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(
                  child: Mjpeg(
                    stream: 'http://192.168.4.2:81/stream',
                    isLive: true,
                    timeout: Duration(seconds: 5),
                  )
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Switch(value: conveyor, onChanged: (bool value) {
                  setState(() {
                    conveyor = value;
                    channel.sink.add('C,${value ? 1 : 0}');
                  });
                }),
                Joystick(
                  base: JoystickBase(
                    decoration: JoystickBaseDecoration(
                      middleCircleColor: Colors.grey[500],
                      innerCircleColor: Colors.blueAccent,
                      drawOuterCircle: false,
                      drawInnerCircle: false
                    ),
                  ),
                  mode: JoystickMode.vertical, // only X-axis
                  listener: (details) {
                    rightMotor = -details.y; // -1.0 to 1.0
                    sendMotorValues(leftMotor, rightMotor);
                  },
                  onStickDragEnd: () {
                    rightMotor = 0;
                    sendMotorValues(leftMotor, rightMotor);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget portraitLayout() {
    return Scaffold(
      appBar: AppBar(
        title: const Text("RINGGAS Boat"),
        backgroundColor: Colors.blue[400],
      ),
      body: Center(
        child: Column(
          children: [
            Switch(value: conveyor, onChanged: (bool value) {
              setState(() {
                conveyor = value;
                channel.sink.add('C,${value ? 1 : 0}');
              });
            }),
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(12),
                color: Colors.black,
              ),
            ),
            Joystick(
              listener: (details) {
                // sendJoystick(details.x, details.y);
              },
              onStickDragEnd: () {
                // STOP motors when released
                channel.sink.add('0,0');
              },
            ),
          ],
        ),
      ),
    );
  }
}
