import 'dart:html';
import 'dart:typed_data';

import 'package:bird_flutter/bird_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_wav_demo/blocs/wav_bloc.dart';
import 'package:flutter_audio_wav_demo/pages/widget_editor.dart';
import 'package:flutter_audio_wav_demo/pages/widget_wav_info.dart';
import 'package:flutter_audio_wav_demo/widgets/title.dart';

import 'main_bloc.dart';

const Color accentColor = Colors.yellow;

Widget mainPage({
  @required void Function(Uint8List) exportAudio,
  @required void Function(Uint8List) previewSamples,
}) {
  return $$ >> (context) {
    final bloc = $$$(() => MainBloc());

    void preview() =>
        previewSamples(Uint8List.fromList(bloc
            .wav
            .write()
            .codeUnits));

    void setChord(Iterable<int> steps) {
      bloc.wav.setSine(steps);
      preview();
    }

    return apply
    & scaffold(color: Colors.blueGrey[900])
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
              > waveInfo(bloc.wav),

          _divider,

          apply
          & villainFadeIn().delayMS(400)
              > onWrapCenterCenter(allSpacing: 12.0) >> [
            _button(() => setChord(minor7(0)))
                > const Text("Sine: Amin"),
            _button(() => setChord(major7(3)))
                > const Text("Sine: Cmaj"),
            _button(() => setChord(major7(-2)))
                > const Text("Sine: Gmaj"),
            _button(() => setChord(major7(-4)))
                > const Text("Sine: Fmaj"),
          ],

          verticalSpace(8.0),

          apply
          & villainFadeIn().delayMS(400)
              > onWrapCenterCenter(allSpacing: 12.0) >> [
            _button(() => setChord([...minor7(0), 19]))
                > const Text("Amin + E"),
            _button(() => setChord([...major7(3), 22]))
                > const Text("Cmaj + G"),
            _button(() => setChord([...major7(-2), 14]))
                > const Text("Gmaj + B"),
            _button(() => setChord([...major7(-4), 15]))
                > const Text("Fmaj + C"),
          ],

          verticalSpace(8.0),

          apply
          & villainFadeIn().delayMS(400)
              > onWrapCenterCenter(allSpacing: 12.0) >> [
            _button(bloc.wav.setSquare.then(preview))
                > const Text("Square wave"),
            _button(bloc.wav.setSilence.then(preview))
                > const Text("Silence"),
            _button(bloc.wav.setNoise.then(preview))
                > const Text("Random noise"),
            _button(bloc.wav.setSecureNoise.then(preview))
                > const Text("Random.secure noise"),
          ],

          verticalSpace(18.0),

          apply
          & villainFadeIn().delayMS(300).inTimeMS(400)
              > editorWidget(bloc.wav),

          verticalSpace(18.0),

          apply
          & villainFadeIn().delayMS(300).inTimeMS(400)
              > onWrapCenterCenter(allSpacing: 12)
              >> [
                apply
                & _button(preview)
                    > const Text("Preview"),

                apply
                & _button(() {
                  exportAudio(Uint8List.fromList(bloc
                      .wav
                      .write()
                      .codeUnits));
                })
                    > const Text("Export"),

              ],

          verticalSpace(24.0),
        ];
  };
}

Applicator _button(void Function() onTap) {
  return apply((child) {
    return RaisedButton(
      child: textColor(Colors.black) > child,
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

extension FN on void Function() {
  void Function() then(void Function() action) =>
          () {
        this();
        action();
      };
}