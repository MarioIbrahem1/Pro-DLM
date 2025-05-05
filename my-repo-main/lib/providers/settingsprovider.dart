import 'package:flutter/cupertino.dart';

class Settingsprovider  extends ChangeNotifier {
  String currentLocale = 'en';
  void changeLocale(String newLocale){
    if(newLocale==currentLocale)return;
    currentLocale = newLocale;
    notifyListeners();


  }
}