library callback_helpers;

import 'dart:async';
import 'package:reactive/reactive.dart';

Function doNothing = (_) {};

void listenToFirstEvent(Observable observable, void onData(data)) {
  StreamSubscription subscription;

  subscription = observable.listen((data) {
    onData(data);
    subscription.cancel();
  });
}
