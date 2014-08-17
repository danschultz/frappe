# Frappé

A mildly [Bacon.js](http://baconjs.github.io/) inspired Dart package that aims to make functional reactive programming (FRP) easier in Dart. Frappé extends the behavior of Dart's streams, and introduces new concepts like properties and reactables.

You can explore the full API here: http://www.dartdocs.org/documentation/frappe/latest.

## Why Frappé?
Functional reactive programming allows you to declaratively define behaviors for user actions. FRP makes it clearer to define behaviors such as, "when a user performs A, do X and Y, then finish with Z."

To illustrate this, let's write an autocomplete widget with Frappé. After 250ms that a user inputs a character, a query is performed that suggests a list of movies that most closely matches the user's input. Because query results are asynchronous, we only want to show results from the last query.

```dart
var searchInput = document.querySelector("#searchInput");

var onInput = new EventStream(searchInput.onKeyUp)
    .debounce(new Duration(milliseconds: 250)
    .map((event) => event.target.value)
    .distinct();
    
var suggestions = onInput.flatMapLatest((input) => querySuggestions(input));
var isPending = onInput.isWaitingOn(suggestions);
    
Future<List<String>> querySuggestions(String input) {
  // Query some API that returns suggestions for 'input'
}
```

Frappe also makes it easy to merge multiple stream. This is useful for performing an action that's triggered from multiple user behaviors. For instance to signal the close of an application:

```dart
var onQuit = new EventStream(quitButton.onClick)
    .merge(fileMenu.querySelector("quit").onClick)
    .merge(fatalErrors);
    
onQuit.listen((_) => closeApp());
```

It's often useful to unsubscribe from a stream after a user performs some action. Frappe makes this easy with `takeUntil`. For instance, we can start listening to `onMouseMove` after `onMouseDown`, and unsubscribe after `onMouseUp`:

```dart
window.onMouseDown.forEach((mouseDown) {
  var pen = new Pen(mouseDown.client);
  new EventStream(window.onMouseMove).takeUntil(window.onMouseUp.first)
      .forEach((mouseMove) => pen.drawTo(mouseMove.client))
      .then((_) => pen.done())
})
```

## Classes

### Reactable
The `Reactable` class is what `EventStream` and `Property` extend from. It unifies the interface for classes that deliver events. At its heart, it defines a method `listen()`, which has the same behavior as Dart's `Stream.listen()`. In the same way that you'd listen to a Dart `Stream`, you'd use this method to subscribe to events from a `Reactable`, and use the returned `StreamSubscription` to unsubscribe from the stream.

### EventStream
An `EventStream` is just like a `Stream` in Dart. It inherits the same interface as a `Stream`, but extends its functionality with methods like `merge`, `scan` and `takeUntil`. Since `EventStream` just extends from `Stream`, it's easy to compose streams from either Frappé or Dart.

### Property
Properties are similar to streams, but they remember their last value. This means that if a property has previously emitted the value of **x** to its subscribers, it will deliver this value to any of its new subscribers.

For instance, a property could be used to unify synchronous and asynchronous calls to get the window's current size:

```dart
Map innerSize() => {"width": window.innerWidth, "height": window.innerHeight};

var windowSize = new Property.fromStreamWithInitialValue(innerSize(),
    window.onResize.map((_) => innerSize()));

print(innerSize()); // hypothetical window size {"width": 1024, "height": 768}

// The first call to `listen` will deliver the property's current value. Since 
// this is the first subscriber, the value of {"width": 1024, "height": 768} will 
// be printed. Resizing the window will print out the window's new size.
windowSize.listen((size) => print(size));
```

#### Creating Properties
The `Property` class has constructors to create properties from a `Stream` or a `Future`.

```dart
// Create a property from a Dart Stream
Property.fromStream(stream);

// Create a property from a Future.
Property.fromFuture(futureValue);
```

You can also create a property that has a constant value.

```dart
var constant = new Property.constant(5);
constant.listen((value) => print(value)); // 5
```

An `EventStream` can also be converted into a `Property` with `EventStream.asProperty()`.

##### Initial Values
When creating a property from a stream or a future, the property will not have an initial value. Frappé includes additional constructors to create properties that have a starting value.

```dart
// Create a property from a stream with an initial value.
Property.fromStreamWithInitialValue(stream, initialValue);

// Create a property from a Future with an initial value.
Property.fromFutureWithInitialValue(futureValue, initialValue);
```

#### Combining Properties
Properties can be combined with each other to create derived values. These values will be recomputed whenever the value changes from which the property was derived.

Frappé includes many built in combinators that you can use, such as `and`, `or`, `equals`, and also operator combinators like `+`, `-`, `>`, `<`. For instance in the following example, the enabled state of a login button is updated whenever the form's fields change. In order for the form to be valid, both the username and password fields must be populated.

```dart
bool isNotEmpty(String value) => value != null && value.isNotEmpty;

var isUsernamePresent = new Property
    .fromStream(usernameField.onChange.map((_) => usernameField.value))
    .map(isNotEmpty);
var isPasswordPresent = new Property
    .fromStream(passwordField.onChange.map((_) => passwordField.value))
    .map(isNotEmpty);
    
var isFormValid = isUsernamePresent.and(isPasswordPresent);
isFormValid.listen((isValid) => submitButton.disabled = !isValid);
```
