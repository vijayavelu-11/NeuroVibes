import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

void main() {
  runApp(TextToSpeech());
}

class TextToSpeech extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TextToSpeechScreen(),
    );
  }
}

class TextToSpeechScreen extends StatefulWidget {
  @override
  _TextToSpeechScreenState createState() => _TextToSpeechScreenState();
}

class _TextToSpeechScreenState extends State<TextToSpeechScreen> {
  final FlutterTts flutterTts = FlutterTts();
  final TextEditingController textController = TextEditingController();

  // Function to convert text to speech
  Future<void> _speak() async {
    String text = textController.text;
    if (text.isNotEmpty) {
      await flutterTts.speak(text);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter some text')),
      );
    }
  }

  @override
  void dispose() {
    flutterTts.stop(); // Stop any speech if the screen is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Text to Speech',style: TextStyle(color: Color.fromARGB(255, 83, 120, 255)),),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              
              controller: textController,
              decoration: InputDecoration(
                labelText: 'Enter text to speak',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            SizedBox(height: 20),
            ElevatedButton(
  onPressed: _speak,
  style: ElevatedButton.styleFrom(
    foregroundColor: Colors.white, backgroundColor: Color.fromARGB(255, 83, 120, 255), // Text color of the button
    elevation: 5, // Optional: Adds elevation for a shadow effect
  ),
  child: Text('Speak',style: TextStyle(color: Colors.black),),
)

          ],
        ),
      ),
    );
  }
}
