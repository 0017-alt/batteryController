import 'dart:async';

import 'package:process_run/shell.dart';

import 'package:flutter/material.dart';

void main() {
  return runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  var _result = '';
  var temp = '';

  void _code() async {
    var shell = Shell();
    var result = await shell.run('''
      #Display
      osascript -e 'do shell script "sudo powermetrics -n 1 | grep -e die" with administrator privileges'
      ''');

    setState(() {
      _result = result.outText;
    });

    _result = _result.substring(21,26);
  }

  void _return() {
    setState(() {
      _result = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_result == '') {
      return MaterialApp(
        title: 'Flutter Demo',
        home: Scaffold(
          body: const Center(
            child: Text('No temperature information is obtained.'),
          ),

          floatingActionButton: FloatingActionButton(
            onPressed: _code,
            tooltip: 'measure temperature',
            child: const Icon(Icons.arrow_forward),
          ),
        ),
      );
    }

    if (double.parse(_result) > 60) {
      return MaterialApp(
        title: 'Flutter Demo',
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget> [
                Text('CPU temperature:'),
                Text(_result),
                Text('[Hot]'),
              ],
            ),
          ),

          floatingActionButton: FloatingActionButton(
            onPressed: _return,
            tooltip: 'return',
            child: const Icon(Icons.add),
          ),
        ),
      );
    } else {
      return MaterialApp(
        title: 'Flutter Demo',
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget> [
                Text('CPU temperature:'),
                Text(_result),
                Text('[cool]'),
              ],
            ),
          ),

          floatingActionButton: FloatingActionButton(
            onPressed: _return,
            tooltip: 'back',
            child: const Icon(Icons.arrow_back),
          ),
        ),
      );
    }
  }
}
