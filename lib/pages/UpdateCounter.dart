import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:my_counter/custom/constants.dart';
import 'package:my_counter/models/CounterInfo.dart';
import 'package:my_counter/pages/counter_statitics.dart';
import 'package:my_counter/services/counter_dbhelper.dart';
import 'package:my_counter/services/counter_sharedpref.dart';

class UpdateCounter extends StatefulWidget {
  final int counterId;

  //final String counterNameFromUpdate;

  // In the constructor, require a Todo.
  UpdateCounter({this.counterId});
  @override
  _UpdateCounterState createState() => _UpdateCounterState();
}

class _UpdateCounterState extends State<UpdateCounter> {
  Duration duration = Duration();
  Timer _timer;
  int _counter = 0;
  String lastUpdatedtimestamp = "";

  String counterInfoName = "";
  String createdTimestamp = "";
  int count;
  Map<String, dynamic> mapSend;
  List<CounterInfo> counters = [];
  var _counters;
  bool isLoading = false;
  bool _isDark = false;

  CounterDBHelper _counterDBHelper = CounterDBHelper();
  @override
  void initState() {
    _counterDBHelper.initializeDatabase().then((value) {
      print('------database intialized');
      _getCounter();
    });
    getSFvalue();
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
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

  void _getCounter() async {
    int counterId = widget.counterId != null
        ? widget.counterId
        : counters[0].counterId != null
            ? counters[0].counterId
            : 0;
    counters.clear();
    _counters = await _counterDBHelper.getcountersById(counterId);
    print('query all rows:');
    _counters.forEach(print);
    _counters.forEach((element) {
      counters.add(element);
      if (mounted)
        setState(() {
          _counter = counters[0].counter != null
              ? int.parse(counters[0].counter.toString())
              : 0;
          counterInfoName =
              counters[0].counterName != null ? counters[0].counterName : "";

          lastUpdatedtimestamp = counters[0].lasttimeStamp != null
              ? counters[0].lasttimeStamp
              : "";

          duration = Contstants.getDuration(duration, lastUpdatedtimestamp);
          startTime();
          isLoading = true;
        });
    });
  }

  _incrementCounter() async {
    DateTime timestamp = DateTime.now();
    DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    setState(() {
      _counter++;
    });
    _counterDBHelper.incrementCounter(
        counters[0].counterId, _counter, formatter.format(timestamp));
    counters[0].counter = _counter;
    counters[0].counterName = counterInfoName;
    counters[0].lasttimeStamp = formatter.format(timestamp);
    lastUpdatedtimestamp = counters != null && counters.length > 0
        ? counters[0].lasttimeStamp
        : "";
    duration = Contstants.getDuration(duration, lastUpdatedtimestamp);
    if (_timer != null && _timer.isActive) {
      _timer.cancel();
    }
    startTime();
  }

  _decrementCounter() async {
    DateTime timestamp = DateTime.now();
    DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    setState(() {
      if (_counter <= 0) {
        _counter = 0;
      } else {
        _counter--;
      }
    });
    _counterDBHelper.decrementCounter(
        counters[0].counterId, _counter, formatter.format(timestamp));
    counters[0].counter = _counter;
    counters[0].counterName = counterInfoName;
    counters[0].lasttimeStamp = formatter.format(timestamp);
    lastUpdatedtimestamp = formatter.format(timestamp);
    duration = Contstants.getDuration(duration, lastUpdatedtimestamp);
    if (_timer != null && _timer.isActive) {
      _timer.cancel();
    }
    startTime();
  }

  updateResetCounters() async {
    DateTime timestamp = DateTime.now();
    DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    _counterDBHelper.updateReset(counters[0].counterId, 0);
    _counterDBHelper.insertResetCounters(
        counters[0].counterId, 0, formatter.format(timestamp), 1);
    _counterDBHelper.updateCounterNumber(
        counters[0].counterId, 0, formatter.format(timestamp), " (Reset)");
    setState(() {
      // var resetCounterUpdateInfo = ResetCounterInfo(
      //     counterId: counters[0].counterId,
      //     resetCounter: 0,
      //     endtimeStamp: formatter.format(timestamp));
      // _counterDBHelper.insertResetCounters(resetCounterUpdateInfo);
    });
    _counter = 0;
  }

  void startTime() {
    _timer = Timer.periodic(Duration(seconds: 1), (_) => addTimer());
  }

  addTimer() {
    final addSeconds = 1;
    setState(() {
      final seconds = duration.inSeconds + addSeconds;
      duration = Duration(seconds: seconds);
    });
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
        child: new Scaffold(
          backgroundColor: _isDark ? Colors.grey[850] : Colors.white,
          appBar: AppBar(
            // automaticallyImplyLeading: false,
            title: Text('Update the Counter'),
            centerTitle: true,
            backgroundColor: _isDark ? Colors.blueGrey : Colors.blueAccent[200],
            elevation: 0.0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                if (counters.length > 0) {
                  counters[0].counterName = counterInfoName;
                  counters[0].counter = _counter;
                  if (createdTimestamp != "") {
                    counters[0].createdtimeStamp = createdTimestamp;
                  }
                }
                if (_timer != null && _timer.isActive) {
                  _timer.cancel();
                }
                Navigator.pop(context, counters);
              },
            ),
            actions: <Widget>[
              Row(
                children: [
                  _counter != 0
                      ? IconButton(
                          icon: Icon(Icons.restore),
                          iconSize: 30.0,
                          onPressed: () async {
                            showAlertDialog(
                                context,
                                "Reset Counter",
                                "This will reset the counter value to '0'.\n"
                                    "The old value of the counter will be saved in the history. You cannot undo this operation.",
                                0);
                          },
                        )
                      : Text(''),
                  IconButton(
                    icon: Icon(Icons.settings),
                    iconSize: 30.0,
                    onPressed: () async {
                      final List<CounterInfo> result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                CounterStats(counterId: counters[0].counterId)),
                      );
                      setState(() {
                        if (result != null) {
                          counterInfoName = result[0].counterName;
                          if (result[0].createdtimeStamp != "" &&
                              result[0].counter != 0) {
                            createdTimestamp = result[0].createdtimeStamp;
                            _counter = result[0].counter;
                          }
                        }
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          body: isLoading
              ? SingleChildScrollView(
                  child: Card(
                    color: _isDark ? Colors.grey[850] : Colors.grey[300],
                    child: SafeArea(
                      child: Column(
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(5.0, 30.0, 10.0, 0.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 350.0,
                                      child: Text(
                                        counterInfoName,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        softWrap: false,
                                        style: TextStyle(
                                          color: _isDark
                                              ? Colors.white
                                              : Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 35.0,
                                          letterSpacing: 2.0,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10.0),
                                Container(
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints.tightFor(
                                        width: 200, height: 120),
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        _incrementCounter();
                                      },
                                      label: Text('Add'),
                                      icon: Icon(
                                        Icons.add_circle_outline_sharp,
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        primary: _isDark
                                            ? Colors.blueGrey[700]
                                            : Colors.pink[900],
                                        textStyle: TextStyle(
                                          fontSize: 22.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 15.0),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      //width: 120.0,
                                      child: Text(
                                        _counter.toString(),
                                        overflow: TextOverflow.visible,
                                        style: TextStyle(
                                          fontSize: 70.0,
                                          letterSpacing: 2.0,
                                          fontWeight: FontWeight.bold,
                                          color: _isDark
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 15.0),
                                Container(
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints.tightFor(
                                        width: 300, height: 120),
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        if (_counter != 0) {
                                          _decrementCounter();
                                        } else {
                                          showAlertDialog(
                                              context,
                                              "Remove Counter",
                                              "The counter value should be more than '0'.",
                                              1);
                                        }
                                      },
                                      label: Text('Remove'),
                                      icon: Icon(
                                        Icons.remove_circle_outline_sharp,
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        primary: _isDark
                                            ? Colors.blueGrey[700]
                                            : Colors.pink[900],
                                        textStyle: TextStyle(
                                          fontSize: 22.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 80.0),
                          Container(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.bottomLeft,
                                      child: Text(
                                        'Last Updated On',
                                        style: TextStyle(
                                            fontSize: 14.0,
                                            color: _isDark
                                                ? Colors.white
                                                : Colors.black,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.bottomRight,
                                      child: Text(
                                        'Last Updated Timer',
                                        style: TextStyle(
                                            fontSize: 14.0,
                                            color: _isDark
                                                ? Colors.white
                                                : Colors.black,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.bottomLeft,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.update,
                                          color: _isDark
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                        SizedBox(
                                          width: 4.0,
                                        ),
                                        Text(
                                          lastUpdatedtimestamp,
                                          style: TextStyle(
                                              fontSize: 15.0,
                                              color: _isDark
                                                  ? Colors.white
                                                  : Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.timelapse,
                                        color: _isDark
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                      SizedBox(
                                        width: 4.0,
                                      ),
                                      counters.length > 0
                                          ? Contstants.displayTimer(duration,
                                              lastUpdatedtimestamp, _isDark)
                                          : Text(""),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : Center(
                  child: SpinKitFadingFour(
                    color: Colors.blue,
                    size: 50.0,
                  ),
                ),
        ),
      ),
    );
  }

  showAlertDialog(
      BuildContext context, String header, String message, int isMessageOnly) {
    // show the dialog
    showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        backgroundColor: _isDark ? Colors.grey[850] : Colors.grey[300],
        title: Center(
          child: Text(
            header,
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.w700,
              color: _isDark ? Colors.white : Colors.black.withOpacity(0.5),
            ),
          ),
        ),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 16.0,
              color: _isDark ? Colors.white : Colors.black.withOpacity(0.5),
              fontWeight: FontWeight.w500),
        ),
        actions: <Widget>[
          isMessageOnly == 0
              ? new ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: _isDark
                        ? Colors.blueGrey[700]
                        : Colors.pink[900], // background
                  ),
                  onPressed: () {
                    updateResetCounters();
                    Navigator.pop(context, counters);
                  },
                  child: Text("Reset"))
              : Text(""),
          SizedBox(height: 16),
          isMessageOnly == 0
              ? new ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: _isDark
                        ? Colors.blueGrey[700]
                        : Colors.pink[900], // background
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text("Cancel"))
              : new ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: _isDark
                        ? Colors.blueGrey[700]
                        : Colors.pink[900], // background
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text("Ok"))
        ],
      ),
    );
  }
}
