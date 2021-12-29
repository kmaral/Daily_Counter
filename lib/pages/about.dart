import 'package:flutter/material.dart';
import 'package:launch_review/launch_review.dart';
import 'package:my_counter/custom/constants.dart';
import 'package:my_counter/services/counter_sharedpref.dart';

class About extends StatefulWidget {
  @override
  _AboutState createState() => _AboutState();
}

class _AboutState extends State<About> {
  bool _isDark = false;
  @override
  void initState() {
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      darkTheme: Contstants.getTheme("dark"),
      theme: Contstants.getTheme("light"),
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(
        backgroundColor: _isDark ? Colors.grey[850] : Colors.white,
        appBar: AppBar(
          title: Text('About Daily Counter'),
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
        body: Card(
          color: _isDark ? Colors.grey[850] : Colors.white,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(
                      "This Daily Counter (free) app started at the end of 2021 as a private non-commercial project \n"
                      "\n"
                      "This is our first Project as Team, there are multiple projects and mobile apps are in pipeline. \n"
                      "We will release based on user inputs and suggestions \n"
                      "Please support Krudaya !!!"
                      "\n"
                      "\n",
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w700,
                        color: _isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    Text(
                      "We've invested a lot of time in furhter development of this app and added very useful features.\n",
                      style: TextStyle(
                        fontSize: 14.0,
                        // fontWeight: FontWeight.w100,
                        color: _isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    Text(
                      "We will try to make this app updated and bug-free !!!. This can be achievable if you guys support",
                      style: TextStyle(
                        fontSize: 14.0,
                        // fontWeight: FontWeight.w100,
                        color: _isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Text(
                      "As the developer of this app We very much depend on your valuable positive and negative feedbacks. \n",
                      style: TextStyle(
                        fontSize: 14.0,
                        // fontWeight: FontWeight.w100,
                        color: _isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Text(
                      "It will be very helpful if you guys give ratings or comments "
                      "in the Google Playstore or sending mails to me (krudaya999@gmail.com).\n"
                      "We will make sure to accomdate as much as features into this app.\n"
                      "\n"
                      "\n"
                      "Cheers,"
                      "\n"
                      "Krudaya Team"
                      "\n"
                      "\n",
                      style: TextStyle(
                        fontSize: 14.0,
                        // fontWeight: FontWeight.w100,
                        color: _isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              // ignore: deprecated_member_use
              FlatButton(
                  color: _isDark ? Colors.blueGrey[700] : Colors.amber,
                  onPressed: () {
                    LaunchReview.launch(androidAppId: "krudaya.dailyCounter");
                    LaunchReview.launch();
                  },
                  child: Text(
                    'OPEN PLAYSTORE',
                    style: TextStyle(
                      color: _isDark ? Colors.white : Colors.black,
                    ),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
