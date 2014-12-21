library collect_reactable_test;

import 'dart:async';
import 'package:guinness/guinness.dart';
import 'package:frappe/frappe.dart';

void main() => describe("Reactable.collect()", () {
  it("contains the values of the reactables", () {
    var p1 = new Property.constant(1);
    var p2 = new Property.constant(2);
    var p3 = new Property.constant(3);
    var combined = Reactable.collect([p1, p2, p3]);
    return combined.first.then((values) => expect(values).toEqual([1, 2, 3]));
  });

  it("delivers changes when a reactables changes", () {
    var controller = new StreamController();
    var p1 = new Property.constant(1);
    var p2 = new Property.fromStreamWithInitialValue(2, controller.stream);
    var p3 = new Property.constant(3);
    var combined = Reactable.collect([p1, p2, p3]);
    return combined.first.then((_) {
      controller.add(4);
      return combined.first.then((values) => expect(values).toEqual([1, 4, 3]));
    });
  });
});