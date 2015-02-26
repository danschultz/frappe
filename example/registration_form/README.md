# Registration form demo

A registration form demo modeled after http://baconjs.github.io/tutorials.html.

Features:

- [x] Username availability checking while the user is still typing the username
- [x] Showing feedback on unavailable username
- [ ] Showing an AJAX indicator while this check is being performed
- [x] Disabling the Register button until both username and fullname have been entered
- [x] Disabling the Register button in case the username is unavailable
- [ ] Disabling the Register button while the check is being performed
- [ ] Disabling the Register button immediately when pressed to prevent double-submit
- [ ] Showing an AJAX indicator while registration is being processed
- [x] Showing feedback after registration

## Running

* `pub serve example`
* Open `http://localhost:8080/registration_form/`