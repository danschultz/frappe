library stream_signal_test;

import 'dart:async';
import 'package:guinness/guinness.dart';
import 'package:reactive/reactive.dart';

void main() => describe("StreamSignal", () {
  StreamController<int> values;
  Signal<int> value;

  beforeEach(() {
    values = new StreamController();
    value = new StreamSignal(1, values.stream);
  });

  describe("+()", () {
    it("returned signal has a value", () {
      var result = value + new Signal(2);
      expect(result.value).toBe(3);
    });
  });

  describe("equals()", () {
    it("returned signal has a value", () {
      var result = value.equals(new Signal(1));
      expect(result.value).toBe(true);
    });

    it("updates when signal changes", () {
      var result = value.equals(new Signal(2));
      values.add(2);

      return new Future(() => values.close()).then((_) {
        expect(result.value).toBe(true);
      });
    });
  });

  describe("derive()", () {
    it("returned signal has a value", () {
      var result = value.derive((value) => value == 1);
      expect(result.value).toBe(true);
    });

    it("updates when signal changes", () {
      var result = value.derive((value) => value == 2);
      values.add(2);

      return new Future(() => values.close()).then((_) {
        expect(result.value).toBe(true);
      });
    });
  });
});