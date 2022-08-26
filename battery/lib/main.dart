import 'package:flutter/material.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:pie_chart/pie_chart.dart';

void main() {
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

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getBatteryLevel(),
      builder: (context, snapshot) {
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
                    baseChartColor: Colors.white,
                    colorList: <Color>[Colors.blue],
                    chartLegendSpacing: 32,
                    chartRadius: MediaQuery.of(context).size.width / 3.2,
                    totalValue: 100,
                  ),
                  ifText()
                ],
              ),
            ),
          );
        } else {
          // 処理中の表示
          return const CircularProgressIndicator();
        }
      },
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
      return const Text("満タン",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32));
    } else if (state == 'BatteryState.charging') {
      return const Text("充電中",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32));
    } else if (state == 'BatteryState.discharging') {
      return const Text("バッテリー減少中",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32));
    } else {
      return const Text("読み込みできません",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32));
    }
  }
}
