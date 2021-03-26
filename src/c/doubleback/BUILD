package(default_visibility=["//visibility:public"])

cc_library(
  name = "dfmt",
  srcs = [
    "dfmt.c",
    "ryu_full_table.h",
    "ryu_small_table.h",
    "common.h",
  ],
  hdrs = ["dfmt.h"],
)

cc_library(
  name = "dparse",
  srcs = [
    "dparse.c",
    "ryu_full_table.h",
    "ryu_small_table.h",
    "common.h",
  ],
  hdrs = ["dparse.h"],
)

cc_library(
  name = "common",
  hdrs = [
    "common.h",
  ],
  testonly = True,
  visibility=["//doubleback/tests:__pkg__"],
)
