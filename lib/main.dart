import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:noise_meter/noise_meter.dart';

String textDb = "0 db";
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MyHomePage(title: 'noise DB scan'),
        debugShowCheckedModeBanner: false);
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isStartRecording = false;
  String textButton = "Start scan noise";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromRGBO(216, 225, 252, 1.0),
        appBar: AppBar(
          title: Text(widget.title),
          foregroundColor: Colors.white,
        ),
        body: Column(children: [
          const Padding(
            padding: EdgeInsets.all(40),
            child: Align(alignment: Alignment.topCenter, child: Circle()),
          ),
          Padding(
            padding: EdgeInsets.all(40),
            child: Align(
                alignment: Alignment.bottomCenter,
                child: RaisedButton(
                  onPressed: StartOrPause,
                  child: Text(textButton),
                  color: const Color.fromRGBO(134, 169, 248, 1),
                )),
          )
        ]));
  }

  late bool _isRecording;
  late StreamSubscription<NoiseReading> _noiseSubscription;
  late NoiseMeter _noiseMeter = NoiseMeter(onError);

  @override
  void initState() {
    _isRecording = false;
  }

  void StartOrPause() {
    if (isStartRecording) {
      stopRecorder();
      textButton = "Start scan noise";
    } else {
      start();
      textButton = "Stop scan noise";
    }
    isStartRecording = !isStartRecording;
    setState(() {});
  }

  void start() async {
    _noiseSubscription = _noiseMeter.noiseStream.listen(onData);
  }

  void onData(NoiseReading noiseReading) {
    this.setState(() {
      if (!this._isRecording) {
        this._isRecording = true;
      }
      textDb = noiseReading.meanDecibel.toStringAsFixed(4) + " db";
    });

    textDb = noiseReading.meanDecibel.toStringAsFixed(4) + " db";
    print("NNN: " + textDb);
  }

  void onError(Object error) {
    print(error.toString());
    _isRecording = false;
  }

  void stopRecorder() async {
    try {
      if (_noiseSubscription != null) {
        _noiseSubscription.cancel();
        //_noiseSubscription = null;
      }
      this.setState(() {
        this._isRecording = false;
      });
    } catch (err) {
      print('stopRecorder error: $err');
    }
  }
}

class Circle extends StatelessWidget {
  const Circle({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Align(
          alignment: Alignment.center,
          child: Text(
            textDb,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 55),
          )),
      width: 300.0,
      height: 300.0,
      decoration: const BoxDecoration(
          color: Color.fromRGBO(134, 169, 248, 0.6),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5.0,
              spreadRadius: 5.0,
              offset: Offset(0, 0),
            )
          ]),
    );
  }
}
