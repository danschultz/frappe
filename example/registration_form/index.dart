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
  var isCheckingUsername = username.changes.isWaitingOn(isUsernameAvailable);

  var isValid =
      isUsernameValid
          .combine(isFullnameValid, (a, b) => a && b)
          .combine(isUsernameAvailable, (a, b) => a && b)
          .distinct()
          .doAction((value) => print("Form valid? $value"))
          .asPropertyWithInitialValue(false);

  var onSubmit =
      new EventStream(registerButton.onClick)
          .doAction((_) => print("Submitting ..."));

  var onRequestRegistration =
      username
          .combine(fullname, (username, fullname) => () => registerUser(username, fullname))
          .sampleOn(onSubmit)
          .asyncMap((registerUser) => registerUser())
          .asEventStream()
          .doAction((_) => print("Registered!"));
  var isSubmittingRegistration = onSubmit.isWaitingOn(onRequestRegistration);

  var canSubmit =
      isValid
          .and(isCheckingUsername.map((value) => !value))
          .and(isSubmittingRegistration.map((value) => !value));

  isCheckingUsername
      .where((value) => value)
      .forEach((_) => usernameAvailable.text = "Checking ...");

  isUsernameAvailable
      .doAction((value) => print("Username available? $value"))
      .forEach((value) => usernameAvailable.text = value ? "Available" : "Sorry, username is taken");

  canSubmit.forEach((value) => registerButton.disabled = !value);

  isSubmittingRegistration.where((value) => value).forEach((_) => result.text = "Registering ...");
  onRequestRegistration.forEach((id) => result.text = "Thanks, your user ID is $id!");
}

Future<bool> fetchIsUsernameAvailable(String username) {
  return new Future.delayed(randomDelay(), () => username.length % 2 == 0);
}
Future<int> registerUser(String username, String fullname) {
  return new Future.delayed(randomDelay() * 4, () => username.hashCode + fullname.hashCode);
}

Duration randomDelay() => new Duration(milliseconds: new Random().nextInt(500) + 500);

String inputValue(Event event) => (event.target as InputElement).value;
