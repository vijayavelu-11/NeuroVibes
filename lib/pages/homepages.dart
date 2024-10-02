import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_11/main.dart';
import 'package:flutter_application_11/pages/texttospeech.dart';
import 'package:lottie/lottie.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});
  void _navigateToNextScreen(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => AudioRecorderScreen()));
  }
  void _textToSpeech(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => TextToSpeech()));
  }
  void _openBluetoothSettings() async {
    if (Platform.isAndroid) {
      try {
        final intent = AndroidIntent(
          action: 'android.settings.BLUETOOTH_SETTINGS',
          flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
        );
        await intent.launch();
      } catch (e) {
        print('Error opening Bluetooth settings: $e');
      }
    } else if (Platform.isIOS) {
      // iOS cannot open Bluetooth settings programmatically
      print('Cannot open Bluetooth settings on iOS programmatically.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold (
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text("N E U R O   V I B E S",style: TextStyle(color: Color.fromARGB(255, 83, 120, 255)),),centerTitle: true,backgroundColor: Colors.black,),
      body: Center(child: Column(children: [
        SizedBox(height: 60,),

        Padding(
          padding: const EdgeInsets.all(30.0),
          child: Text(" ~  /  E X P E R I E N C E   S O U N D   T H O U H G   Y O U R   S E N SE /  ~",style: TextStyle(color: Color.fromARGB(255, 83, 120, 255),fontWeight: FontWeight.bold)),
        ),
        SizedBox(height: 100,),
GestureDetector(
  onTap: () {
    _openBluetoothSettings();
  },
  child: Lottie.asset(
    'lib/GIF/bluetooth.json',
    width: 150,
    height: 150,
  ),
),
        Spacer(),
        Container(height: 350,decoration: BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(50),topRight: Radius.circular(50)),color: Color.fromARGB(255, 83, 120, 255).withOpacity(0.2)),child: Center(
          child: Column(children: [
            SizedBox(height: 30,),
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: GestureDetector(
  onTap: () {
   _textToSpeech(context);
  },
  child: Container(
    height: 90,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(25),
      color: Colors.black.withOpacity(0.5),
    ),
    child: Center(
      child: Text(
        "T E X T   T O   S P E E C H",
        style: TextStyle(
          color: Color.fromARGB(255, 83, 120, 255),
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  ),
)

            ),
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: 
ElevatedButton(
  
  style: ElevatedButton.styleFrom(
    
    padding: EdgeInsets.zero, backgroundColor: Colors.black, // Removes default padding
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(25), // Border radius
    ), // Background color
  ),
  onPressed: () {
_navigateToNextScreen(context);  },
  child: Container(
    height: 90, // Same height as your container
    alignment: Alignment.center, // Centers the text
    child: Text(
      "R  E  C  O  R  D",
      style: TextStyle(
        color: Color.fromARGB(255, 83, 120, 255), // Text color
        fontWeight: FontWeight.bold, // Bold text
      ),
    ),
  ),
)
            ),
          
          
          ],),
        ),)

      
      ],),),
    );
  }
  
}