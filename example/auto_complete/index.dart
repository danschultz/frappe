import 'dart:convert';
import 'dart:html';
import 'package:frappe/frappe.dart';

void main() {
  var searchInput = querySelector("#searchInput");
  var suggestionsList = querySelector("#suggestions");

  var searchText = new EventStream<Event>(searchInput.onInput)
      .map((event) => event.target.value)
      .distinct();

  var suggestions = searchText
      .debounce(new Duration(milliseconds: 250))
      .doAction((term) => print("Querying `$term`"))
      .flatMapLatest((term) => queryTerm(term))
      .doAction((results) => print("Found ${results.length} results"));

  suggestions.forEach((results) {
    suggestionsList.children
        ..clear()
        ..addAll(results.map((result) => new LIElement()..text = result));
  });
}

EventStream<Iterable<String>> queryTerm(String term) {
  if (term.length > 2) {
    var params = {
        "api_key": "9eae05e667b4d5d9fbb75d27622347fe",
        "query": term
    };

    var uri = Uri.parse("http://api.themoviedb.org/3/search/movie").replace(queryParameters: params);
    var results = HttpRequest.getString(uri.toString())
        .then((response) => JSON.decode(response))
        .then((json) => json["results"].map((result) => result["original_title"]));

    return new EventStream.fromFuture(results);
  } else {
    return new EventStream.single([]);
  }
}
