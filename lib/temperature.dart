import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:new_page/state_provider.dart';
import 'package:provider/provider.dart';

class TemperaState extends StatefulWidget {
  @override
  _TemperaState createState() => _TemperaState();
}

class _TemperaState extends State<TemperaState> {
  late DatabaseReference setSTRef;
  late DatabaseReference setSPRef;
  late DatabaseReference setDev;

  String formattedStartTime = '';
  String formattedStopTime = '';

  @override
  void initState() {
    super.initState();
    setSTRef = FirebaseDatabase.instance.ref().child('set_start_time');
    setSPRef = FirebaseDatabase.instance.ref().child('set_stop_time');
    setDev = FirebaseDatabase.instance.ref().child('Tem/Dev');

    setSTRef.onValue.listen((event) {
      var snapshot = event.snapshot;
      if (snapshot.value != null) {
        setState(() {
          formattedStartTime = snapshot.value.toString();
        });
      }
    });

    setSPRef.onValue.listen((event) {
      var snapshot = event.snapshot;
      if (snapshot.value != null) {
        setState(() {
          formattedStopTime = snapshot.value.toString();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final stateService = Provider.of<StateService>(context);
    final switchValue2 = stateService.switchValue2;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Controler Temperature',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.only(left: 0),
                child: Column(
                  children: [
                    const Text('Dev'),
                    Switch(
                      value: switchValue2,
                      onChanged: (value) {
                        stateService.switchValue2 = value;
                        setDev.set(value ? 1 : 0);
                      },
                      activeColor: switchValue2 ? Colors.green : Colors.red,
                    ),
                    Text(switchValue2 ? 'ON' : 'OFF')
                  ],
                ),
              ),
            ],
          ),
          buildTimeSettingButton(
              'Set Start Time', setSTRef, formattedStartTime),
          buildTimeSettingButton('Set Stop Time', setSPRef, formattedStopTime),
        ],
      ),
    );
  }

  Widget buildTimeSettingButton(
      String buttonText, DatabaseReference ref, String formattedTime) {
    return Container(
      child: Row(
        children: [
          ElevatedButton(
            onPressed: () {
              _selectTime(context, ref);
            },
            child: Text(buttonText),
          ),
          const SizedBox(height: 20),
          Text('$buttonText: $formattedTime'),
        ],
      ),
    );
  }

  Future<void> _selectTime(BuildContext context, DatabaseReference ref) async {
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (selectedTime != null) {
      String formattedTime =
          '${selectedTime.hour}:${selectedTime.minute.toString().padLeft(2, '0')}';
      ref.set(formattedTime);
    }
  }
}
