library return_type_shared_tests;

import 'dart:async';
import 'package:frappe/frappe.dart';
import 'package:guinness/guinness.dart';

void testReturnTypes(Type expectedType, Reactable provider()) => describe("return types", () {
  Reactable reactable;

  beforeEach(() {
    reactable = provider();
  });

  describe("asBroadcastStream()", () {
    it("returns a $expectedType", () {
      var transformed = reactable.asBroadcastStream();
      expect(transformed.runtimeType == expectedType).toBeTruthy();
    });
  });

  describe("asyncExpand()", () {
    it("returns a $expectedType", () {
      var transformed = reactable.asyncExpand((value) => new Stream.fromIterable([value]));
      expect(transformed.runtimeType == expectedType).toBeTruthy();
    });
  });

  describe("asyncMap()", () {
    it("returns a $expectedType", () {
      var transformed = reactable.asyncMap((value) => new Future(() => value));
      expect(transformed.runtimeType == expectedType).toBeTruthy();
    });
  });

  describe("bufferWhen()", () {
    it("returns a $expectedType", () {
      var transformed = reactable.bufferWhen(new Stream.fromIterable([]));
      expect(transformed.runtimeType == expectedType).toBeTruthy();
    });
  });

  describe("combine()", () {
    it("returns a $expectedType", () {
      var transformed = reactable.combine(new Stream.fromIterable([]), (a, b) => a + b);
      expect(transformed.runtimeType == expectedType).toBeTruthy();
    });
  });

  describe("debounce()", () {
    it("returns a $expectedType", () {
      var transformed = reactable.debounce(new Duration(milliseconds: 1));
      expect(transformed.runtimeType == expectedType).toBeTruthy();
    });
  });

  describe("delay()", () {
    it("returns a $expectedType", () {
      var transformed = reactable.delay(new Duration(milliseconds: 1));
      expect(transformed.runtimeType == expectedType).toBeTruthy();
    });
  });

  describe("distinct()", () {
    it("returns a $expectedType", () {
      var transformed = reactable.distinct();
      expect(transformed.runtimeType == expectedType).toBeTruthy();
    });
  });

  describe("expand()", () {
    it("returns a $expectedType", () {
      var transformed = reactable.expand((value) => [value]);
      expect(transformed.runtimeType == expectedType).toBeTruthy();
    });
  });

  describe("flatMap()", () {
    it("returns a $expectedType", () {
      var transformed = reactable.flatMap((e) => new Stream.fromIterable([e]));
      expect(transformed.runtimeType == expectedType).toBeTruthy();
    });
  });

  describe("flatMapLatest()", () {
    it("returns a $expectedType", () {
      var transformed = reactable.flatMapLatest((e) => new Stream.fromIterable([e]));
      expect(transformed.runtimeType == expectedType).toBeTruthy();
    });
  });

  describe("handleError()", () {
    it("returns a $expectedType", () {
      var transformed = reactable.handleError((e) => e);
      expect(transformed.runtimeType == expectedType).toBeTruthy();
    });
  });

  describe("map()", () {
    it("returns a $expectedType", () {
      var transformed = reactable.map((e) => e);
      expect(transformed.runtimeType == expectedType).toBeTruthy();
    });
  });

  describe("merge()", () {
    it("returns a $expectedType", () {
      var transformed = reactable.merge(new Stream.fromIterable([]));
      expect(transformed.runtimeType == expectedType).toBeTruthy();
    });
  });

  describe("scan()", () {
    it("returns a $expectedType", () {
      var transformed = reactable.scan(1, (a, b) => a + b);
      expect(transformed.runtimeType == expectedType).toBeTruthy();
    });
  });

  describe("skip()", () {
    it("returns a $expectedType", () {
      var transformed = reactable.skip(1);
      expect(transformed.runtimeType == expectedType).toBeTruthy();
    });
  });

  describe("skipWhile()", () {
    it("returns a $expectedType", () {
      var transformed = reactable.skipWhile((_) => false);
      expect(transformed.runtimeType == expectedType).toBeTruthy();
    });
  });

  describe("skipUntil()", () {
    it("returns a $expectedType", () {
      var transformed = reactable.skipUntil(new Stream.fromIterable([]));
      expect(transformed.runtimeType == expectedType).toBeTruthy();
    });
  });

  describe("take()", () {
    it("returns a $expectedType", () {
      var transformed = reactable.take(1);
      expect(transformed.runtimeType == expectedType).toBeTruthy();
    });
  });

  describe("takeWhile()", () {
    it("returns a $expectedType", () {
      var transformed = reactable.takeWhile((_) => false);
      expect(transformed.runtimeType == expectedType).toBeTruthy();
    });
  });

  describe("takeUntil()", () {
    it("returns a $expectedType", () {
      var transformed = reactable.takeUntil(new Stream.fromIterable([]));
      expect(transformed.runtimeType == expectedType).toBeTruthy();
    });
  });

  describe("timeout()", () {
    it("returns a $expectedType", () {
      var transformed = reactable.timeout(new Duration(milliseconds: 10));
      expect(transformed.runtimeType == expectedType).toBeTruthy();
    });
  });

  describe("transform()", () {
    it("returns a $expectedType", () {
      var transformed = reactable.transform(new StreamTransformer.fromHandlers());
      expect(transformed.runtimeType == expectedType).toBeTruthy();
    });
  });

  describe("when()", () {
    it("returns a $expectedType", () {
      var transformed = reactable.when(new Stream.fromIterable([]));
      expect(transformed.runtimeType == expectedType).toBeTruthy();
    });
  });

  describe("where()", () {
    it("returns a $expectedType", () {
      var transformed = reactable.where((e) => true);
      expect(transformed.runtimeType == expectedType).toBeTruthy();
    });
  });

  describe("zip()", () {
    it("returns a $expectedType", () {
      var transformed = reactable.zip(new Stream.fromIterable([]), (a, b) => [a, b]);
      expect(transformed.runtimeType == expectedType).toBeTruthy();
    });
  });
});
