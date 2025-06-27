import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  int? _userId;
  
  // Getter para userId - retorna -1 se não estiver logado (modo visitante)
  int get userId => _userId ?? -1;
  
  // Getter para verificar se está logado
  bool get isLoggedIn => _userId != null;
  
  // Getter para currentUserId (pode ser nulo)
  int? get currentUserId => _userId;

  void login(int userId) {
    _userId = userId;
    notifyListeners();
  }
  
  void logout() {
    _userId = null;
    notifyListeners();
  }
  
  void setVisitorMode() {
    _userId = -1;
    notifyListeners();
  }
}