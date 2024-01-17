import 'package:flutter/material.dart';

class PageState with ChangeNotifier {
  int _currentPage = 0;

  int get currentPage => _currentPage;

  set currentPage(int page) {
    _currentPage = page;
    notifyListeners(); // Notifica a los oyentes que hay un cambio
  }
}
