import 'package:flutter/material.dart';

class ProfileIcons {
  static const List<String> iconPaths = [
    'assets/images/profile_icons/default.png',  
    'assets/images/profile_icons/dog.png',    
    'assets/images/profile_icons/panda.png',   
    'assets/images/profile_icons/penguin.png',   
    'assets/images/profile_icons/walrus.png',    
  ];

  static Widget getIcon(int index, {double size = 50}) {
    if (index < 0 || index >= iconPaths.length) {
      index = 0; 
    }
    return Image.asset(
      iconPaths[index],
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }

  static Widget getDefaultIcon(String username, {double size = 50}) {
    // Alterado para usar a imagem default.png em vez da inicial
    return Image.asset(
      iconPaths[0], // Usa o primeiro ícone (default.png)
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}