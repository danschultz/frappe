import 'package:grinder/grinder.dart';

main(args) => grind(args);

@Task("Analyzes the package for errors")
analyze() {
  new PubApp.global('tuneup').run(['check']);
}

@Task()
test() => Tests.runCliTests(testFile: "all_tests.dart");

@DefaultTask()
@Depends(analyze, test)
build() {

}