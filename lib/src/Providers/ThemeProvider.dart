import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData? currentTheme;

  ThemeProvider() {
    currentTheme = ThemeData.dark();
  }

  setLightMode() {
    currentTheme = ThemeData(
      primarySwatch: Colors.blue,
      fontFamily: 'Roboto',
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.white24),
        contentPadding: EdgeInsets.all(10.0),
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        // style: ElevatedButton.styleFrom(
        //   padding: const EdgeInsets.all(16),
        //   textStyle: TextStyle(fontSize: 18),
        // ),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: 32,
            vertical: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              12,
            ), // Rounded corners
          ),
          elevation: 5,
          // Shadow
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
    notifyListeners();
  }

  // setDarkmode() {
  //   currentTheme = ThemeData.dark().copyWith(
  //     elevatedButtonTheme: ElevatedButtonThemeData(
  //       style: ElevatedButton.styleFrom(
  //         padding: const EdgeInsets.all(16),
  //         textStyle: TextStyle(fontSize: 18),
  //       ),
  //     ),
  //   );
  //   notifyListeners();
  // }
}
