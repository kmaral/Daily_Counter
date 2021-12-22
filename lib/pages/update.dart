import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_counter/models/CounterInfo.dart';
import 'package:my_counter/services/counter_dbhelper.dart';

class Update extends StatefulWidget {
  final int counterId;

  Update({this.counterId});
  @override
  _UpdateState createState() => _UpdateState();
}

class _UpdateState extends State<Update> {
  CounterDBHelper _counterDBHelper = CounterDBHelper();
  List<CounterInfo> counters = [];
  var _counters;
  String counterName = "";
  TextEditingController textFieldController = TextEditingController();

  @override
  void dispose() {
    textFieldController.dispose();
    super.dispose();
  }

  void _getCounterByid() async {
    counters.clear();
    _counters = await _counterDBHelper.getcountersById(widget.counterId);
    print('query all rows:');
    _counters.forEach(print);
    _counters.forEach((element) {
      counters.add(element);
      if (mounted)
        setState(() {
          textFieldController.text = counters[0].counterName;
        });
    });
  }

  _updateCounters(String counterName) async {
    DateTime timestamp = DateTime.now();
    DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    setState(() {
      _counterDBHelper.updateCounters(
          widget.counterId, counterName, formatter.format(timestamp));
    });
  }

  @override
  void initState() {
    _counterDBHelper.initializeDatabase().then((value) {
      print('------database intialized');
      _getCounterByid();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text('Update Counter Name'),
          centerTitle: true,
          // automaticallyImplyLeading: false,
          backgroundColor: Colors.blueAccent[200],
          elevation: 0.0,
        ),
        body: SingleChildScrollView(
          child: Card(
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
                          'Counter Name',
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
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () async {
                                if (textFieldController.text != "") {
                                  setState(() {
                                    counterName = textFieldController.text;
                                    counters[0].counterName = counterName;
                                  });
                                  _updateCounters(textFieldController.text);
                                }
                                FocusScope.of(context).unfocus();
                                Navigator.pop(context, counters);
                              },
                              label: Text('Update'),
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
      ),
    );
  }
}
