import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
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
  final FlutterTts flutterTts = FlutterTts();
  SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;
  String text = 'Press the button and start speaking';
  String dataFromFirebase = "No Data";
  String dataFromFirebase1 = "No Data";

  @override
  void initState() {
    super.initState();
    speechtotext = FirebaseDatabase.instance.ref().child('index/sptt');
    _speechToText = SpeechToText();
    _getfirebase = FirebaseDatabase.instance.ref().child("index/tem");
    _getfirebase1 = FirebaseDatabase.instance.ref().child("index/humu");

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
        title: const Text(''),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: 50,
                color: const Color.fromARGB(255, 211, 211, 211),
                child: const Center(
                  child: Text(
                    'Smart Farm',
                    style: TextStyle(
                      fontSize: 25,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Column(
            children: [
              SizedBox(
                child: Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.only(top: 5),
                      color: const Color.fromARGB(255, 209, 208, 208),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'ความชื้น : $dataFromFirebase1 % ',
                            style: const TextStyle(fontSize: 18),
                          ),
                          ElevatedButton(
                            onPressed: () => speak(
                                'ขณะนี้ความชื้นเท่ากับ $dataFromFirebase1 %'),
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
                              'อุณหภมิ : $dataFromFirebase°C ',
                              style: const TextStyle(fontSize: 18),
                            ),
                            ElevatedButton(
                              onPressed: () => speak(
                                  'ขณะนี้อุณหภูมิเท่ากับ $dataFromFirebase °C'),
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
                          _isListening ? Icons.mic : Icons.mic_none,
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
                width: MediaQuery.of(context).size.width,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                child: Row(children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => TemperaState()),
                      );
                    },
                    child: const Text('Temperature'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Motor()),
                      );
                    },
                    child: const Text('Motor'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Light()),
                      );
                    },
                    child: const Text('Light'),
                  ),
                ]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
