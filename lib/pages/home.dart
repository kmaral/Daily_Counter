import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:my_counter/pages/UpdateCounter.dart';
import 'package:my_counter/pages/about.dart';
import 'package:my_counter/pages/archive_list.dart';
import 'package:my_counter/pages/save.dart';
import 'package:my_counter/services/counter_dbhelper.dart';
import '../models/CounterInfo.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<CounterInfo> counters = [];
  var _counters;
  bool isLoading = false;
  CounterDBHelper _counterDBHelper = CounterDBHelper();
  @override
  void initState() {
    _counterDBHelper.initializeDatabase().then((value) {
      print('------database intialized');
      _loadCounter();
    });
    isLoading = true;
    super.initState();
  }

  void _loadCounter() async {
    counters.clear();
    _counters = await _counterDBHelper.getCounters();
    print('query all rows:');
    _counters.forEach(print);
    _counters.forEach((element) {
      counters.add(element);
      if (mounted) setState(() {});
    });
    isLoading = true;
  }

  saveCounters(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Save()),
    );
  }

  Future<bool> _onBackPressed() {
    return showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Are you sure?'),
            content: new Text('Do you want to exit an App'),
            actions: <Widget>[
              new ElevatedButton(
                  child: Text("NO"),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  }),
              SizedBox(height: 16),
              new ElevatedButton(
                  child: Text("YES"),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                    Future.delayed(const Duration(milliseconds: 1), () {
                      SystemChannels.platform
                          .invokeMethod('SystemNavigator.pop');
                    });
                  }),
            ],
          ),
        ) ??
        false;
  }

  void handleClick(String value) {
    switch (value) {
      case 'Archive List':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ArchieveCounters()),
        );
        break;
      case 'About Daily Counter':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => About()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Center(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                title: Text('Active Counter List'),
                centerTitle: true,
                automaticallyImplyLeading: false,
                actions: [
                  // IconButton(
                  //     onPressed: () {
                  //       Navigator.push(
                  //         context,
                  //         MaterialPageRoute(builder: (context) => Settings()),
                  //       );
                  //     },
                  //     icon: Icon(Icons.settings)),
                  RotatedBox(
                    quarterTurns: 2,
                    child: Container(
                      child: PopupMenuButton<String>(
                        //color: Colors.amber[300],
                        onSelected: handleClick,
                        itemBuilder: (BuildContext context) {
                          return {'Archive List', 'About Daily Counter'}
                              .map((String choice) {
                            return PopupMenuItem<String>(
                              value: choice,
                              child: Container(child: Text(choice)),
                            );
                          }).toList();
                        },
                      ),
                    ),
                  ),
                ],
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  saveCounters(context);
                },
                child: Icon(Icons.add_box),
                backgroundColor: Colors.grey[800],
              ),
              body: isLoading && counters.length <= 0
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 2.0,
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            "You don't have any exitsting counters. \n\n"
                            "Add a counter by hitting the plus button below.",
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    )
                  : isLoading
                      ? Stack(children: [
                          ListView.builder(
                            itemCount: counters.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 1.0, horizontal: 4.0),
                                child: Card(
                                  color: Colors.grey[300],
                                  margin: EdgeInsets.fromLTRB(
                                      16.0, 16.0, 16.0, 0.0),
                                  child: InkWell(
                                    splashColor: Colors.white,
                                    onTap: () async {
                                      final List<CounterInfo> result =
                                          await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => UpdateCounter(
                                                counterId:
                                                    counters[index].counterId)),
                                      );
                                      setState(() {
                                        if (result != null &&
                                            result.length > 0) {
                                          counters[index].lasttimeStamp =
                                              result[0].lasttimeStamp;
                                          counters[index].counter =
                                              result[0].counter;
                                          counters[index].counterName =
                                              result[0].counterName;
                                          counters[index].createdtimeStamp =
                                              result[0].createdtimeStamp;
                                        }
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          ListTile(
                                            title: Text(
                                              counters[index].counterName,
                                              style: TextStyle(
                                                fontSize: 22.0,
                                                color: Colors.pink[900],
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            subtitle: Text(
                                              'Count: ' +
                                                  counters[index]
                                                      .counter
                                                      .toString(),
                                              style: TextStyle(
                                                fontSize: 18.0,
                                                color: Colors.pink[900],
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            trailing:
                                                Icon(Icons.fast_forward_sharp),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                12.0, 0.0, 0.0, 0.0),
                                            child: Container(
                                              child: Column(
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(
                                                        'Created Date : ',
                                                        style: TextStyle(
                                                          fontSize: 15.0,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              Colors.grey[800],
                                                        ),
                                                      ),
                                                      Text(
                                                        counters[index]
                                                            .createdtimeStamp,
                                                        style: TextStyle(
                                                          fontSize: 15.0,
                                                          color:
                                                              Colors.grey[800],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                            .fromLTRB(
                                                        0.0, 5.0, 0.0, 5.0),
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          'Last Updated : ',
                                                          style: TextStyle(
                                                            fontSize: 15.0,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors
                                                                .grey[800],
                                                          ),
                                                        ),
                                                        Text(
                                                          counters[index]
                                                              .lasttimeStamp,
                                                          style: TextStyle(
                                                            fontSize: 15.0,
                                                            color: Colors
                                                                .grey[800],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ])
                      : Center(
                          child: SpinKitFadingFour(
                            color: Colors.blue,
                            size: 50.0,
                          ),
                        )),
        ),
      ),
    );
  }
}
