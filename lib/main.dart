import 'package:flutter/material.dart';
import 'package:flutter_application_11/pages/homepages.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // For formatting date and time

void main() => runApp(AudioRecorderApp());

class AudioRecorderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyWidget(),
    );
  }
}

class AudioRecorderScreen extends StatefulWidget {
  @override
  _AudioRecorderScreenState createState() => _AudioRecorderScreenState();
}

class _AudioRecorderScreenState extends State<AudioRecorderScreen> {
  FlutterSoundRecorder? _recorder;
  AudioPlayer _audioPlayer = AudioPlayer();
  bool _isRecording = false;
  String? _recordingPath;
  List<Map<String, String>> _savedRecordings = [];
  int _recordingCount = 0; // Track the number of recordings

  @override
  void initState() {
    super.initState();
    _recorder = FlutterSoundRecorder();
    _initRecorder();
    _loadSavedRecordings(); // Load saved recordings on app start
  }

  Future<void> _initRecorder() async {
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      _showPermissionError();
      return;
    }
    await _recorder!.openRecorder();
  }

  Future<void> _showPermissionError() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Permission Denied'),
        content: Text('Microphone permission is required to record audio.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  // Save recordings in the app's documents directory with date and time
  Future<void> _startRecording() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    String filePath = '${appDocDir.path}/recording_$timestamp.aac';

    await _recorder!.startRecorder(toFile: filePath);
    setState(() {
      _isRecording = true;
      _recordingPath = filePath;
    });
  }

  Future<void> _stopRecording() async {
    await _recorder!.stopRecorder();
    setState(() {
      _isRecording = false;
      if (_recordingPath != null) {
        _recordingCount++; // Increment the recording count
        String timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
        _savedRecordings.insert(0, {
          'path': _recordingPath!,
          'name': 'Recording $_recordingCount ($timestamp)', // Include the timestamp in the name
        });
        _saveRecordings(); // Save recordings list to SharedPreferences
        _recordingPath = null; // Clear the path for future recordings
      }
    });
  }

  Future<void> _playRecording(String path) async {
    await _audioPlayer.play(DeviceFileSource(path));
  }

  // Save recordings to SharedPreferences
  Future<void> _saveRecordings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> recordings = _savedRecordings
        .map((recording) => '${recording['name']}|${recording['path']}')
        .toList();
    await prefs.setStringList('recordings', recordings);
  }

  // Load recordings from SharedPreferences
  Future<void> _loadSavedRecordings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? recordings = prefs.getStringList('recordings');
    if (recordings != null) {
      setState(() {
        _savedRecordings = recordings.map((record) {
          List<String> parts = record.split('|');
          return {'name': parts[0], 'path': parts[1]};
        }).toList();
      });
    }
  }

  // Delete a recording from the list and file system
  Future<void> _deleteRecording(int index) async {
    String path = _savedRecordings[index]['path']!;
    File file = File(path);

    if (await file.exists()) {
      await file.delete(); // Delete file from storage
    }

    setState(() {
      _savedRecordings.removeAt(index); // Remove from list
      _saveRecordings(); // Update the SharedPreferences
    });
  }

  @override
  void dispose() {
    _recorder!.closeRecorder();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Audio Recorder',style: TextStyle(color: Color.fromARGB(255, 83, 120, 255))),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body:
       Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              _buildRecordingList(), // List of saved recordings
              SizedBox(height: 20),
              _buildRecorderControlCard(),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecordingList() {
    return Expanded(
      child: ListView.builder(
        itemCount: _savedRecordings.length,
        itemBuilder: (context, index) {
          String recordingPath = _savedRecordings[index]['path']!;
          String recordingName = _savedRecordings[index]['name']!;
          return Card(color: Color.fromARGB(255, 83, 120, 255).withOpacity(0.2),
            child: ListTile(
              title: Text(recordingName,style: TextStyle(color: Color.fromARGB(255, 83, 120, 255)),),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.play_arrow,color: Colors.white.withOpacity(0.5),),
                    onPressed: () => _playRecording(recordingPath),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmDelete(index), // Confirm before deleting
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Confirm deletion dialog
  Future<void> _confirmDelete(int index) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Recording'),
        content: Text('Are you sure you want to delete this recording?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _deleteRecording(index); // Delete if confirmed
              Navigator.of(context).pop();
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildRecorderControlCard() {
    return Card(
      elevation: 5,
      color: Color.fromARGB(255, 83, 120, 255).withOpacity(0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Recorder Control',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color:Color.fromARGB(255, 83, 120, 255) ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isRecording ? _stopRecording : _startRecording,
              icon: Icon(_isRecording ? Icons.stop : Icons.mic,color: Color.fromARGB(255, 83, 120, 255),),
              label: Text(_isRecording ? 'Stop Recording' : 'Start Recording',style: TextStyle(color: Color.fromARGB(255, 83, 120, 255)),),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isRecording ? Colors.redAccent : Colors.black.withOpacity(0.5),
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
