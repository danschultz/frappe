library signal_helpers;

import 'dart:async';
import 'package:reactive/reactive.dart';

void listenToFirstEvent(Signal signal, void onData(data)) {
  StreamSubscription subscription;

  subscription = signal.listen((data) {
    onData(data);
    subscription.cancel();
  });
}