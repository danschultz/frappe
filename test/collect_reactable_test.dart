library collect_reactable_test;

import 'dart:async';
import 'package:guinness/guinness.dart';
import 'package:frappe/frappe.dart';
import 'util.dart';

void main() => describe("Reactable.collect()", () {
  describe("with one reactable", () {
    it("contains the value of that reactable as a list", () {
      var p1 = new Property.constant(1);
      var combined = Reactable.collect([p1]);
      return testReactable(combined, expectation: (values) => expect(values).toEqual([[1]]));
    });
  });

  describe("with multiple reactables", () {
    it("contains the values of all the reactables as a list", () {
      var p1 = new Property.constant(1);
      var p2 = new Property.constant(2);
      var p3 = new Property.constant(3);
      var combined = Reactable.collect([p1, p2, p3]);
      return testReactable(combined, expectation: (values) => expect(values).toEqual([[1, 2, 3]]));
    });
  });

  it("delivers changes when a reactables changes", () {
    var controller = new StreamController();
    var p1 = new Property.constant(1);
    var p2 = new Property.fromStreamWithInitialValue(2, controller.stream);
    var p3 = new Property.constant(3);
    var combined = Reactable.collect([p1, p2, p3]);

    return testReactable(combined,
        behavior: () {
          controller.add(4);
        },
        expectation: (values) => expect(values).toEqual([[1, 2, 3], [1, 4, 3]]));
  });
});