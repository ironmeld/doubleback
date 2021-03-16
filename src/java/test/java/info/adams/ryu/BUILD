package(default_visibility=["//visibility:public"])

java_test(
  name = "ryu",
  test_class = "info.adams.ryu.AllTests",
  srcs = glob(["*.java"]),
  deps = [
    "//main/java/info/adams/ryu",
    "//main/java/info/adams/ryu/analysis",
    "//third_party/jaffer",
    "//third_party/junit",
  ],
  # Travis CI: No Java support on Windows.
  tags = ["nowindows"],
)
