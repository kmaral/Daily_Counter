import 'package:flutter/material.dart';
import 'package:my_counter/custom/constants.dart';
import 'package:my_counter/pages/home.dart';
import 'package:my_counter/services/counter_sharedpref.dart';

Future<void> main() async {
  bool _isDark = false;
  WidgetsFlutterBinding.ensureInitialized();
  void getSFvalue() async {
    String value = await CounterSharedPref.getTheme("themeInfo");
    value != null && value == "true" ? _isDark = true : _isDark = false;
  }

  getSFvalue();
  runApp(
    MaterialApp(
      darkTheme: Contstants.getTheme("dark"),
      theme: Contstants.getTheme("light"),
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      debugShowCheckedModeBanner: false,
      title: 'My Counter',
      initialRoute: '/',
      routes: {'/': (context) => Home()}, //, '/home': (context) => Home()
    ),
  );
}
