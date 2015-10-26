import 'package:grinder/grinder.dart';

main(List<String> args) => grind(args);

@Task("Analyzes the package for errors or warnings")
analyze() {
  new PubApp.global('tuneup').run(['check']);
}

@Task("Checks that Dart code adheres to the style guide")
lint() {
  new PubApp.global('linter').run(["example/", "lib/", "test/"]);
}

@Task()
test() => Tests.runCliTests(testFile: "all_tests.dart");

@DefaultTask()
@Depends(analyze, test, lint)
build() { }
