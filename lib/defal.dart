import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:new_page/control.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';


class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late DatabaseReference led;
  late DatabaseReference led1;
  late DatabaseReference led2;
  late DatabaseReference slide;
  late DatabaseReference slide1;
  late DatabaseReference slide2;
  late DatabaseReference speechtotext;
  late DatabaseReference _getfirebase;
  late DatabaseReference _getfirebase1;
  final FlutterTts flutterTts = FlutterTts();

  bool switchValue = false;
  bool switchValue1 = false;
  bool switchValue2 = false;
  int sliderValue = 0;
  int sliderValue1 = 0;
  int sliderValue2 = 0;
  SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;
  String text = 'Press the button and start speaking';
  double progressValue = 0.5;
  String dataFromFirebase = "No Data";
  String dataFromFirebase1 = "No Data";

  @override
  void initState() {
    super.initState();
    led = FirebaseDatabase.instance.ref().child('led1');
    led1 = FirebaseDatabase.instance.ref().child('led2');
    led2 = FirebaseDatabase.instance.ref().child('led3');
    slide = FirebaseDatabase.instance.ref().child('slidled');
    slide1 = FirebaseDatabase.instance.ref().child('slidled1');
    slide2 = FirebaseDatabase.instance.ref().child('slidled2');
    speechtotext = FirebaseDatabase.instance.ref().child('speechtotext');
    _speechToText = SpeechToText();
    _getfirebase = FirebaseDatabase.instance.ref().child("sensor");
    _getfirebase1 = FirebaseDatabase.instance.ref().child("sensor1");

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
                    'Control Manual',
                    style: TextStyle(
                      fontSize: 25,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 5, bottom: 5),
                color: const Color.fromARGB(255, 209, 208, 208),
                width: 350,
                child: Stack(
                  children: [
                    Container(
                      //LED1
                      padding: const EdgeInsets.only(left: 0),
                      child: Column(
                        children: [
                          const Text('LED1'),
                          Switch(
                            value: switchValue,
                            onChanged: (value) {
                              setState(() {
                                switchValue = value;
                                led.set(switchValue ? 1 : 0);
                              });
                            },
                            activeColor:
                                switchValue ? Colors.green : Colors.red,
                          ),
                          Text(switchValue ? 'ON' : 'OFF')
                        ],
                      ),
                    ),
                    Container(
                      //LED2
                      padding: const EdgeInsets.only(left: 150),
                      child: Column(
                        children: [
                          const Text('LED2'),
                          Switch(
                            value: switchValue1,
                            onChanged: (value) {
                              setState(() {
                                switchValue1 = value;
                                led1.set(switchValue1 ? 1 : 0);
                              });
                            },
                            activeColor:
                                switchValue1 ? Colors.green : Colors.red,
                          ),
                          Text(switchValue1 ? 'ON' : 'OFF')
                        ],
                      ),
                    ),
                    Container(
                      //LED3
                      padding: const EdgeInsets.only(left: 290),
                      child: Column(
                        children: [
                          const Text('LED3'),
                          Switch(
                            value: switchValue2,
                            onChanged: (value) {
                              setState(() {
                                switchValue2 = value;
                                led2.set(switchValue2 ? 1 : 0);
                              });
                            },
                            activeColor:
                                switchValue2 ? Colors.green : Colors.red,
                          ),
                          Text(switchValue2 ? 'ON' : 'OFF')
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            //Slider 1
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 330,
                color: const Color.fromARGB(255, 209, 208, 208),
                margin: EdgeInsets.only(top: 3),
                child: Row(children: [
                  Text('Slider Led1'),
                  RotatedBox(
                    quarterTurns: 0, // Rotate the slider vertically
                    child: Slider(
                      value: sliderValue.toDouble(),
                      onChanged: (value) {
                        setState(() {
                          sliderValue = value.round();
                          slide.set(sliderValue);
                        });
                      },
                      min: 0,
                      max: 100,
                      divisions: 100,
                      label: sliderValue.toString(),
                    ),
                  ),
                  Text('$sliderValue')
                ]),
              ),
            ],
          ),
          Row(
            //Slider 2
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 330,
                color: const Color.fromARGB(255, 209, 208, 208),
                margin: EdgeInsets.only(top: 3),
                child: Row(children: [
                  Text('Slider Led2'),
                  RotatedBox(
                    quarterTurns: 0, // Rotate the slider vertically
                    child: Slider(
                      value: sliderValue1.toDouble(),
                      onChanged: (value) {
                        setState(() {
                          sliderValue1 = value.round();
                          slide1.set(sliderValue1);
                        });
                      },
                      min: 0,
                      max: 100,
                      divisions: 100,
                      label: sliderValue1.toString(),
                    ),
                  ),
                  Text('$sliderValue1')
                ]),
              ),
            ],
          ),
          Row(
            //Slider 3
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 330,
                color: const Color.fromARGB(255, 209, 208, 208),
                margin: EdgeInsets.only(top: 3),
                child: Row(children: [
                  Text('Slider Led3'),
                  RotatedBox(
                    quarterTurns: 0, // Rotate the slider vertically
                    child: Slider(
                      value: sliderValue2.toDouble(),
                      onChanged: (value) {
                        setState(() {
                          sliderValue2 = value.round();
                          slide2.set(sliderValue2);
                        });
                      },
                      min: 0,
                      max: 100,
                      divisions: 100,
                      label: sliderValue2.toString(),
                    ),
                  ),
                  Text('$sliderValue2')
                ]),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(
                child: Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 5),
                      color: const Color.fromARGB(255, 209, 208, 208),
                      width: 170,
                      height: 190,
                      child: Column(
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
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
          Column(
            children: [
              // Expanded(

              // ),
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
              Container(
                child: Column(children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Control()),
                      );
                    },
                    child: const Text('Setting Controler'),
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
