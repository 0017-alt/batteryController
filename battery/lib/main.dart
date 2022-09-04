import 'dart:async';
import 'package:flutter/material.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  bool _offPoint = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Timer.periodic(Duration(seconds: 10), (Timer timer) {
      _onTimer;
      setState(() {});
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
    ui();
  }

  void _handleOnPaused() {}

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
            _offPoint = true;
            turnOff();
          } else if (double.parse('${snapshot.data}') < 30.0 &&
              ifText() ==
                  Text("バッテリー減少中",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 32)) &&
              _offPoint) {
            setNotificationOn();
            _offPoint = false;
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
                    PieChart(
                      dataMap: <String, double>{
                        "Battery": double.parse('${snapshot.data}')
                      },
                      chartType: ChartType.ring,
                      initialAngleInDegree: 0,
                      animationDuration: Duration(milliseconds: 0),
                      baseChartColor: Colors.white,
                      colorList: <Color>[Colors.blue],
                      chartLegendSpacing: 32,
                      chartRadius: MediaQuery.of(context).size.width / 3.2,
                      totalValue: 100,
                    ),
                    SizedBox(height: 50),
                    ifText(),
                    SizedBox(height: 50),
                    ElevatedButton(
                      onPressed: () {
                        turnOn();
                      },
                      child: Text(
                        "On",
                      ),
                    ),
                    SizedBox(height: 50),
                    ElevatedButton(
                      onPressed: () {
                        turnOff();
                      },
                      child: Text(
                        "Off",
                      ),
                    ),
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
      ;
      ;
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
}
