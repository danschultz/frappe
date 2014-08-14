library property_test;

import 'dart:async';
import 'package:frappe/frappe.dart';
import 'package:guinness/guinness.dart';

void main() => describe("Property", () {
  StreamController controller;
  Property property;

  beforeEach(() {
    controller = new StreamController();
    property = new Property.fromStream(controller.stream);
  });

  describe("not()", () {
    it("negates the current value", () {
      var result = property.not();
      controller.add(true);
      return result.first.then((value) => expect(value).toBe(false));
    });
  });
});