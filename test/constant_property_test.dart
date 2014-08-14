library constant_property_test;

import 'package:frappe/frappe.dart';
import 'package:guinness/guinness.dart';
import 'reactable_shared_tests.dart';

void main() => describe("Property.constant()", () {
  describe("first", () {
    it("completes with the constant value", () {
      return new Property.constant(true).first.then((value) => expect(value).toBe(true));
    });
  });
});