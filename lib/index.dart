import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:new_page/setting.dart';
import 'package:new_page/temperature.dart';
import 'package:new_page/motor.dart';
import 'package:new_page/light.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late DatabaseReference speechtotext;
  late DatabaseReference _getfirebase;
  late DatabaseReference _getfirebase1;
  late DatabaseReference _getfirebase2;
  final TextEditingController ssidController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FlutterTts flutterTts = FlutterTts();
  SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;
  String text = 'Press the button and start speaking';
  String dataFromFirebase = "No Data";
  String dataFromFirebase1 = "No Data";
  String dataFromFirebase2 = "No Data";
  @override
  void initState() {
    super.initState();
    speechtotext = FirebaseDatabase.instance.ref().child('index/sptt');
    _speechToText = SpeechToText();
    _getfirebase = FirebaseDatabase.instance.ref().child("index/tem");
    _getfirebase1 = FirebaseDatabase.instance.ref().child("index/humu");
    _getfirebase2 = FirebaseDatabase.instance.ref().child("index/humuEar");

    _getfirebase.onValue.listen((DatabaseEvent event) {
      if (event.snapshot.value != null) {
        var data = event.snapshot.value;
        setState(() {
          dataFromFirebase = data.toString();
        });
      }
    });

    _getfirebase1.onValue.listen((DatabaseEvent event) {
      if (event.snapshot.value != null) {
        var data = event.snapshot.value;
        setState(() {
          dataFromFirebase1 = data.toString();
        });
      }
    });
    _getfirebase2.onValue.listen((DatabaseEvent event) {
      if (event.snapshot.value != null) {
        var data = event.snapshot.value;
        setState(() {
          dataFromFirebase2 = data.toString();
        });
      }
    });
  }

  speak(String text) async {
    await flutterTts.setLanguage('th-TH');
    await flutterTts.setPitch(1.5);
    await flutterTts.speak(text);
  }

  void _sendToFirebase(String text) {
    speechtotext.set(text);
  }

  void startListening() async {
    if (!_isListening) {
      bool available = await _speechToText.initialize(
        onStatus: (status) {
          print('Status: $status');
        },
        onError: (error) {
          print('Error: $error');
        },
      );
      if (available) {
        setState(() {
          _isListening = true;
        });

        _speechToText.listen(
          onResult: (result) {
            setState(() {
              text = result.recognizedWords;
              if (result.finalResult) {
                _sendToFirebase(text);
              }
            });
          },
        );

        Future.delayed(const Duration(seconds: 5), () {
          if (_isListening) {
            _speechToText.stop();
            setState(() {
              _isListening = false;
            });
          }
        });
      }
    } else {
      _speechToText.stop();
      setState(() {
        _isListening = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Farm'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'settings') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Setting()),
                );
              }
              if (value == 'TemperaState') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TemperaState()),
                );
              }
              if (value == 'Motor') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Motor()),
                );
              }
              if (value == 'Light') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Light()),
                );
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(
                  value: 'settings',
                  child: Row(
                    children: [
                      Icon(Icons.settings),
                      SizedBox(width: 8),
                      Text('Settings'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'TemperaState',
                  child: Row(
                    children: [
                      Icon(Icons.thermostat),
                      SizedBox(width: 8),
                      Text('Temperature'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'Motor',
                  child: Row(
                    children: [
                      Icon(Icons.motorcycle),
                      SizedBox(width: 8),
                      Text('Motor'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'Light',
                  child: Row(
                    children: [
                      Icon(Icons.lightbulb),
                      SizedBox(width: 8),
                      Text('Light'),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Column(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.98,
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 5),
                      color: const Color.fromARGB(255, 209, 208, 208),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'ความชื้นในอากาศ : $dataFromFirebase1 % ',
                            style: const TextStyle(fontSize: 18),
                          ),
                          ElevatedButton(
                            onPressed: () => speak(
                                'ขณะนี้ความชื้นในอากาศเท่ากับ $dataFromFirebase1 %'),
                            child: Text('Read'),
                          ),
                        ],
                      ),
                    ),
                    Container(
                        color: const Color.fromARGB(255, 209, 208, 208),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'อุณหภูมิ : $dataFromFirebase °C ',
                              style: const TextStyle(fontSize: 18),
                            ),
                            ElevatedButton(
                              onPressed: () => speak(
                                  'ขณะนี้อุณหภูมิห้องเท่ากับ $dataFromFirebase °C'),
                              child: Text('Read'),
                            ),
                          ],
                        )),
                    Container(
                        color: const Color.fromARGB(255, 209, 208, 208),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'ความชื้นในดิน : $dataFromFirebase2 % ',
                              style: const TextStyle(fontSize: 18),
                            ),
                            ElevatedButton(
                              onPressed: () => speak(
                                  'ขณะนี้ความชื้นในดินเท่ากับ $dataFromFirebase2 %'),
                              child: Text('Read'),
                            ),
                          ],
                        )),
                  ],
                ),
              )
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10),
                child: Column(children: [
                  ElevatedButton(
                    onPressed: () {
                      startListening();
                      setState(() {
                        text = 'Listening...';
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isListening
                          ? const Color.fromARGB(255, 233, 119, 111)
                          : const Color.fromARGB(255, 114, 219, 118),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isListening ? Icons.pause : Icons.play_arrow,
                          color: _isListening ? Colors.white : null,
                        ),
                        const SizedBox(width: 8),
                        Text(_isListening ? 'Stop' : 'Start'),
                      ],
                    ),
                  ),
                ]),
              ),
              Container(
                color: const Color.fromARGB(255, 180, 180, 180),
                width: MediaQuery.of(context).size.width * 0.98,
                height: 30,
                margin: EdgeInsets.all(5),
                child: Column(
                  children: [
                    Text(
                      text,
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
