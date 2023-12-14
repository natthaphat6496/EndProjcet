import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class Setting extends StatefulWidget {
  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  final TextEditingController ssidController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController FIREBASE_HOST = TextEditingController();
  final TextEditingController FIREBASE_AUTH = TextEditingController();

  void saveWifiConfiguration() async {
    final DatabaseReference wifiRef =
        FirebaseDatabase.instance.reference().child('wifi');
    final DatabaseReference firebaseRef =
        FirebaseDatabase.instance.reference().child('firebase');

    await wifiRef.set({
      'ssid': ssidController.text,
      'password': passwordController.text,
    });
    await firebaseRef.set({
      'FIREBASE_HOST': FIREBASE_HOST.text,
      'FIREBASE_AUTH': FIREBASE_AUTH.text,
    });

    print('Wi-Fi configuration saved to Firebase!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(' Setting Wi-Fi '),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('Setting WiFi'),
              TextFormField(
                controller: ssidController,
                decoration: const InputDecoration(labelText: 'SSID'),
              ),
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
              ),
              TextFormField(
                controller: FIREBASE_HOST,
                decoration: const InputDecoration(labelText: 'FIREBASE_HOST'),
              ),
              TextFormField(
                controller: FIREBASE_AUTH,
                decoration: const InputDecoration(labelText: 'FIREBASE_AUTH'),
              ),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                onPressed: saveWifiConfiguration,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
