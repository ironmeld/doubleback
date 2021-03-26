package(default_visibility=["//visibility:public"])

java_test(
  name = "doubleback",
  test_class = "com.ironmeld.doubleback.AllTests",
  srcs = glob(["*.java"]),
  deps = [
    "//src/com/ironmeld/doubleback",
    "//testsrc/com/ironmeld/doubleback/analysis",
    "//third_party/jaffer",
    "//third_party/junit",
  ],
  # Travis CI: No Java support on Windows.
  tags = ["nowindows"],
)

java_binary(
  name = "dfmtecho",
  main_class = "com.ironmeld.doubleback.DfmtEcho",
  srcs = ["DfmtEcho.java"],
  deps = [
    "//src/com/ironmeld/doubleback",
  ],
  # Travis CI: No Java support on Windows.
  tags = ["nowindows"],
)
