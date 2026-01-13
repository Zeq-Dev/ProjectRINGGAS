import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';

class JoystickController extends StatefulWidget {
  const JoystickController({super.key});

  @override
  State<JoystickController> createState() => _JoystickControllerState();
}

class _JoystickControllerState extends State<JoystickController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Joystick(listener: (details) {
          debugPrint(details.x.toString());
        }),
      ),
    );
  }
}