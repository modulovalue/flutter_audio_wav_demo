import 'dart:html';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_audio_wav_demo/pages/main.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark(),
      home: mainPage((Uint8List data) {
        final blob = Blob(
            <dynamic>[data], "audio/wav");
        final url = Url.createObjectUrl(blob).toString();
        window.open(url, "download");
      }),
    );
  }
}