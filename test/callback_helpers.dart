library callback_helpers;

import 'dart:async';
import 'package:frappe/frappe.dart';

Function doNothing = (_) {};

void listenToFirstEvent(Watchable observable, void onData(data)) {
  StreamSubscription subscription;

  subscription = observable.listen((data) {
    onData(data);
    subscription.cancel();
  });
}
