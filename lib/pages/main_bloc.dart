import 'package:bird/bird.dart';
import 'package:flutter_audio_wav_demo/blocs/wav_bloc.dart';

class MainBloc extends HookBloc {
  final WavBloc wavBloc = HookBloc.disposeBloc(WavBloc());

  MainBloc();
}
