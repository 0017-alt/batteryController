import 'dart:async';
import 'package:flutter/material.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:process_run/shell.dart';
import 'dart:io';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final IOSInitializationSettings initializationSettingsIOS =
      IOSInitializationSettings(
    requestSoundPermission: true,
    requestBadgePermission: true,
    requestAlertPermission: true,
  );

  //initializationSettingsのオブジェクト作成
  final InitializationSettings initializationSettings = InitializationSettings(
    iOS: initializationSettingsIOS,
    android: null,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
  );

  runApp(const MyApp());
}

class SampleData {
  String name;
  int value;

  SampleData({required this.name, required this.value});
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Battrey Controll Application'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

Future<int> getBatteryLevel() async {
  var battery = Battery();
  return battery.batteryLevel;
}

Future<BatteryState> getBatteryState() async {
  var battery = Battery();
  return battery.batteryState;
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  bool _offPoint = true;
  var _result = '30';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Timer.periodic(Duration(seconds: 10), (Timer timer) {
      _onTimer;
    });
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // バックグラウンドに遷移した時
      setState(() {});
    }
  }

  void _onTimer(Timer timer) {
    setState(() {});
  }

  void setNotificationOff() async {
    const IOSNotificationDetails iOSPlatformChannelSpecifics =
        IOSNotificationDetails(
            // sound: 'example.mp3',
            presentAlert: true,
            presentBadge: true,
            presentSound: true);
    NotificationDetails platformChannelSpecifics = const NotificationDetails(
      iOS: iOSPlatformChannelSpecifics,
      android: null,
    );
    await flutterLocalNotificationsPlugin.show(
        0, 'ButteryController', '充電をオフにしてください', platformChannelSpecifics);
  }

  void setNotificationOn() async {
    const IOSNotificationDetails iOSPlatformChannelSpecifics =
        IOSNotificationDetails(
            // sound: 'example.mp3',
            presentAlert: true,
            presentBadge: true,
            presentSound: true);
    NotificationDetails platformChannelSpecifics = const NotificationDetails(
      iOS: iOSPlatformChannelSpecifics,
      android: null,
    );
    await flutterLocalNotificationsPlugin.show(
        1, 'ButteryController', '充電をオンにしてください', platformChannelSpecifics);
  }

  @override
  Widget build(BuildContext context) {
    return ui();
  }

  Widget ui() {
    return FutureBuilder(
        future: getBatteryLevel(),
        builder: (context, snapshot) {
          if (double.parse('${snapshot.data}') > 80.0 &&
              ifText() !=
                  Text("バッテリー減少中",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 32)) &&
              !_offPoint) {
            setNotificationOff();
            turnOff();
          } else if (double.parse('${snapshot.data}') < 30.0 &&
              ifText() ==
                  Text("バッテリー減少中",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 32)) &&
              _offPoint) {
            setNotificationOn();
            turnOn();
          }
          ;
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Text("Error: ${snapshot.error}");
            }
            if (!snapshot.hasData) {
              return Text("データが見つかりません");
            }
            return Scaffold(
              appBar: AppBar(
                title: Text(widget.title),
              ),
              body: Center(
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 50),
                    Text('充電状況',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20)),
                    SizedBox(height: 20),
                    ifText(),
                    SizedBox(height: 50),
                    graph('${snapshot.data}'),
                    SizedBox(height: 50),
                    SizedBox(
                        width: 100,
                        height: 50,
                        child: RaisedButton.icon(
                          icon: Icon(Icons.battery_charging_full),
                          label: Text("On"),
                          color: Colors.blue,
                          onPressed: _offPoint
                              ? null
                              : () {
                                  _offPoint = false;
                                  turnOn();
                                },
                        )),
                    SizedBox(
                        width: 100,
                        height: 50,
                        child: RaisedButton.icon(
                          icon: Icon(Icons.battery_std),
                          label: Text("Off"),
                          onPressed: !_offPoint
                              ? null
                              : () {
                                  _offPoint = true;
                                  turnOff();
                                },
                        ))
                  ],
                ),
              ),
            );
          } else {
            // 処理中の表示
            return const CircularProgressIndicator();
          }
        });
  }

  Widget graph(String data) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        PieChart(
          dataMap: <String, double>{"Battery": double.parse('${data}')},
          chartType: ChartType.ring,
          initialAngleInDegree: 0,
          animationDuration: Duration(milliseconds: 0),
          baseChartColor: Colors.white,
          colorList: <Color>[Colors.blue],
          chartLegendSpacing: 32,
          chartRadius: MediaQuery.of(context).size.width / 3.2,
          totalValue: 100,
          legendOptions: LegendOptions(
            legendPosition: LegendPosition.bottom,
          ),
        ),
        SizedBox(width: 50),
        getTemp()
      ],
    );
  }

  Widget ifText() {
    return FutureBuilder(
      future: getBatteryState(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          }
          if (!snapshot.hasData) {
            return Text("データが見つかりません");
          }
          return ifState('${snapshot.data}');
        } else {
          // 処理中の表示
          return const CircularProgressIndicator();
        }
      },
    );
  }

  Widget ifState(String state) {
    if (state == 'BatteryState.full') {
      return Text("満タン",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32));
    } else if (state == 'BatteryState.charging') {
      return Text("充電中",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32));
    } else if (state == 'BatteryState.discharging') {
      return Text("バッテリー減少中",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32));
    } else {
      return Text("読み込みできません",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32));
    }
  }

  void turnOn() async {
    String _content;
    String url =
        "https://api.switch-bot.com/v1.0/devices/6055F92B5E8A/commands";
    Map<String, String> headers = {
      'Authorization':
          '387b43f7ab27876063e11b29aa71fe78eb50f5606af4d97ec7fa329e8e5dfc44d0e472f5a020ee484a61646e162f784c',
      "Content-type": "application/json"
    };
    String body = json.encode({
      "command": "turnOn",
      "parameter": "default",
      "commandType": "command"
    });

    http.Response resp =
        await http.post(Uri.parse(url), headers: headers, body: body);
    if (resp.statusCode != 200) {
      setState(() {
        int statusCode = resp.statusCode;
        _content = "Failed to post $statusCode";
      });
      return;
    }
    setState(() {
      _content = resp.body;
    });
  }

  void turnOff() async {
    String _content;
    String url =
        "https://api.switch-bot.com/v1.0/devices/6055F92B5E8A/commands";
    Map<String, String> headers = {
      'Authorization':
          '387b43f7ab27876063e11b29aa71fe78eb50f5606af4d97ec7fa329e8e5dfc44d0e472f5a020ee484a61646e162f784c',
      "Content-type": "application/json"
    };
    String body = json.encode({
      "command": "turnOff",
      "parameter": "default",
      "commandType": "command"
    });

    http.Response resp =
        await http.post(Uri.parse(url), headers: headers, body: body);
    if (resp.statusCode != 200) {
      setState(() {
        int statusCode = resp.statusCode;
        _content = "Failed to post $statusCode";
      });
      return;
    }
    setState(() {
      _content = resp.body;
    });
  }

  void _code() async {
    var shell = Shell();
    var result = await shell.run('''
      #Display
      osascript -e 'do shell script "sudo powermetrics -n 1 | grep -e die" with administrator privileges'
      ''');

    setState(() {
      _result = result.outText;
    });

    _result = _result.substring(21, 26);
  }

  void _return() {
    setState(() {
      _result = '';
    });
  }

  Widget getTemp() {
    _code;
    if (_result == '') {
      return Text('No temperature information is obtained.');
    }

    if (double.parse(_result) > 60) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('CPU temperature:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32)),
          Text(_result + '℃',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32)),
          Text('[Hot]',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32)),
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('CPU temperature:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32)),
          Text(_result + '℃',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32)),
          Text('[Cool]',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32)),
        ],
      );
    }
  }
}
