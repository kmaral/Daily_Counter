import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:my_counter/models/CounterInfo.dart';
import 'package:my_counter/services/counter_dbhelper.dart';
import 'package:intl/intl.dart';
import 'home.dart';

class Save extends StatefulWidget {
  @override
  _SaveState createState() => _SaveState();
}

class _SaveState extends State<Save> {
  CounterDBHelper _counterDBHelper = CounterDBHelper();
  TextEditingController textFieldController = TextEditingController();
  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    textFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('Add New Counter'),
          centerTitle: true,
          // automaticallyImplyLeading: false,
          backgroundColor: Colors.blueAccent[200],
          elevation: 0.0,
        ),
        body: Card(
          color: Colors.grey[300],
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              child: Column(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Name the Counter',
                        style: TextStyle(
                          letterSpacing: 2.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextField(
                        controller: textFieldController,
                        decoration: InputDecoration(labelText: ''),
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
                              primary: Colors.pink[900],
                            ),
                          ),
                        ],
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
