# Changelog

## 0.4.0 (03/02/2015)

- Fix an issue where `EventStream`s wouldn't be the same type of stream as its source [#17](https://github.com/danschultz/frappe/issues/17)
- Transformation methods on `Property` or `EventStream` now return the same type of `Reactable`
- Add `Reactable.concat()`
- Add `Reactable.concatAll()`
- Add `Reactable.doAction()`
- Add `Reactable.mergeAll()`
- Add `Reactable.sampleOn()`
- Add `Reactable.samplePeriodically()`
- Add `Reactable.selectFirst()`
- Add `Reactable.startWith()`
- Add `Reactable.startWithValues()`
- Add `Reactable.zip()`
- Add `EventStream.empty()` constructor
- Add `EventStream.single()` constructor
- Add `EventStream.periodic()` constructor
- Bug fixes in `Reactable.isWaitingOn()`
- Deprecate `Reactable.asStream()`, it's now `Reactable.asEventStream()`
- Deprecate `Property` operator overrides, `equals()`, `>`, `>=`, `<`, `<=`, `+`, `-`, `*`, `/`
- `Property.and()` and `Property.or()` can now accept any stream
- `Property.not()` has been moved to `Reactable`
- Remove type declerations for `Reactable.scan()`

## 0.3.2+1 (01/10/2015)

- Move stream transformation classes to the *[stream_transformers]* package.

[stream_transformers]: https://github.com/frappe-dart/stream_transformers
