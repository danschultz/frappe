# Registration form demo

A registration form demo that behaves like the one described in BaconJS's [tutorial](http://baconjs.github.io/tutorials.html).

This simple registration form includes a laundry list of features:

- [x] Username availability checking while the user is still typing the username
- [x] Showing feedback on unavailable username
- [x] Showing an AJAX indicator while this check is being performed
- [x] Disabling the Register button until both username and fullname have been entered
- [x] Disabling the Register button in case the username is unavailable
- [x] Disabling the Register button while the check is being performed
- [x] Disabling the Register button immediately when pressed to prevent double-submit
- [ ] Showing an AJAX indicator while registration is being processed
- [x] Showing feedback after registration

You can try out the demo for yourself [here](http://danschultz.github.io/frappe/examples/registration_form/).

## Overview

With Frappe, you setup signal graphs that transform input events, and side effects for when these events propagate through your app and cause the signals to change. These side effects can be in the form of modifying the DOM or saving application state to some external store.

For instance in this demo, we've setup signal graphs for validating a form. If the form isn't valid, the registration button should be disabled. Some validations might happen locally, such as a username or fullname being entered, and some validations happen on the server, such as if the username is available. A server validation is just another type of input into the system. Instead of it being input by the user, it's input from the network. For simplicity, this demo mocks server validations.

As a user inputs text into these fields, the signals capture these events, run their validations and either enable or disable the registration button.

```dart
var username = new Property<String>.fromStreamWithInitialValue(usernameInput.value, usernameInput.onInput.map(inputValue));
var fullname = new Property<String>.fromStreamWithInitialValue(fullnameInput.value, fullnameInput.onInput.map(inputValue));

var isUsernameValid = username.map((value) => value.isNotEmpty);
var isFullnameValid = fullname.map((value) => value.isNotEmpty);
var isUsernameAvailable =
    username
        .changes
        .debounce(new Duration(milliseconds: 250))
        .flatMapLatest((value) => new Stream.fromFuture(fetchIsUsernameAvailable(value)));

var isValid =
      isUsernameValid
          .combine(isFullnameValid, (a, b) => a && b)
          .combine(isUsernameAvailable, (a, b) => a && b)
          .distinct()
          .asPropertyWithInitialValue(false);

isValid.listen((value) => registerButton.disabled = !value);
```

## Running

You can try out the demo [here](http://danschultz.github.io/frappe/examples/registration_form/). Otherwise, you can clone the project and run the example locally:

* `pub serve example`
* Open `http://localhost:8080/registration_form/`