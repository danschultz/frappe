# Frappé

[![Build Status](https://travis-ci.org/danschultz/frappe.svg)](https://travis-ci.org/danschultz/frappe)

A functional reactive programming library for Dart. Frappé extends the functionality of Dart's stream, and introduces new concepts like properties.

## Why FRP?

UI applications today are highly interactive and data driven. User input can trigger updates to the DOM, playing of animations, invoking network requests, and modifying application state. Using the traditional form of event callbacks and modifying state variables can quickly become messy and difficult to maintain.

Functional reactive programming (FRP) makes it clearer to define behaviors for user and system events, how state changes in your application, and the result of these changes. With FRP, it's easy to define, "when a user performs A, do X and Y, then output Z."

When writing reactive code, you'll find yourself focusing more on the dependencies between events for business logic, and less time on their implementation details.

## Example

Lets write an auto-complete movie widget with Frappé. The widget has an input field for the movie name, and a list element that displays movies that most closely match the user's input. A working version can be found [here](http://danschultz.github.io/frappe/examples/auto_complete/).

```dart
var searchInput = document.querySelector("#searchInput");
var suggestionsElement = document.querySelector("#suggestions");

var onInput = new EventStream(searchInput.onInput)
    .debounce(new Duration(milliseconds: 250)) // Limit the number of network requests
    .map((event) => event.target.value) // Get the text from the input field
    .distinct(); // Ignore duplicate events with the same text

// Make a network request to get the list of movie suggestions. Because requests
// are asynchronous, they can complete out of order. Use `flatMapLatest` to only
// respond to request for the last text change.
var suggestions = onInput.flatMapLatest((input) => querySuggestions(input));

suggestions.listen((movies) =>
    suggestionsElement.children
        ..clear()
        ..addAll(movies.map((movie) => new LIElement()..text = movie));

// Show "Searching ..." feedback while the request is pending
var isPending = searchInput.onInput.isWaitingOn(suggestions);
isPending.where((value) => value).listen((_) {
  suggestionsElement.children
      ..clear()
      ..add(new DivElement()..text = "Searching ...");
});

Future<List<String>> querySuggestions(String input) {
  // Query some API that returns suggestions for 'input'
}
```

## API

You can explore the full API [here][documentation].

### `Reactable`

The `Reactable` class extends from Stream and is inherited by the `EventStream` and `Property` sub-classes. Because these classes extend from Dart's `Stream`, you can pass them directly to other API's that expect `Stream`.

### `EventStream`

An `EventStream` represents a series of discrete events. It's just like a `Stream` in Dart, but extends its functionality with the methods found on `Reactable`.

### `Property`

A `Property` represents a value that changes over time. They're similar to event streams, but they have a current value. If you were to model text input using properties and streams, the individual key strokes would be events, and the resulting text is a property.

Properties are implemented internally as broadcast streams. Subscription to a property will always receive its current value as its first event.

## Learning More

Definitely take a look at the API [documentation], and play around with some of the [examples]. It's also worth checking out [BaconJS] and [RxJS]. They're both mature FRP libraries, and offer some great resourses on the subject.

## Running Tests

Tests are run using [test_runner].

* Install *test_runner*: `pub global activate test_runner`
* Run *test_runner* inside *frappe*: `pub global run run_tests`

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[documentation]: http://www.dartdocs.org/documentation/frappe/latest
[examples]: https://github.com/danschultz/frappe/tree/master/example
[tracker]: https://github.com/danschultz/frappe/issues
[test_runner]: https://pub.dartlang.org/packages/test_runner
[baconjs]: https://github.com/baconjs/bacon.js
[rxjs]: http://reactive-extensions.github.io/RxJS/
