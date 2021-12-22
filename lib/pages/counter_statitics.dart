import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:my_counter/custom/constants.dart';
import 'package:my_counter/models/CounterInfo.dart';
import 'package:my_counter/models/CounterInfoHistory.dart';
import 'package:my_counter/models/ResetCounterInfo.dart';
import 'package:my_counter/pages/home.dart';
import 'package:my_counter/pages/loading.dart';
import 'package:my_counter/services/counter_dbhelper.dart';

class CounterStats extends StatefulWidget {
  final int counterId;
  CounterStats({this.counterId});
  @override
  _CounterStatsState createState() => _CounterStatsState();
}

class _CounterStatsState extends State<CounterStats> {
  CounterDBHelper _counterDBHelper = CounterDBHelper();
  Duration lastUpdatedduration = Duration();
  Duration createdOnduration = Duration();
  Duration lastResetOnduration = Duration();
  Duration archiveduration = Duration();
  Timer _timer;
  List<CounterInfo> counters = [];
  var _counters;
  List<CounterInfoHistory> historyCounters = [];
  var _historyCounters;
  List<ResetCounterInfo> resetCounters = [];
  var _resetCounters;
  String counterName = "";
  String counterValue = "";
  String counterColor = "";
  String counterCreatedTimestamp = "";
  String counterlastTimestamp = "";
  int isDeleted = 1;
  String archiveTimestamp = "";
  int isReset = 1;
  TextEditingController textFieldController = TextEditingController();
  TextEditingController textFieldCreateController = TextEditingController();
  TextEditingController textFieldlastUpdateController = TextEditingController();
  String lastResettimestamp = "";
  bool isLoadingpage = false;
  bool isLoading = false;
  int rawDeleted = 0;
  @override
  void initState() {
    super.initState();
    _counterDBHelper.initializeDatabase().then((value) {
      _loadHistoryCounter();
      _getCounterByid();
      _loadResetCounter();
    });
  }

  _updateCounters(String counterName) async {
    DateTime timestamp = DateTime.now();
    DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    setState(() {
      _counterDBHelper.updateCounters(
          counters[0].counterId, counterName, formatter.format(timestamp));
    });
  }

  void _loadHistoryCounter() async {
    historyCounters.clear();
    _historyCounters =
        await _counterDBHelper.getHistoryCounters(widget.counterId);
    print('query all rows:');
    _historyCounters.forEach(print);
    _historyCounters.forEach((element) {
      historyCounters.add(element);
      if (mounted) setState(() {});
    });
  }

