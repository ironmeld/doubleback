package(default_visibility=["//visibility:public"])

java_test(
  name = "doubleback",
  test_class = "com.ironmeld.doubleback.AllTests",
  srcs = glob(["*.java"]),
  deps = [
    "//src/com/ironmeld/doubleback",
    "//third_party/jaffer",
    "//third_party/junit",
  ],
)

java_binary(
  name = "dfmtecho",
  main_class = "com.ironmeld.doubleback.DfmtEcho",
  srcs = ["DfmtEcho.java"],
  deps = [
    "//src/com/ironmeld/doubleback",
  ],
)
