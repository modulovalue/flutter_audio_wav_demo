import 'dart:ui';

import 'package:bird_flutter/bird_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_wav_demo/blocs/wav_bloc.dart';

Widget editorWidget(WavBloc wavBloc) {
  return $$ >> (context) {
    return apply
    & height(300.0)
    & material(
      4.0,
      color: Colors.grey[900],
      borderRadius: BorderRadius.circular(8.0),
    )
        > $$ >> (context) {
          final oldData = useState<List<int>>(null);
          final newData = useState<List<int>>(null);
          useDispose(() =>
              wavBloc.data.subscribe((data) {
                newData.value ??= data;
                oldData.value ??= data;
                oldData.value = newData.value;
                newData.value = data;
              }), (Disposable a) => a.cancel);

          return TweenAnimationBuilder<List<int>>(
            tween: _ListTween(oldData.value, newData.value),
            duration: ms300,
            curve: Curves.easeOut,
            builder: (context, data, _) {
              return CustomPaint(
                painter: WavePainter(
                  data: data,
                ),
              );
            },
          );
        };
  };
}

class _ListTween extends Tween<List<int>> {

  _ListTween(List<int> begin, List<int> end) : super(begin: begin, end: end);

  @override
  List<int> lerp(double t) {
    return begin
        .asMap()
        .entries
        .map((entry) {
      return DoubleLerp(entry.value.toDouble(), end[entry.key].toDouble()).lerp(
          t).floor();
    }).toList();
  }
}

class WavePainter extends CustomPainter {
  final int samplePeak;
  final List<int> data;

  const WavePainter({
    @required this.data,
    this.samplePeak = 256,
  });

  @override
  void paint(Canvas canvas, Size size) {

    /// draw center line
    canvas.drawLine(
      Offset(0.0, size.height / 2),
      Offset(size.width, size.height / 2),
      Paint()
        ..color = Colors.grey[800]
        ..strokeWidth = 1.5,
    );

    /// draw wave
    data
        .asMap()
        .entries
        .map((entry) {
      return Offset(
          size.width * (entry.key / data.length),
          (size.height / 2) + ((entry.value.toDouble() / samplePeak) - 0.5)
              * size.height
      );
    })
        .toList()
        .fold<Offset>(null, (previous, current) {
      if (previous != null) {
        canvas.drawLine(
          previous,
          current,
          Paint()
            ..color = Colors.yellow[300],
        );
      }
      return current;
    });
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}