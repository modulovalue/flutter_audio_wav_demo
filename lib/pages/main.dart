import 'dart:html';
import 'dart:typed_data';

import 'package:bird_flutter/bird_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_wav_demo/pages/widget_editor.dart';
import 'package:flutter_audio_wav_demo/pages/widget_wav_info.dart';
import 'package:flutter_audio_wav_demo/widgets/title.dart';

import 'main_bloc.dart';

const Color accentColor = Colors.yellow;

Widget mainPage(void Function(Uint8List) exportAudio) {
  return $$ >> (context) {
    final bloc = $$$(() => MainBloc());

    return apply
    & scaffold()
    & center()
    & fluidByMarginH2(1000)
        > onListView(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(
            horizontal: 18.0,
            vertical: 28.0
          ),
        ) >> [
          ..._title,

          _divider,

          villainFadeIn().delayMS(100)
          & opacity(0.4)
              > waveInfo(bloc.wavBloc),

          verticalSpace(18.0),

          center()
          & villainFadeIn().delayMS(200)
          & _button(() {
            exportAudio(Uint8List.fromList(bloc
                .wavBloc
                .write()
                .codeUnits));
          })
          & textColor(Colors.black)
              > const Text("Export"),

          _divider,

          apply
          & villainFadeIn().delayMS(400)
              > onWrapCenterCenter(allSpacing: 12.0) >> [
            _button(bloc.wavBloc.setSine) & textColor(Colors.black) > const Text("Sine"),
            _button(bloc.wavBloc.setSquare) & textColor(Colors.black) > const Text("Square"),
            _button(bloc.wavBloc.setSilence) & textColor(Colors.black) > const Text("Silence"),
          ],
          verticalSpace(18.0),

          apply
          & villainFadeIn().delayMS(300).inTimeMS(400)
              > editorWidget(bloc.wavBloc),

          verticalSpace(24.0),
        ];
  };
}

Applicator _button(void Function() onTap) {
  return apply((child) {
    return RaisedButton(
      child: child,
      color: accentColor,
      onPressed: onTap,
    );
  });
}

final _divider = padding(vertical: 18.0)
& height(1.0)
& width(300.0)
& bgColor(Colors.grey[800])
    > nothing;

Iterable<Widget> _title =
    villainFadeIn() * modulovalueTitle(
      "Flutter Audio .wav Demo",
      "flutter_audio_wav_demo",
    );