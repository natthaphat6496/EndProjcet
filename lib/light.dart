import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:new_page/state_provider.dart';
import 'package:provider/provider.dart';

class Light extends StatefulWidget {
  @override
  _LightState createState() => _LightState();
}

class _LightState extends State<Light> {
  late DatabaseReference setSTRef;
  late DatabaseReference setSPRef;
  late DatabaseReference setDev;
  late DatabaseReference getDev;
  String formattedStartTime = '';
  String formattedStopTime = '';
  String dataFromFirebase = '';
  final bool _isSwitchOn = false;
  final List<String> _items = [];
  final List<bool> _itemSwitches = [];

  @override
  void initState() {
    super.initState();
    setSTRef = FirebaseDatabase.instance.ref().child('Light/set_start_time');
    setSPRef = FirebaseDatabase.instance.ref().child('Light/set_stop_time');
    setDev = FirebaseDatabase.instance.ref().child('Light/Dev');
    getDev = FirebaseDatabase.instance.ref().child('Light/Dev');

    getDev.onValue.listen((DatabaseEvent event) {
      if (event.snapshot.value != null) {
        var data = event.snapshot.value;
        setState(() {
          dataFromFirebase = data.toString();
        });
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

  @override
  Widget build(BuildContext context) {
    final stateService = Provider.of<StateService>(context);
    final switchValue = stateService.switchValue;
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(left: 150),
                child: Column(
                  children: [
                    const Text('DevL'),
                    Switch(
                      value: switchValue,
                      onChanged: (value) {
                        stateService.switchValue = value;
                        setDev.set(value ? 1 : 0);
                      },
                      activeColor: switchValue ? Colors.green : Colors.red,
                    ),
                    Text(switchValue ? 'ON' : 'OFF')
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 100),
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
                              'switchValue': 0,
                            });
                          });
                        } else {}
                      },
                      child: const Icon(Icons.add),
                    ),
                  ],
                ),
              ),
            ],
          ),
          for (int i = 0; i < _items.length; i++)
            ListTile(
              title: Text(_items[i]),
              trailing: Switch(
                value: _itemSwitches[i],
                onChanged: (value) {
                  setState(() {
                    _itemSwitches[i] = value;
                  });
                  setDev.child(_items[i]).update({
                    'switchValue': value ? 1 : 0,
                  });
                },
              ),
            ),
          buildTimeSettingButton(
              'Set Start Time', setSTRef, formattedStartTime),
          buildTimeSettingButton('Set Stop Time', setSPRef, formattedStopTime),
          // สร้างปุ่ม Switch สำหรับแต่ละรายการ
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
