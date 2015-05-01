# Contributing

## Learning Material

Documentation and examples go a long way in helping others learn about Frappe. Building an example yourself can also be a great way to learn about FRP. If you're interested in contributing to our learning material, check [here](https://github.com/danschultz/frappe/issues/37) for ideas. 

## Code Changes

If you'd like to submit a code change, here are some guidelines to follow:

* If you plan on submitting a transformation method, implement it first as a `StreamTransformer` and submit a PR to the [stream_transformers] package.
* All transformation methods should have a unit test that test the following:
  * A transformed `EventStream` that originates from a non-broadcast stream, should return a non-broadcast stream.
  * A transformed `EventStream` that originates from a broadcast stream, should return a broadcast stream.
  * A transformed `Reactable` should return the appropriate `Reactable` sub-class. For example, `EventStream.map()` should return a `EventStream` and `Property.map()` should return a `Property`.
  * Cancellation of a `StreamSubscription` should call the `onCancel` callback of the source `StreamController`.
  * Closing of the source `StreamController` should call the `onDone` callback of `StreamSubscription`s.
  * The expected forwarding behavior for errors.
  * The expected behavior when closing a source stream.
  * The expected transfomed values.
* It's a good idea to run `grind build` before submitting a PR. This runs the Dart Analyzer to check for warnings, the linter to check that code adheres to the Dart style guide, and that unit tests pass.

[stream_transformers]: https://github.com/danschultz/stream_transformers
