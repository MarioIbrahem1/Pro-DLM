import 'package:flutter/foundation.dart';

class SignupProvider with ChangeNotifier {
  Map<String, dynamic> userData = {};

  void setUserData(Map<String, dynamic> data) {
    userData.addAll(data);
    notifyListeners();
  }

  void clear() {
    userData.clear();
    notifyListeners();
  }
}
