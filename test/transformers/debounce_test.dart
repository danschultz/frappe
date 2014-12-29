library debounce_test;

import 'dart:async';
import 'package:guinness/guinness.dart';
import 'package:unittest/unittest.dart' show expectAsync;
import 'package:frappe/src/transformers.dart';
import 'util.dart';

void main() => describe("Debounce", () {
  StreamController controller;
  Duration duration;

  beforeEach(() {
    controller = new StreamController();
    duration = new Duration(milliseconds: 50);
  });

  afterEach(() {
    controller.close();
  });

  it("provides the first and last events after duration passes", () {
    return testStream(controller.stream.transform(new Debounce(duration)),
        behavior: () {
          controller..add(1)..add(2)..add(3);
          return new Future.delayed(new Duration(seconds: 1), () {});
        },
        expectation: (values) => expect(values).toEqual([1, 3]));
  });

  it("closes transformed stream when source stream is done", () {
    var stream = controller.stream.transform(new Debounce(duration));
    controller..add(1)..close();
    return stream.toList().then((values) {
      expect(values).toEqual([1]);
    });
  });

  it("doesn't debounce errors", () {
    var errors = [];
    var stream = controller.stream.transform(new Debounce(duration));
    var subscription = stream.listen((_) {}, onError: (e) => errors.add(e), onDone: expectAsync(() {
      expect(errors).toEqual([1, 2, 3]);
    }));
    controller..addError(1)..addError(2)..addError(3)..close();
  });
});