cc_test(
  name = "d2s_test",
  srcs = ["d2s_test.cc"],
  deps = [
    "//ryu",
    "//third_party/gtest",
  ],
)

cc_test(
  name = "s2d_test",
  srcs = ["s2d_test.cc"],
  deps = [
    "//ryu:ryu_parse",
    "//third_party/gtest",
  ],
)

cc_test(
  name = "d2s_table_test",
  srcs = ["d2s_table_test.cc"],
  deps = [
    "//ryu",
    "//third_party/gtest",
  ],
)

cc_test(
  name = "dfmt_test",
  srcs = ["dfmt_test.cc"],
  deps = [
    "//ryu",
    "//third_party/gtest",
  ],
)

cc_binary(
  name = "dfmt_echo",
  srcs = ["dfmt_echo.c"],
  deps = [
    "//ryu",
    "//ryu:ryu_parse",
  ],
)
