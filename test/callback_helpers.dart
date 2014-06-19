library callback_helpers;

import 'dart:async';
import 'package:relay/relay.dart';

Function doNothing = (_) {};

void listenToFirstEvent(Observable observable, void onData(data)) {
  StreamSubscription subscription;

  subscription = observable.listen((data) {
    onData(data);
    subscription.cancel();
  });
}
