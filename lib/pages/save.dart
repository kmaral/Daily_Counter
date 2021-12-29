import 'package:flutter/material.dart';
import 'package:my_counter/custom/constants.dart';
import 'package:my_counter/models/CounterInfo.dart';
import 'package:my_counter/services/counter_dbhelper.dart';
import 'package:intl/intl.dart';
import 'package:my_counter/services/counter_sharedpref.dart';
import 'home.dart';

class Save extends StatefulWidget {
  @override
  _SaveState createState() => _SaveState();
}

class _SaveState extends State<Save> {
  CounterDBHelper _counterDBHelper = CounterDBHelper();
  TextEditingController textFieldController = TextEditingController();
  bool _isDark = false;

  @override
  void initState() {
    getSFvalue();
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    textFieldController.dispose();
    super.dispose();
  }

  void getSFvalue() async {
    String value = await CounterSharedPref.getTheme("themeInfo");
    if (value != null && value == "true") {
      setState(() {
        _isDark = true;
      });
    } else {
      setState(() {
        _isDark = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      darkTheme: Contstants.getTheme("dark"),
      theme: Contstants.getTheme("light"),
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      home: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: _isDark ? Colors.grey[850] : Colors.white,
          appBar: AppBar(
            title: Text('Add New Counter'),
            automaticallyImplyLeading: false,
            centerTitle: true,
            // automaticallyImplyLeading: false,
            backgroundColor: _isDark ? Colors.blueGrey : Colors.blueAccent[200],
            elevation: 0.0,
            leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_back)),
          ),
          body: Padding(
            padding: const EdgeInsets.all(10.0),
            child: SingleChildScrollView(
              // color: _isDark ? Colors.grey[850] : Colors.grey[300],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text(
                  //   'Name the Counter',
                  //   style: TextStyle(
                  //     letterSpacing: 2.0,
                  //     color: _isDark ? Colors.white : Colors.black,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
                  // SizedBox(
                  //   height: 5.0,
                  // ),
                  TextField(
                    controller: textFieldController,
                    decoration: InputDecoration(
                      labelText: 'Counter Name',
                      fillColor: _isDark ? Colors.white : Colors.black,
                      filled: _isDark,
                    ),
                    maxLength: 30,
                  ),
                  SizedBox(height: 5.0),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          onSaveCounter(textFieldController.text);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Home()),
                          );
                        },
                        label: Text('Save the Counter'),
                        icon: Icon(
                          Icons.save_sharp,
                        ),
                        style: ElevatedButton.styleFrom(
                          primary:
                              _isDark ? Colors.blueGrey[700] : Colors.pink[900],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void onSaveCounter(String counterName) async {
    DateTime timestamp = DateTime.now();
    DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    if (counterName != null && counterName != "") {
      var counterInfo = CounterInfo(
          counterName: counterName,
          counter: 0,
          createdtimeStamp: formatter.format(timestamp),
          lasttimeStamp: formatter.format(timestamp),
          isDeleted: 1,
          archiveOn: "");

      int counterId = await _counterDBHelper.insertCounters(counterInfo);
      if (counterId != 0) {
        _counterDBHelper.insertResetCounters(
            counterId, 0, formatter.format(timestamp), 1);
      }
    }
  }

  showAlertDialog(BuildContext context) {
    // set up the button
    Widget okButton = ElevatedButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context).pop(); // dismiss dialog
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Save Counter"),
      content: Text("The Counter Name already exists. Please create new one."),
      actions: [
        okButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
