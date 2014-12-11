library computed_property_test;

import 'dart:async';
import 'package:guinness/guinness.dart';
import 'package:unittest/unittest.dart' show expectAsync;
import 'package:frappe/frappe.dart';
import 'callback_helpers.dart';

void main() => describe("Combined properties", () {
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

  it("delivers current value to multiple listeners", () {
    var result = property1 + property2;

    controller1.add(1);
    controller2.add(2);

    return Future.wait([result.first, result.first]).then((results) {
      expect(results.first).toBe(3);
      expect(results.last).toBe(3);
    });
  });

  it("forwards errors from dependencies", () {
    var result = property1 + property2;
    result.listen(doNothing, onError: expectAsync((error) => expect(error).toBeNotNull()), cancelOnError: true);
    controller1.addError("ERROR");
  });

  it("forwards errors from compute function", () {
    var result = property1.combine(property2, (a, b) => throw "dummy error");
    result.listen(doNothing, onError: expectAsync((error) => expect(error).toBeNotNull()), cancelOnError: true);

    controller1.add(1);
    controller2.add(2);
  });
});
