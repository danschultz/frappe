part of frappe.transformers;

Stream bindStream({Stream like, StreamSubscription onListen(EventSink sink), void onDone(), Future onCancel()}) {
  StreamSubscription subscription;
  StreamController controller;

  controller = _createControllerLikeStream(
      stream: like,
      onListen: () {
        subscription = onListen(controller);
        subscription.onDone(() {
          if (onDone != null) {
            onDone();
          }
          controller.close();
        });
      },
      onPause: () => subscription.pause(),
      onResume: () => subscription.resume(),
      onCancel: () {
        var futures = [onCancel, subscription.cancel]
            .where((function) => function != null)
            .map((function) => function())
            .where((future) => future != null);
        return Future.wait(futures);
      });

  return controller.stream;
}

StreamController _createControllerLikeStream({Stream stream, void onListen(), void onCancel(), void onPause(), void onResume()}) {
  if (stream == null || !stream.isBroadcast) {
    return new StreamController(onListen: onListen, onCancel: onCancel, onPause: onPause, onResume: onResume);
  } else {
    return new StreamController.broadcast(onListen: onListen, onCancel: onCancel);
  }
}

Future cancelSubscriptions(Iterable<StreamSubscription> subscriptions) {
  var futures = subscriptions
      .map((subscription) => subscription.cancel())
      .where((future) => future != null);
  return Future.wait(futures);
}