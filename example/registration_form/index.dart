import 'dart:async';
import 'dart:html';
import 'dart:math';
import 'package:frappe/frappe.dart';

InputElement usernameInput = querySelector("#username");
Element usernameAvailable = querySelector("#usernameAvailable");
InputElement fullnameInput = querySelector("#fullname");
ButtonElement registerButton = querySelector("#register");
Element result = querySelector("#result");

void main() {
  var username = new Property<String>.fromStreamWithInitialValue(usernameInput.value, usernameInput.onInput.map(inputValue));
  var fullname = new Property<String>.fromStreamWithInitialValue(fullnameInput.value, fullnameInput.onInput.map(inputValue));

  var isUsernameValid = username.map((value) => value.isNotEmpty);
  var isFullnameValid = fullname.map((value) => value.isNotEmpty);
  var isUsernameAvailable =
      username
          .changes
          .flatMapLatest((value) => new Stream.fromFuture(fetchIsUsernameAvailable(value)));
  var isValid =
      isUsernameValid
          .combine(isFullnameValid, (a, b) => a && b)
          .combine(isUsernameAvailable, (a, b) => a && b)
          .asPropertyWithInitialValue(false);

  var onSubmit =
      new EventStream(usernameInput.onKeyUp.where(isEnterKey))
          .merge(fullnameInput.onKeyUp.where(isEnterKey))
          .merge(registerButton.onClick)
          .when(isValid);

  var onRequestRegistration =
      username
          .combine(fullname, (username, fullname) => register(username, fullname))
          .sampleOn(onSubmit);

  username.changes.forEach((_) => usernameAvailable.text = "");

  isUsernameAvailable
      .doAction((value) => print("Username available? $value"))
      .where((value) => !value)
      .forEach((value) => usernameAvailable.text = "Sorry, username is taken");

  isValid
      .distinct()
      .doAction((value) => print("Form valid? $value"))
      .forEach((value) => registerButton.disabled = !value);

  onRequestRegistration
      .doAction((_) => print("Registering ..."))
      .asyncMap((request) => request)
      .doAction((_) => print("Registered!"))
      .forEach((_) => result.text = "Thanks, you're registered!");
}

Future<bool> fetchIsUsernameAvailable(String username) {
  return new Future.delayed(randomDelay(), () => username.length % 2 == 0);
}

Future<bool> register(String username, String fullname) {
  return new Future.delayed(randomDelay() * 4, () => true);
}

Duration randomDelay() => new Duration(milliseconds: new Random().nextInt(500) + 500);

String inputValue(Event event) => event.target.value;

bool isEnterKey(KeyboardEvent event) => event.keyCode == 13;
