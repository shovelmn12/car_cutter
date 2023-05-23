import 'package:flutter/material.dart';
import 'dart:async';

import 'package:gyroscope/gyroscope.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _gyroscopePlugin = Gyroscope();

  bool _isSubscribed = false;

  GyroscopeData? _data;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _subscribe() async {
    if (_isSubscribed) {
      await _unsubscribe();
    }

    await _gyroscopePlugin.subscribe((data) {
      if (mounted) {
        setState(() {
          _data = data;
        });
      }
    });

    if (mounted) {
      setState(() {
        _isSubscribed = true;
      });
    }
  }

  Future<void> _unsubscribe() async {
    if (!_isSubscribed) {
      return;
    }

    await _gyroscopePlugin.unsubscribe();

    if (mounted) {
      setState(() {
        _isSubscribed = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Plugin example app'),
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Gyro data: ${_data?.azimuth ?? 0}, ${_data?.pitch ?? 0}, ${_data?.roll ?? 0}',
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: ElevatedButton(
                  onPressed: _isSubscribed ? _unsubscribe : _subscribe,
                  child: _isSubscribed
                      ? const Text("Unsubscribe")
                      : const Text("Subscribe"),
                ),
              ),
            ],
          ),
        ),
      );
}
