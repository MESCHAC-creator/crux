import 'package:flutter/material.dart';

/// Provider pour gérer l'état de création de réunion
/// Utilisé pour éviter que _isLargeConference persiste entre les créations
class MeetingCreationProvider extends ChangeNotifier {
  bool _isLargeConference = false;

  bool get isLargeConference => _isLargeConference;

  void setLargeConference(bool value) {
    _isLargeConference = value;
    notifyListeners();
  }

  void reset() {
    _isLargeConference = false;
    notifyListeners();
  }
}
