package(default_visibility=["//visibility:public"])

cc_binary(
  name = "ryu_benchmark_shortest",
  srcs = ["benchmark_shortest.c"],
  deps = [
    "//doubleback:dfmt",
    "//doubleback:dparse",
    "//third_party/mersenne",
  ],
  copts = ["-std=c99"],
)