  void _loadResetCounter() async {
    resetCounters.clear();
    _resetCounters = await _counterDBHelper.getResetCounters(widget.counterId);
    print('query all rows:');
    _resetCounters.forEach(print);
    _resetCounters.forEach((element) {
      resetCounters.add(element);
      if (mounted)
        setState(() {
          isReset =
              resetCounters.length > 1 ? resetCounters[1].isCounterreseted : 1;
        });
    });
    if (isReset == 0) {
      lastResettimestamp =
          resetCounters.length > 1 ? resetCounters[1].endtimeStamp : "";
      if (lastResettimestamp != "") {
        lastResetOnduration =
            Contstants.getDuration(lastResetOnduration, lastResettimestamp);
      }
    }
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
          counterName = counters[0].counterName;
          counterValue = counters[0].counter.toString();
          counterColor = counters[0].counterName;
          counterCreatedTimestamp = counters[0].createdtimeStamp;
          counterlastTimestamp = counters[0].lasttimeStamp;
          isDeleted = counters[0].isDeleted;
          archiveTimestamp = counters[0].archiveOn;
        });
      isLoadingpage = true;
    });

    setState(() {
      counterlastTimestamp =
          counters[0].lasttimeStamp != null ? counters[0].lasttimeStamp : "";
      counterCreatedTimestamp = counters[0].createdtimeStamp != null
          ? counters[0].createdtimeStamp
          : "";

      lastUpdatedduration =
          Contstants.getDuration(lastUpdatedduration, counterlastTimestamp);
      createdOnduration =
          Contstants.getDuration(createdOnduration, counterCreatedTimestamp);
      if (isDeleted == 0) {
        archiveduration =
            Contstants.getDuration(archiveduration, archiveTimestamp);
      }
    });

    startTime();
  }

  void startTime() {
    _timer = Timer.periodic(Duration(seconds: 1), (_) => addTimer());
  }

  addTimer() {
    final addSeconds = 1;
    setState(() {
      final lastUpdateseconds = lastUpdatedduration.inSeconds + addSeconds;
      final createdseconds = createdOnduration.inSeconds + addSeconds;
      lastUpdatedduration = Duration(seconds: lastUpdateseconds);
      createdOnduration = Duration(seconds: createdseconds);

      if (isReset == 0) {
        final lastResetOnseconds = lastResetOnduration.inSeconds + addSeconds;
        lastResetOnduration = Duration(seconds: lastResetOnseconds);
      }
      if (isDeleted == 0) {
        final archiveseconds = archiveduration.inSeconds + addSeconds;
        archiveduration = Duration(seconds: archiveseconds);
      }
    });
  }

  _updateArchiveInfo() async {
    DateTime timestamp = DateTime.now();
    DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    setState(() {
      _counterDBHelper.updateArchive(
          counters[0].counterId, formatter.format(timestamp));
    });
  }

  Future<int> _removeCounter() async {
    return await _counterDBHelper.delete(counters[0].counterId);
  }

  _updateCounterDates(
      String createdDatetime, String lastDatetime, int counter) async {
    _counterDBHelper.updateCountersDateTime(
        counters[0].counterId, createdDatetime, lastDatetime, counter);
  }

  void handleClick(String value) async {
    switch (value) {
      case 'Edit':
        textFieldController.text = counters[0].counterName;
        _showSettingpanel(counters[0].counterId, 'Edit');
        // final List<CounterInfo> result = await Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //         builder: (context) =>
        //             Update(counterId: counters[0].counterId)));
        // setState(() {
        //   if (result != null && result.length > 0) {
        //     counterName = result[0].counterName;
        //   }
        // });
        break;
      case 'Archive':
        _updateArchiveInfo();
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Home()));
        break;
      case 'Delete':
        showAlertDialog(
            context,
            "Delete Counter",
            "This will completely remove the counter including its whole history and statistics. You can't undo this operation. \n"
                "You can do Archive instead of Deleting the Counter",
            "Delete");
        break;
      case 'Update Dates':
        textFieldCreateController.text = counterCreatedTimestamp;
        textFieldlastUpdateController.text = counterlastTimestamp;
        _showSettingpanel(counters[0].counterId, 'Update Dates');
        break;
    }
  }

  @override
  void dispose() {
    super.dispose();
    textFieldCreateController.clear();
    textFieldlastUpdateController.clear();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: DefaultTabController(
        length: 3,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            appBar: AppBar(
              bottom: const TabBar(
                tabs: [
                  Tab(
                    child: Text('Counter Info'),
                  ),
                  Tab(
                    child: Text('Reset Counter History'),
                  ),
                  Tab(
                    child: Text('Counter Update History'),
                  ),
                ],
              ),
              actions: [
                RotatedBox(
                  quarterTurns: 4,
                  child: Container(
                    child: PopupMenuButton<String>(
                      //color: Colors.amber[300],
                      onSelected: handleClick,
                      itemBuilder: (BuildContext context) {
                        if (isDeleted == 1) {
                          return {'Edit', 'Update Dates', 'Archive', 'Delete'}
                              .map((String choice) {
                            return PopupMenuItem<String>(
                              value: choice,
                              child: Container(child: Text(choice)),
                            );
                          }).toList();
                        } else {
                          return {'Delete'}.map((String choice) {
                            return PopupMenuItem<String>(
                              value: choice,
                              child: Container(child: Text(choice)),
                            );
                          }).toList();
                        }
                      },
                    ),
                  ),
                ),
              ],
              title: Text(counterName),
              leading: IconButton(
                  onPressed: () {
                    Navigator.pop(context, counters);
                  },
                  icon: Icon(Icons.arrow_back)),
            ),
            body: GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(new FocusNode());
              },
              child: TabBarView(
                children: [
                  // Counter Info
                  isLoadingpage
                      ? Card(
                          color: Colors.grey[300],
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Counter Name',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 19.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          counterName != null
                                              ? counterName
                                              : "",
                                          textAlign: TextAlign.end,
                                          style: TextStyle(
                                            fontSize: 16.0,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 20.0,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Counter Value',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 19.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Text(
                                        counterValue,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 16.0,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                  // SizedBox(
                                  //   height: 20.0,
                                  // ),
                                  // Row(
                                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  //   children: [
                                  //     Text(
                                  //       'Counter Color',
                                  //       textAlign: TextAlign.center,
                                  //       style: TextStyle(
                                  //         fontSize: 19.0,
                                  //         fontWeight: FontWeight.bold,
                                  //         color: Colors.black,
                                  //       ),
                                  //     ),
                                  //     Text(
                                  //       "counterName",
                                  //       textAlign: TextAlign.center,
                                  //       style: TextStyle(
                                  //         fontSize: 16.0,
                                  //         color: Colors.black,
                                  //       ),
                                  //     ),
                                  //   ],
                                  // ),
                                  SizedBox(
                                    height: 20.0,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Counter Last Updated On",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 19.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Text(
                                        counterlastTimestamp,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 16.0,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Align(
                                      alignment: Alignment.centerRight,
                                      child: counters.length > 0
                                          ? Contstants.displayTimer(
                                              lastUpdatedduration,
                                              counterlastTimestamp)
                                          : Text("")),
                                  SizedBox(
                                    height: 20.0,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Counter Created On',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 19.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Text(
                                        counterCreatedTimestamp,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 16.0,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Align(
                                      alignment: Alignment.centerRight,
                                      child: counters.length > 0
                                          ? Contstants.displayTimer(
                                              createdOnduration,
                                              counterCreatedTimestamp)
                                          : Text("")),
                                  isReset == 0
                                      ? Column(
                                          children: [
                                            SizedBox(
                                              height: 30.0,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  'Number of Resets',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 19.0,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                Align(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: Text(
                                                    (_resetCounters.length - 1)
                                                        .toString(),
                                                    //textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontSize: 16.0,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 30.0,
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 30.0,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  'Last Resetted On',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 19.0,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                Text(
                                                  resetCounters.length > 1
                                                      ? resetCounters[1]
                                                          .endtimeStamp
                                                      : "",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 16.0,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: counters.length > 0
                                                    ? Contstants.displayTimer(
                                                        lastResetOnduration,
                                                        resetCounters[1]
                                                            .endtimeStamp)
                                                    : Text("")),
                                            SizedBox(
                                              height: 30.0,
                                            ),
                                          ],
                                        )
                                      : Text(""),
                                  isDeleted == 0
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Counter Archived On',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 19.0,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                            Text(
                                              archiveTimestamp,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 16.0,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        )
                                      : Text(""),
                                  isDeleted == 0
                                      ? Align(
                                          alignment: Alignment.centerRight,
                                          child: counters.length > 0
                                              ? Contstants.displayTimer(
                                                  archiveduration,
                                                  archiveTimestamp)
                                              : Text(""))
                                      : Text(""),
                                  SizedBox(
                                    height: 30.0,
                                  ),

                                  // Align(
                                  //   alignment: Alignment.center,
                                  //   // ignore: deprecated_member_use
                                  //   child: FlatButton(
                                  //     color: Colors.amber,
                                  //     onPressed: () async {
                                  //       // Navigator.push(
                                  //       //   context,
                                  //       //   MaterialPageRoute(
                                  //       //       builder: (context) => Update(
                                  //       //           counterId: counters[0].counterId)),
                                  //     },
                                  //     child: Text(
                                  //       "Edit",
                                  //       style: TextStyle(
                                  //         color: Colors.purple,
                                  //       ),
                                  //     ),
                                  //   ),
                                  // ),
                                  // SizedBox(
                                  //   width: 25.0,
                                  // ),
                                ],
                              ),
                            ),
                          ))
                      : Center(
                          child: SpinKitFadingFour(
                            color: Colors.blue,
                            size: 50.0,
                          ),
                        ),
                  // Reset Counter History
                  isLoadingpage
                      ? Card(
                          color: Colors.grey[300],
                          child: resetCounters.length <= 0
                              ? Container(
                                  child: Icon(Icons.emoji_nature_outlined))
                              : ListView.builder(
                                  itemCount: resetCounters.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.all(6.0),
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                  (resetCounters.length - index)
                                                          .toString() +
                                                      ".",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 15.0,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                SizedBox(width: 30.0),
                                                Text(
                                                  resetCounters[index]
                                                              .resetCounter !=
                                                          null
                                                      ? resetCounters[index]
                                                          .resetCounter
                                                          .toString()
                                                      : "0",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 35.0,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                SizedBox(width: 20.0),
                                                Expanded(
                                                  child: Align(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: Text(
                                                      resetCounters[index]
                                                                  .endtimeStamp !=
                                                              null
                                                          ? resetCounters[index]
                                                              .endtimeStamp
                                                          : "",
                                                      textAlign: TextAlign.end,
                                                      style: TextStyle(
                                                        fontSize: 16.0,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 20.0,
                                            ),
                                          ]),
                                    );
                                  },
                                ))
                      : Center(
                          child: SpinKitFadingFour(
                            color: Colors.blue,
                            size: 50.0,
                          ),
                        ),
                  // Counter Update History
                  isLoadingpage
                      ? Card(
                          color: Colors.grey[300],
                          child: historyCounters.length <= 0
                              ? Container(
                                  child: Icon(Icons.emoji_nature_outlined))
                              : ListView.builder(
                                  itemCount: historyCounters.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                  (historyCounters.length -
                                                              index)
                                                          .toString() +
                                                      ".",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 15.0,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                SizedBox(width: 20.0),
                                                Expanded(
                                                  child: Text(
                                                    historyCounters[index]
                                                                .counter !=
                                                            null
                                                        ? historyCounters[index]
                                                            .counter
                                                        : "0",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontSize: 20.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 20.0),
                                                Expanded(
                                                  child: Text(
                                                    historyCounters[index]
                                                                .lasttimeStamp !=
                                                            null
                                                        ? historyCounters[index]
                                                            .lasttimeStamp
                                                        : "",
                                                    textAlign: TextAlign.end,
                                                    style: TextStyle(
                                                      fontSize: 16.0,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 20.0,
                                            ),
                                          ]),
                                    );
                                  },
                                ))
                      : Center(
                          child: SpinKitFadingFour(
                            color: Colors.blue,
                            size: 50.0,
                          ),
                        ),

                  // Icon(Icons.directions_bike),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  showAlertDialog(
      BuildContext context, String title, String description, String value) {
    // set up the AlertDialog
    Stack alert = Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(
            top: 16.0,
            bottom: 16.0,
            left: 16.0,
            right: 16.0,
          ),
          margin: EdgeInsets.only(top: 66.0),
          decoration: new BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            shape: BoxShape.rectangle,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // To make the card compact
            children: <Widget>[
              Text(
                title,
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 24.0),
              value == 'Delete'
                  ? Align(
                      alignment: Alignment.bottomRight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          // ignore: deprecated_member_use
                          FlatButton(
                            color: Colors.amber,
                            onPressed: () {
                              Navigator.of(context)
                                  .pop(); // To close the dialog
                            },
                            child: Text(
                              "Close",
                              style: TextStyle(
                                color: Colors.purple,
                              ),
                            ),
                          ),
                          // ignore: deprecated_member_use
                          FlatButton(
                            color: Colors.amber,
                            onPressed: () async {
                              rawDeleted = await _removeCounter();
                              Navigator.of(context).pop();
                              Loading();
                              if (rawDeleted > 0) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Home()));
                              }
                            },
                            child: Text(
                              "OK",
                              style: TextStyle(
                                color: Colors.purple,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Align(
                      alignment: Alignment.bottomRight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          // ignore: deprecated_member_use
                          FlatButton(
                            color: Colors.amber,
                            onPressed: () async {
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              "OK",
                              style: TextStyle(
                                color: Colors.purple,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ],
          ),
        ),
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            child: alert);
      },
    );
  }

  void _showSettingpanel(int id, String value) {
    DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    DateTime selectedDate = new DateTime.now();
    Future<DateTime> _selectDate(
        BuildContext context, DateTime updateDate) async {
      final now = new DateTime.now();
      final DateTime pickedDate = await showDatePicker(
          context: context,
          initialDate: updateDate,
          firstDate: DateTime(1969, 1, 1, 11, 33),
          lastDate: DateTime.now());

      if (pickedDate != null && pickedDate != selectedDate)
        setState(() {
          updateDate = new DateTime(pickedDate.year, pickedDate.month,
              pickedDate.day, now.hour, now.minute, now.second);
        });

      return updateDate;
    }

    if (value == 'Edit') {
      showModalBottomSheet(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          context: context,
          isScrollControlled: true,
          builder: (context) => SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text(
                          'Counter Name',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            letterSpacing: 2.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              TextField(
                                decoration:
                                    InputDecoration(hintText: 'Counter Name'),
                                autofocus: true,
                                controller: textFieldController,
                                maxLength: 30,
                              ),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  _updateCounters(textFieldController.text);
                                  counterName = textFieldController.text;
                                  counters[0].counterName = counterName;
                                  Navigator.pop(context);
                                  //}
                                },
                                label: Text('Update'),
                                icon: Icon(
                                  Icons.update,
                                ),
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.pink[900],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // SizedBox(height: 10),
                    ],
                  ),
                ),
              ));
    } else {
      showModalBottomSheet(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          context: context,
          isScrollControlled: true,
          builder: (context) => SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        'Update Created and Last Updated Date of Counter',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          letterSpacing: 2.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              TextField(
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                ),
                                readOnly: true,
                                enabled: false,
                                controller: textFieldCreateController,
                                focusNode: FocusNode(),
                                enableInteractiveSelection: false,
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: ElevatedButton(
                                    onPressed: () async {
                                      selectedDate = await _selectDate(
                                          context,
                                          DateTime.parse(
                                              textFieldCreateController.text));

                                      setState(() {
                                        textFieldCreateController.text =
                                            formatter.format(selectedDate);
                                      });
                                    },
                                    child: Text('Select for Created Date')),
                              ),
                              TextField(
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                ),
                                readOnly: true,
                                enabled: false,
                                controller: textFieldlastUpdateController,
                                focusNode: FocusNode(),
                                enableInteractiveSelection: false,
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: ElevatedButton(
                                    onPressed: () async {
                                      selectedDate = await _selectDate(
                                          context,
                                          DateTime.parse(
                                              textFieldlastUpdateController
                                                  .text));

                                      setState(() {
                                        textFieldlastUpdateController.text =
                                            formatter.format(selectedDate);
                                      });
                                    },
                                    child:
                                        Text('Select for Last Updated Date')),
                              ),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  if (DateTime.parse(
                                          textFieldlastUpdateController.text)
                                      .isAfter(DateTime.parse(
                                          textFieldCreateController.text))) {
                                    setState(() {
                                      createdOnduration =
                                          Contstants.getDuration(
                                              createdOnduration,
                                              textFieldCreateController.text);
                                      lastUpdatedduration =
                                          Contstants.getDuration(
                                              lastUpdatedduration,
                                              textFieldlastUpdateController
                                                  .text);
                                      counterCreatedTimestamp =
                                          textFieldCreateController.text;
                                      counterlastTimestamp =
                                          textFieldlastUpdateController.text;
                                      counterValue =
                                          createdOnduration.inDays.toString();
                                      counters[0].createdtimeStamp =
                                          textFieldCreateController.text;
                                      counters[0].lasttimeStamp =
                                          textFieldlastUpdateController.text;
                                      counters[0].counter =
                                          createdOnduration.inDays;
                                    });

                                    _updateCounterDates(
                                        textFieldCreateController.text,
                                        textFieldlastUpdateController.text,
                                        createdOnduration.inDays);

                                    Navigator.pop(context);
                                  } else {
                                    showAlertDialog(
                                        context,
                                        "Update the Counter Dates",
                                        "The Created Counter Date is less than Last Updated Counter Date.",
                                        "Update Dates");
                                  }
                                },
                                label: Text('Update the Counter Dates'),
                                icon: Icon(
                                  Icons.update_sharp,
                                ),
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.pink[900],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ));
    }
  }
}
