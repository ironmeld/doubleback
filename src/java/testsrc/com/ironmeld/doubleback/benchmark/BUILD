package(default_visibility=["//visibility:public"])

java_binary(
  name = "benchmark",
  main_class = "com.ironmeld.doubleback.benchmark.BenchmarkMain",
  srcs = glob(["*.java"]),
  deps = [
    "//src/com/ironmeld/doubleback",
    "//third_party/jaffer",
    "//third_party/mersenne_java",
  ],
  # Travis CI: No Java support on Windows.
  tags = ["nowindows"],
)
