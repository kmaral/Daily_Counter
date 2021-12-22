import 'package:flutter/material.dart';
import 'package:my_counter/pages/home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Counter',
      initialRoute: '/',
      routes: {'/': (context) => Home()}, //, '/home': (context) => Home()
    ),
  );
}
