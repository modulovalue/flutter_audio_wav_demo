import 'dart:math' as _math;
import 'dart:math';
import 'package:bird/bird.dart';
import 'package:convert/convert.dart';

// Reference:
// https://gist.github.com/literallylara/7ece1983fab47365108c47119afb51c7
// https://de.wikipedia.org/wiki/RIFF_WAVE
// ignore_for_file: close_sinks
class WavBloc extends HookBloc {
  final Signal<double> _durationInSeconds = HookBloc.disposeSink(Signal(0.3));
  final Signal<int> _channels = HookBloc.disposeSink(Signal(1));

  // Samples per second
  final Signal<int> _sampleRate = HookBloc.disposeSink(Signal(44100));
  final Signal<int> _bytesPerSample = HookBloc.disposeSink(Signal(1));
  final Signal<List<int>> _data = HookBloc.disposeSink(Signal([]));

  Wave<double> durationInSeconds;
  Wave<int> channels;
  Wave<int> sampleRate;
  Wave<int> bytesPerSample;
  Wave<int> data_size;
  Wave<int> header_size;
  Wave<int> file_size;
  Wave<List<int>> data;

  WavBloc() {
    durationInSeconds = _durationInSeconds.wave;
    channels = _channels.wave;
    sampleRate = _sampleRate.wave;
    bytesPerSample = _bytesPerSample.wave;
    data = _data.wave;

    data_size = Wave.combineLatest<num, int>(
        [durationInSeconds, channels, sampleRate, bytesPerSample], (a) {
      return a.reduce((a, b) => a * b).floor();
    });
    header_size = just(44);
    file_size = data_size.and(header_size).latest((a, b) => a + b);
    setSilence();
  }

  void setSine(Iterable<int> steps) {
    _data.add(_iterateThroughLengthOfWave((sample, addSample, period) {
      final val = (
          _normalize(_sinAtSteps(steps, period)))
          .floor().clamp(0, 255).round();
      addSample(val);
    }));
  }

  void setSquare() {
    _data.add(_iterateThroughLengthOfWave((sample, addSample, period) {
      final val = _normalize(_sinAtSteps([0], period)).floor();
      if (val > 128) {
        addSample(255);
      } else {
        addSample(0);
      }
    }));
  }

  num _normalize(num a) {
    return a / 2 * _math.pow(
        2, _bytesPerSample.value * 8);
  }

  void setSilence() {
    _data.add(_iterateThroughLengthOfWave((sample, addSample, period) {
      addSample(128);
    }));
  }

  void setNoise() {
    final rand = Random();
    _data.add(_iterateThroughLengthOfWave((sample, addSample, period) {
      addSample(rand.nextInt(256));
    }));
  }

  void setSecureNoise() {
    final rand = Random.secure();
    _data.add(_iterateThroughLengthOfWave((sample, addSample, period) {
      addSample(rand.nextInt(256));
    }));
  }

  List<int> _iterateThroughLengthOfWave(
      void Function(int sample, void Function(int) addSample, double period) action) {
    final data = <int>[];
    for (var j = 0; j < (_durationInSeconds.value * _sampleRate.value)
        .floor(); j++) {
      action(j, data.add, j / _sampleRate.value);
    }
    return data;
  }

  String write() {
    String _put(int n, int l) {
      final _n = n.toRadixString(16);
      final __n = List<String>.filled(l * 2 - _n.length, "0").join() + _n;
      return String.fromCharCodes(hex
          .decode(__n)
          .reversed
          .toList());
    }

    final _data = StringBuffer();
    // PCM Data
    // --------------------------------------------
    // Field           | Bytes | Content
    // --------------------------------------------
    // ckID            |     4 | "fmt "
    // cksize          |     4 | 0x0000010 (16)
    // wFormatTag      |     2 | 0x0001 (PCM)
    // nChannels       |     2 | NCH
    // nSamplesPerSec  |     4 | SPS
    // nAvgBytesPerSec |     4 | NCH * BPS * SPS
    // nBlockAlign     |     2 | NCH * BPS * NCH
    // wBitsPerSample  |     2 | BPS * 8
    //
    // data_size = DUR * NCH * SPS * BPS
    // file_size = 44 (Header) + data_size
    _data.write(
        "RIFF" + _put(file_size.value.floor(), 4) + "WAVEfmt " + _put(16, 4));
    _data.write(_put(1, 2)); // wFormatTag (pcm)
    _data.write(_put(_channels.value, 2)); // nChannels
    _data.write(_put(_sampleRate.value, 4)); // nSamplesPerSec
    _data.write(_put(
        _channels.value * _bytesPerSample.value * _sampleRate.value,
        4)); // nAvgBytesPerSec
    _data.write(
        _put(_channels.value * _bytesPerSample.value, 2)); // nBlockAlign
    _data.write(_put(_bytesPerSample.value * 8, 2)); // wBitsPerSample
    _data.write("data" + _put(data_size.value.floor(), 4));

    this._data.value.forEach((val) {
      _data.write(_put(val, _bytesPerSample.value));
    });
    return _data.toString();
  }
}

double _pi = _math.pi;

double _sin(num d) => _math.sin(d);

double _sinAtFreq(double freq, double time) => _sin(freq * _pi * 2 * time) + 1;

double _sinAtFreqs(Iterable<double> freq, double time) {
  return (freq.map((_freq) => _sinAtFreq(_freq, time) - 128).reduce((a,
      b) => a + b) / freq.length) + 128;
}

double _sinAtSteps(Iterable<int> steps, double time) {
  return _sinAtFreqs(steps.map(calcFrequency), time);
}

double calcFrequency(int stepsAboveA4) {
  const _rootMiddleC5 = 440.0;
  return _rootMiddleC5 * _math.pow(1.059463, stepsAboveA4);
}

Iterable<int> minor7(int stepsAboveA4) {
  return [-12, -24, -36, -5, 0, 3, 7].map((a) => a + stepsAboveA4);
}

Iterable<int> major7(int stepsAboveA4) {
  return [-12, -24, -36, -5, 0, 4, 7].map((a) => a + stepsAboveA4);
}
//
//Iterable<int> minor7(int stepsAboveA4) sync* {
//  yield* minor(stepsAboveA4);
//  yield 10;
//}
//
//Iterable<int> major7(int stepsAboveA4) sync* {
//  yield* major(stepsAboveA4);
//  yield 11;
//}