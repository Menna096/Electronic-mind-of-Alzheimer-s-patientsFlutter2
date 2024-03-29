import 'dart:async';

class TimerManager {
  late Timer _timer;
  late Function(int) _onTick;
  late Function() _onTimerFinish;
  int _secondsLeft;

  TimerManager({
    required int initialSeconds,
    required Function(int) onTick,
    required Function() onTimerFinish,
  }) : _secondsLeft = initialSeconds {
    _onTick = onTick;
    _onTimerFinish = onTimerFinish;
  }

  void start() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _secondsLeft--;
      if (_secondsLeft <= 0) {
        stop();
        _onTimerFinish();
      } else {
        _onTick(_secondsLeft);
      }
    });
  }

  void stop() {
    _timer.cancel();
  }

  void reset() {
    _timer.cancel();
    _secondsLeft = 30; // Reset to initial value
  }
}
