library computed_property_test;

import 'dart:async';
import 'package:guinness/guinness.dart';
import 'package:unittest/unittest.dart' show expectAsync;
import 'package:courier/courier.dart';
import 'callback_helpers.dart';

void main() {
  describe("Combined properties", () {
    StreamController controller1;
    Property property1;

    StreamController controller2;
    Property property2;

    beforeEach(() {
      controller1 = new StreamController();
      property1 = new Property.fromStream(controller1.stream);

      controller2 = new StreamController();
      property2 = new Property.fromStream(controller2.stream);
    });

    it("recomputes when dependencies change", () {
      var result = property1 + property2;
      listenToFirstEvent(result, expectAsync((value) => expect(value).toBe(3)));

      controller1.add(1);
      controller2.add(2);
    });

    it("forwards errors from dependencies", () {
      var result = property1 + property2;
      result.listen(doNothing, onError: expectAsync((error) => expect(error).toBeNotNull()), cancelOnError: true);
      controller1.addError("ERROR");
    });

    it("forwards errors from compute function", () {

    });
  });

  describe("Computed properties", () {
    StreamController controller;
    Property property;

    beforeEach(() {
      controller = new StreamController();
      property = new Property.fromStream(controller.stream);
    });

    it("recomputes when value changes", () {
      var result = property.map((value) => value + 1);
      listenToFirstEvent(result, expectAsync((value) => expect(value).toBe(3)));
      controller.add(2);
    });

    it("forwards errors from source property", () {
      var result = property.map((value) => value + 1);
      result.listen(doNothing, onError: expectAsync((error) => expect(error).toBeNotNull()), cancelOnError: true);
      controller.addError("ERROR");
    });
  });
}
