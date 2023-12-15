import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;

class Setting extends StatefulWidget {
  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  final TextEditingController ssidController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController firebaseHost = TextEditingController();
  final TextEditingController firebaseAuth = TextEditingController();
  final TextEditingController connectWifi = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool showConnectFields = false;
  late DatabaseReference _databaseReference;
  String _dataFromFirebase = "No Data";

  @override
  void initState() {
    super.initState();

    _databaseReference =
        FirebaseDatabase.instance.ref().child("Setting/connectwifi");

    _databaseReference.onValue.listen((DatabaseEvent event) {
      if (event.snapshot.value != null) {
        var data = event.snapshot.value;
        setState(() {
          _dataFromFirebase = data.toString();
        });
      }
    });
  }

  void saveWifiConfiguration() async {
    final DatabaseReference wifiRef =
        FirebaseDatabase.instance.ref().child('Setting/wifi');
    final DatabaseReference firebaseRef =
        FirebaseDatabase.instance.ref().child('Setting/firebase');

    await wifiRef.set({
      'ssid': ssidController.text,
      'password': passwordController.text,
    });
    await firebaseRef.set({
      'FIREBASE_HOST': firebaseHost.text,
      'FIREBASE_AUTH': firebaseAuth.text,
    });

    setState(() {
      showConnectFields = true;
    });
    print('Wi-Fi configuration saved to Firebase!');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Save'),
      ),
    );
  }

  void connectToESP32() async {
    final DatabaseReference connectwifi =
        FirebaseDatabase.instance.ref().child('Setting');
    final response =
        await http.get(Uri.parse('http://$_dataFromFirebase/connect'));
    if (response.statusCode == 200) {
      print('Connected to ESP32');
    } else {
      print('Failed to connect to ESP32');
    }

    await connectwifi.set({
      'connectwifi': connectWifi.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(' Setting Wi-Fi '),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text('Setting WiFi'),
                TextFormField(
                  controller: ssidController,
                  decoration: const InputDecoration(labelText: 'SSID'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter SSID';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Password';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: firebaseHost,
                  decoration: const InputDecoration(labelText: 'FIREBASE_HOST'),
                ),
                TextFormField(
                  controller: firebaseAuth,
                  decoration: const InputDecoration(labelText: 'FIREBASE_AUTH'),
                ),
                const SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      print('SSID: ${ssidController.text}');
                      saveWifiConfiguration();
                    }
                  },
                  child: const Text('Save'),
                ),
                Container(
                  child: Column(
                    children: [
                      if (showConnectFields)
                        Column(
                          children: [
                            TextFormField(
                              controller: connectWifi,
                              decoration: const InputDecoration(
                                labelText: 'Enter Uri ip-address...',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter IP address';
                                }
                                RegExp regExp = RegExp(
                                  r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$',
                                );
                                if (!regExp.hasMatch(value)) {
                                  return 'Enter a valid IP address';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: connectToESP32,
                              child: const Text('Connect to Wi-Fi'),
                            ),
                            const SizedBox(height: 10),
                            const Text(''),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
