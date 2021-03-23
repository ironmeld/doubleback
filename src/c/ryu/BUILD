package(default_visibility=["//visibility:public"])

cc_library(
  name = "ryu",
  srcs = [
    "d2s.c",
    "d2s_full_table.h",
    "d2s_small_table.h",
    "d2s_intrinsics.h",
    "digit_table.h",
    "common.h",
  ],
  hdrs = ["ryu.h"],
)

cc_library(
  name = "ryu_parse",
  srcs = [
    "s2d.c",
    "d2s_intrinsics.h",
    "d2s_full_table.h",
    "d2s_small_table.h",
    "common.h",
  ],
  hdrs = ["ryu_parse.h"],
)

cc_library(
  name = "common",
  hdrs = [
    "common.h",
  ],
  testonly = True,
  visibility=["//ryu/tests:__pkg__"],
)

cc_library(
  name = "d2s_intrinsics",
  hdrs = [
    "common.h",
    "d2s_intrinsics.h",
  ],
  testonly = True,
  visibility=["//ryu/tests:__pkg__"],
)

