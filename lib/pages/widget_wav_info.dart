import 'package:bird_flutter/bird_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_wav_demo/blocs/wav_bloc.dart';

Widget waveInfo(WavBloc bloc) {
  return $$ >> (context) {
    final duratinoInSeconds = $(() => bloc.durationInSeconds);
    final channels = $(() => bloc.channels);
    final sampleRate = $(() => bloc.sampleRate);
    final bytesPerSample = $(() => bloc.bytesPerSample);
    final data_size = $(() => bloc.data_size);
    final header_size = $(() => bloc.header_size);
    final file_size = $(() => bloc.file_size);

    return onColumnMinCenterCenter() >> [
      onWrapCenterCenter(allSpacing: 6.0) >> [
        Text("Duration: ${duratinoInSeconds}s"),
        Text("Channels: ${channels}"),
        Text("Sample Rate: ${sampleRate}"),
        Text("Bytes per sample: ${bytesPerSample}"),
      ].intersperse(const Text("•")),
      verticalSpace(4.0),
      onWrapCenterCenter(allSpacing: 6.0) >> [
        Text("Data size: ${data_size} Byte"),
        Text("Header size: ${header_size} Byte"),
        Text("File size: ${file_size} Byte"),
      ].intersperse(const Text("•")),
    ];
  };
}