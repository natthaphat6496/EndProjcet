// ignore_for_file: unnecessary_cast

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class Light extends StatefulWidget {
  @override
  _LightState createState() => _LightState();
}

class _LightState extends State<Light> {
  late DatabaseReference setDev;
  late DatabaseReference setSTRef;
  late DatabaseReference setSPRef;

  final bool _isSwitchOn = false;
  final List<String> _items = [];
  final List<bool> _itemSwitches = [];

  String formattedStartTime = '';
  String formattedStopTime = '';

  _LightState();

  @override
  void initState() {
    super.initState();
    setDev = FirebaseDatabase.instance.ref().child('Light');
    setSTRef = FirebaseDatabase.instance.ref().child('Time/set/start_time');
    setSPRef = FirebaseDatabase.instance.ref().child('Time/set/stop_time');

    setDev.once().then((DatabaseEvent event) {
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic>? data =
            event.snapshot.value as Map<dynamic, dynamic>?;
        if (data != null) {
          data.forEach((key, value) {
            setState(() {
              _items.add(key);
              _itemSwitches.add(value['switchValue'] == 1);
            });
          });
        }
      }
    });
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

  void removeItem(int index) {
    setState(() {
      String removedItemName = _items.removeAt(index);
      _itemSwitches.removeAt(index);
      setDev.child(removedItemName).remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Controler Light',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                margin: const EdgeInsets.only(right: 20),
                child: Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (!_isSwitchOn) {
                          setState(() {
                            final ledName = 'Light ${_items.length + 1}';
                            _items.add(ledName);
                            _itemSwitches.add(false);
                            setDev.child(ledName).set({
                              'Value': 0,
                            });
                          });
                        } else {}
                      },
                      child: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
              ),
            ],
          ),
          for (int i = 0; i < _items.length; i++)
            ListTile(
              title: Text(_items[i]),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (i < _itemSwitches.length)
                    Switch(
                      value: _itemSwitches[i],
                      onChanged: (value) {
                        setState(() {
                          _itemSwitches[i] = value;
                        });
                        setDev.child(_items[i]).update({
                          'Value': value ? 1 : 0,
                        });
                      },
                    ),
                  if (i < _itemSwitches.length) // Check the bounds
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        removeItem(i);
                      },
                    ),
                ],
              ),
            ),
          Column(
            children: [
              Container(
                child: Row(
                  children: [
                    buildTimeSettingButton(
                      'StartTime',
                      setSTRef,
                      formattedStartTime,
                    ),
                  ],
                ),
              ),
              Container(
                child: Row(
                  children: [
                    buildTimeSettingButton(
                      'StopTime',
                      setSPRef,
                      formattedStopTime,
                    ),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget buildTimeSettingButton(
    String buttonText,
    DatabaseReference ref,
    String formattedTime,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          IconButton(
            color: Color.fromARGB(255, 255, 0, 0),
            onPressed: () {
              _selectTime(context as BuildContext, ref);
            },
            icon: Icon(Icons.access_time, size: 35),
          ),
          const SizedBox(height: 0),
          Text('$buttonText: $formattedTime'),
        ],
      ),
    );
  }
}
