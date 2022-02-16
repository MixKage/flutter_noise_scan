import 'dart:async';
import 'package:flutter/material.dart';
import 'package:noise_meter/noise_meter.dart';

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
  bool isRecording = false;
  String textDb = "0 db";
  String textButton = "Start scan noise";
  StreamSubscription<NoiseReading>? _noiseSubscription;
  late NoiseMeter _noiseMeter;

  @override
  void initState() {
    super.initState();
    _noiseMeter = NoiseMeter(onError);
  }

  void startOnPause() {
    if (isRecording) {
      stopRecorder();
      setState(() {
        textButton = "Start scan noise";
        isRecording = false;
      });
    } else {
      start();
      setState(() {
        textButton = "Stop scan noise";
        isRecording = true;
      });
    }
  }

  void start() async =>
      _noiseSubscription = _noiseMeter.noiseStream.listen(onData);

  void onData(NoiseReading noiseReading) {
    setState(() {
      textDb = noiseReading.meanDecibel.toStringAsFixed(4) + " db";
    });
    debugPrint("NNN: " + textDb);
  }

  void onError(Object error) {
    debugPrint(error.toString());
    setState(() {
      isRecording = false;
    });
  }

  void stopRecorder() async {
    try {
      if (_noiseSubscription != null) {
        _noiseSubscription!.cancel();
        _noiseSubscription = null;
      }
      setState(() {
        isRecording = false;
      });
    } catch (err) {
      debugPrint('stopRecorder error: $err');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromRGBO(216, 225, 252, 1.0),
        appBar: AppBar(
          title: Text(widget.title),
          foregroundColor: Colors.white,
        ),
        body: Column(children: [
          Padding(
            padding: const EdgeInsets.all(40),
            child: Align(
                alignment: Alignment.topCenter,
                child: Circle(
                  text: textDb,
                )),
          ),
          Padding(
            padding: const EdgeInsets.all(40),
            child: Align(
                alignment: Alignment.bottomCenter,
                child: ElevatedButton(
                  onPressed: startOnPause,
                  child: Text(textButton),
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          const Color.fromRGBO(134, 169, 248, 1))),
                )),
          )
        ]));
  }
}

class Circle extends StatelessWidget {
  const Circle({Key? key, required this.text}) : super(key: key);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Align(
          alignment: Alignment.center,
          child: Text(
            text,
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
