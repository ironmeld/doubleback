CONVERSION_CMD_RYU="".join([
    "TMP_FILE=$$(mktemp /tmp/plot.XXXXXX)",
    " && cat $(location %s.template)",
    "  | sed \"s|INPUT_FILE|$<|g\"",
    "  | sed \"s|COMPARISON_NAME_1|%s|g\"",
    "  | sed \"s|COMPARISON_NAME_2|%s|g\"",
    "  > $${TMP_FILE}",
    " && gnuplot $${TMP_FILE} > $@",
    " && rm -f $${TMP_FILE}"])

[genrule(
  name = "shortest-" + t + "-" + f + "-csv",
  tools = [dep],
  outs = ["shortest-" + t + "-" + f + ".csv"],
  cmd = "$(location " + dep + ") " + o + " -classic -samples=1000 -v > $@",
) for (t,f,o,dep) in [
    ("c", "float", "-32", "//ryu/benchmark:ryu_benchmark"),
    ("c", "double", "-64", "//ryu/benchmark:ryu_benchmark"),
]]

[genrule(
  name = "shortest-" + t + "-" + f + "-pdf",
  srcs = ["shortest-" + t + "-" + f + ".csv"],
  tools = [f + ".template"],
  outs = ["shortest-" + t + "-" + f + ".pdf"],
  cmd = CONVERSION_CMD_RYU % (f, c, d),
) for (t,c,d) in [("c","Grisu3","")] for f in ["float","double"]]

CONVERSION_CMD_RYU_PRINTF="".join([
    "TMP_FILE=$$(mktemp /tmp/plot.XXXXXX)",
    " && cat $(location %s.template)",
    "  | sed \"s|INPUT_FILE|$<|g\"",
    "  | sed \"s|COMPARISON_NAME_1|%s|g\"",
    "  > $${TMP_FILE}",
    " && gnuplot $${TMP_FILE} > $@",
    " && rm -f $${TMP_FILE}"])

[genrule(
  name = "f-" + t + "-" + f + "-" + p + "-csv",
  tools = [dep],
  outs = ["f-" + t + "-" + f + "-" + p + ".csv"],
  cmd = "$(location " + dep + ") " + o + " -classic -samples=2000 -precision=" + p + " -v > $@",
) for (t,f,o,dep) in [
    ("c", "double", "-f", "//ryu/benchmark:ryu_printf_benchmark"),
  ]
  for p in ["1", "10", "100", "1000"]
]

[genrule(
  name = "f-" + t + "-" + f + "-" + p + "-pdf",
  srcs = ["f-" + t + "-" + f + "-" + p + ".csv"],
  tools = ["printf.template"],
  outs = ["f-" + t + "-" + f + "-" + p + ".pdf"],
  cmd = CONVERSION_CMD_RYU_PRINTF % ("printf", c),
) for (t,c,d) in [("c","snprintf","")] for f in ["double"]
  for p in ["1", "10", "100", "1000"]
]

[genrule(
  name = "e-" + t + "-" + f + "-" + p + "-csv",
  tools = [dep],
  outs = ["e-" + t + "-" + f + "-" + p + ".csv"],
  cmd = "$(location " + dep + ") " + o + " -classic -samples=2000 -precision=" + p + " -v > $@",
) for (t,f,o,dep) in [
    ("c", "double", "-e", "//ryu/benchmark:ryu_printf_benchmark"),
  ]
  for p in ["1", "10", "100", "1000"]
]

[genrule(
  name = "e-" + t + "-" + f + "-" + p + "-pdf",
  srcs = ["e-" + t + "-" + f + "-" + p + ".csv"],
  tools = ["printf.template"],
  outs = ["e-" + t + "-" + f + "-" + p + ".pdf"],
  cmd = CONVERSION_CMD_RYU_PRINTF % ("printf", c),
) for (t,c,d) in [("c","snprintf","")] for f in ["double"]
  for p in ["1", "10", "100", "1000"]
]

[genrule(
  name = "shortest-native-" + t + "-" + f + "-csv",
  tools = [dep],
  outs = ["shortest-native-" + t + "-" + f + ".csv"],
  cmd = "$(location " + dep + ") -classic -samples=500 -v > $@",
) for (t,f,dep) in [
    ("c", "double", "//ryu/benchmark:ryu_benchmark_shortest"),
  ]
]

