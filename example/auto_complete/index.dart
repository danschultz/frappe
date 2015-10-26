import 'dart:async';
import 'dart:convert';
import 'dart:html';

import 'package:frappe/frappe.dart';

void main() {
  var searchInput = querySelector("#searchInput");
  var suggestionsList = querySelector("#suggestions");

  var searchText = new EventStream(searchInput.onInput.map((event) => event.target.value));

  var suggestions =
      searchText
          .debounce(new Duration(milliseconds: 250))
          .doAction((term) => print("Querying `$term`"))
          .flatMapLatest((term) => queryTerm(term))
          .doAction((results) => print("Found ${results.length} results"));

  var isPending = searchText.isWaitingOn(suggestions);

  isPending
      .where((value) => value)
      .forEach((_) => suggestionsList.children..clear()..add(new DivElement()..text = "Loading ..."));

  suggestions.forEach((results) =>
      suggestionsList.children
          ..clear()
          ..addAll(results.map((result) => new LIElement()..text = result)));
}

EventStream<Iterable<String>> queryTerm(String term) {
  if (term.length > 2) {
    Map<String, String> params = {
        "api_key": "9eae05e667b4d5d9fbb75d27622347fe",
        "query": term
    };

    var uri = Uri.parse("http://api.themoviedb.org/3/search/movie").replace(queryParameters: params);
    Future<Iterable<String>> results = HttpRequest.getString(uri.toString())
        .then((response) => JSON.decode(response))
        .then((json) => json["results"].map((result) => result["original_title"]));

    return new EventStream.fromFuture(results);
  } else {
    return new EventStream.fromValue([]);
  }
}
