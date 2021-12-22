import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatefulWidget {
  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  @override
  void initState() {
    super.initState();
    _home();
  }

  _home() async{
    await Future.delayed(Duration(seconds: 3));
    Navigator.pushNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return
      Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('Daily Counters'),
          centerTitle: true,
          backgroundColor: Colors.blueAccent[200],
          elevation: 0.0,
          automaticallyImplyLeading: false,
        ),
        body:  Padding(
          padding: const EdgeInsets.all(80.0),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SpinKitWave(
                  color: Colors.indigo[900],
                  size: 50.0,
                ),
                SizedBox(height: 50.0),
                Container(
                  child: Row(
                    children:  [
                      Text('Made with',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                          letterSpacing: 2.0,
                        ),
                      ),
                      SizedBox(width: 10.0),
                      ColorFiltered(
                        child:Image.asset(
                          "images/heart3.jpg", width: 25.0,height: 25.0,
                        ),
                        colorFilter: ColorFilter.mode(Colors.blueAccent, BlendMode.saturation),
                      ),
                      SizedBox(width: 10.0),
                      Text('in',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                          letterSpacing: 2.0,
                        ),
                      ),
                      SizedBox(width: 10.0),
                      Image.asset('images/in.png',
                        height: 50.0,
                        width: 50.0,),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }
}