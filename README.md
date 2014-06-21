# Relay

A slightly [Bacon.js](http://baconjs.github.io/) inspired Dart package to make functional reactive programming easier in Dart. Relay extends the behavior of Dart's streams, and introduces a concept of dynamic values called properties.

## EventStream
Relay makes it easy to compose streams. Like combining the mouse down, mouse move and mouse up events for drawing:

```
window.onMouseDown.forEach((mouseDown) {
  var pen = new Pen(mouseDown.client);
  new EventStream(window.onMouseMove).takeUntil(window.onMouseUp)
      .forEach((mouseMove) => pen.drawTo(mouseMove.client))
      .then((_) => pen.done())
})
```

Or, merging multiple streams to signal the close of your application:

```
new EventStream(quitButton.onClick)
    .merge(fileMenu.querySelector("quit").onClick)
    .merge(fatalErrors)
    .listen((_) => closeApp());
```

## Properties
Properties introduce a concept of a current value to a stream. Unlike streams, each subscription to a property return its latest value.

For instance, a property could be used to unify synchronous and asynchronous calls to get the current window size:

```
Size innerSize() => new Size(window.innerWidth, window.innerHeight);

var windowSize = new Property.fromStreamWithInitialValue(innerSize(),
    window.onResize.map((_) => innerSize()));

print(innerSize()); // hypothetical window size {"width": 1024, "height": 768}
windowSize.listen((size) => print(size)); // {"width": 1024, "height": 768}
windowSize.listen((size) => print(size)); // {"width": 1024, "height": 768}
```

Properties can also be combined. Their values are recomputed whenever their dependencies change. For instance, `isFormValid` updates whenever a character is entered into the username or password fields:

```
bool isPresent(String value) => value != null;

var isUsernamePresent = new Property
    .fromStream(usernameField.onChange.map((_) => usernameField.value))
    .map(isPresent);
var isPasswordPresent = new Property
    .fromStream(passwordField.onChange.map((_) => passwordField.value))
    .map(isPresent);
    
var isFormValid = isUsernamePresent.and(isPasswordPresent);
```