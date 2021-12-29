import 'package:flutter/material.dart';
import 'package:my_counter/custom/constants.dart';
import 'package:my_counter/models/CounterInfo.dart';
import 'package:my_counter/pages/counter_statitics.dart';
import 'package:my_counter/services/counter_dbhelper.dart';
import 'package:my_counter/services/counter_sharedpref.dart';

class ArchieveCounters extends StatefulWidget {
  @override
  _ArchieveCountersState createState() => _ArchieveCountersState();
}

class _ArchieveCountersState extends State<ArchieveCounters> {
  List<CounterInfo> counters = [];
  var _counters;
  bool _isDark = false;
  CounterDBHelper _counterDBHelper = CounterDBHelper();
  @override
  void initState() {
    _counterDBHelper.initializeDatabase().then((value) {
      print('------database intialized');
      _loadArchiveCounter();
    });
    getSFvalue();
    super.initState();
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

  void _loadArchiveCounter() async {
    counters.clear();
    _counters = await _counterDBHelper.getArchiveCounters();
    print('query all rows:');
    _counters.forEach(print);
    _counters.forEach((element) {
      counters.add(element);
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      darkTheme: Contstants.getTheme("dark"),
      theme: Contstants.getTheme("light"),
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      home: Center(
        child: Scaffold(
            backgroundColor: _isDark ? Colors.grey[850] : Colors.white,
            appBar: AppBar(
              title: Text('Archive Counters List'),
              centerTitle: true,
              leading: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.arrow_back)),
              // automaticallyImplyLeading: false,
              backgroundColor:
                  _isDark ? Colors.blueGrey : Colors.blueAccent[200],
            ),
            body: counters.length <= 0
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
                          "You don't have any Archive counters. \n\n"
                          "",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: _isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ],
                  )
                : Stack(children: [
                    ListView.builder(
                      itemCount: counters.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 1.0, horizontal: 4.0),
                          child: Card(
                            color: Colors.grey[300],
                            margin: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
                            child: InkWell(
                              splashColor: Colors.white,
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => CounterStats(
                                          counterId:
                                              counters[index].counterId)),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    ListTile(
                                      title: Row(
                                        children: [
                                          Text(
                                            counters[index].counterName,
                                            style: TextStyle(
                                              fontSize: 30.0,
                                              color: Colors.pink[900],
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 5.0,
                                          ),
                                          Text(
                                            "(" +
                                                counters[index]
                                                    .counter
                                                    .toString() +
                                                ")",
                                            style: TextStyle(
                                              fontSize: 30.0,
                                              color: Colors.pink[900],
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      trailing: Icon(Icons.fast_forward_sharp),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ])),
      ),
    );
  }
}
