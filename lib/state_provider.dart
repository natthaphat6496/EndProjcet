import 'package:flutter/material.dart';

class StateService extends ChangeNotifier {
  bool _switchValue = false;
  bool _switchValue1 = false;
  bool _switchValue2 = false;
  
  bool get switchValue => _switchValue;
  bool get switchValue1 => _switchValue1;
  bool get switchValue2 => _switchValue2;

  set switchValue(bool value) {
    _switchValue = value;
    notifyListeners();
  }

  set switchValue1(bool value) {
    _switchValue1 = value;
    notifyListeners();
  }

  set switchValue2(bool value) {
    _switchValue2 = value;
    notifyListeners();
  }
}