CONVERSION_CMD_RYU_SHORTEST="".join([
    "TMP_FILE=$$(mktemp /tmp/plot.XXXXXX)",
    " && cat $(location %s.template)",
    "  | sed \"s|INPUT_FILE|$<|g\"",
    "  | sed \"s|LANGUAGE|%s|g\"",
    "  | sed \"s|COMPARISON_NAME_1|%s|g\"",
    "  | sed \"s|COMPARISON_NAME_2|%s|g\"",
    "  > $${TMP_FILE}",
    " && gnuplot $${TMP_FILE} > $@",
    " && rm -f $${TMP_FILE}"])

[genrule(
  name = "shortest-native-" + t + "-" + f + "-pdf",
  srcs = ["shortest-native-" + t + "-" + f + ".csv"],
  tools = ["shortest.template"],
  outs = ["shortest-native-" + t + "-" + f + ".pdf"],
  cmd = CONVERSION_CMD_RYU_SHORTEST % ("shortest", t, c, d),
) for (t,c,d) in [("c","snprintf %.17g","Doubleback dfmt")] for f in ["double"]
]

[genrule(
  name = "shortest-native-" + t + "-" + f + "-summary-csv",
  tools = [dep],
  outs = ["shortest-native-" + t + "-" + f + "-summary.csv"],
  cmd = "$(location " + dep + ") -csv -classic -samples=500 > $@",
) for (t,f,dep) in [
    ("c", "double", "//ryu/benchmark:ryu_benchmark_shortest"),
  ]
]

[genrule(
  name = "shortest-native-" + t + "-" + f + "-time-pdf",
  srcs = ["shortest-native-" + t + "-" + f + "-summary.csv"],
  tools = ["shortest-native-time.template"],
  outs = ["shortest-native-" + t + "-" + f + "-time.pdf"],
  cmd = CONVERSION_CMD_RYU_SHORTEST % ("shortest-native-time", t, c, d),
) for (t,c,d) in [("c","snprintf %.17g","Doubleback dfmt")] for f in ["double"]
]

[genrule(
  name = "shortest-native-" + t + "-" + f + "-time-png",
  srcs = ["shortest-native-" + t + "-" + f + "-summary.csv"],
  tools = ["shortest-native-time-png.template"],
  outs = ["shortest-native-" + t + "-" + f + "-time.png"],
  cmd = CONVERSION_CMD_RYU_SHORTEST % ("shortest-native-time-png", t, c, d),
) for (t,c,d) in [("c","snprintf %.17g","Doubleback dfmt")] for f in ["double"]
]

[genrule(
  name = "shortest-native-" + t + "-" + f + "-length-pdf",
  srcs = ["shortest-native-" + t + "-" + f + "-summary.csv"],
  tools = ["shortest-native-length.template"],
  outs = ["shortest-native-" + t + "-" + f + "-length.pdf"],
  cmd = CONVERSION_CMD_RYU_SHORTEST % ("shortest-native-length", t, c, d),
) for (t,c,d) in [("c","snprintf %.17g","Doubleback dfmt")] for f in ["double"]
]

[genrule(
  name = "shortest-native-" + t + "-" + f + "-length-png",
  srcs = ["shortest-native-" + t + "-" + f + "-summary.csv"],
  tools = ["shortest-native-length-png.template"],
  outs = ["shortest-native-" + t + "-" + f + "-length.png"],
  cmd = CONVERSION_CMD_RYU_SHORTEST % ("shortest-native-length-png", t, c, d),
) for (t,c,d) in [("c","snprintf %.17g","Doubleback dfmt")] for f in ["double"]
]

[genrule(
  name = "shortest-native-" + t + "-" + f + "-parse-pdf",
  srcs = ["shortest-native-" + t + "-" + f + "-summary.csv"],
  tools = ["shortest-native-parse.template"],
  outs = ["shortest-native-" + t + "-" + f + "-parse.pdf"],
  cmd = CONVERSION_CMD_RYU_SHORTEST % ("shortest-native-parse", t, c, d),
) for (t,c,d) in [("c","snprintf %.17g","Doubleback dfmt")] for f in ["double"]
]

[genrule(
  name = "shortest-native-" + t + "-" + f + "-parse-png",
  srcs = ["shortest-native-" + t + "-" + f + "-summary.csv"],
  tools = ["shortest-native-parse-png.template"],
  outs = ["shortest-native-" + t + "-" + f + "-parse.png"],
  cmd = CONVERSION_CMD_RYU_SHORTEST % ("shortest-native-parse-png", t, c, d),
) for (t,c,d) in [("c","snprintf %.17g","Doubleback dfmt")] for f in ["double"]
]
