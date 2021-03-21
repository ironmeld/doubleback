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

# Charts for "shortest" and corresponding implementations

# Generate data using doubles from 64bit ints
[genrule(
  name = lang + "-double-shortest-64bit-data-csv",
  tools = [dep],
  outs = [lang + "-double-shortest-64bit-data.csv"],
  cmd = "$(location " + dep + ") -data -csv -samples=500 > $@",
) for (lang,dep) in [
    ("c", "//ryu/benchmark:ryu_benchmark_shortest"),
  ]
]

# This is the gnuplot chart command, which supports naming the
# programming language and up to three data series to compare.
CONVERSION_CMD_RYU_SHORTEST="".join([
    "TMP_FILE=$$(mktemp /tmp/plot.XXXXXX)",
    " && cat $(location %s.template)",
    "  | sed \"s|INPUT_FILE|$<|g\"",
    "  | sed \"s|LANGUAGE|%s|g\"",
    "  | sed \"s|SERIES1|%s|g\"",
    "  | sed \"s|SERIES2|%s|g\"",
    "  | sed \"s|SERIES3|%s|g\"",
    "  > $${TMP_FILE}",
    " && gnuplot $${TMP_FILE} > $@",
    " && rm -f $${TMP_FILE}"])

# Generate the chart for raw data
[genrule(
  name = lang + "-double-shortest-64bit-data-pdf",
  srcs = [lang + "-double-shortest-64bit-data.csv"],
  tools = ["shortest.template"],
  outs = [lang + "-double-shortest-64bit-data.pdf"],
  cmd = CONVERSION_CMD_RYU_SHORTEST % ("shortest", lang, s1, s2, s3),
) for (lang,s1,s2,s3) in [("c","snprintf %.17g","Ryū shortest","Doubleback dfmt")]
]

# Generate stats using doubles grouped by number of digits
[genrule(
  name = lang + "-double-shortest-bydigits-summary-csv",
  tools = [dep],
  outs = [lang + "-double-shortest-bydigits-summary.csv"],
  cmd = "$(location " + dep + ") -csv -samples=500 > $@",
) for (lang,dep) in [
    ("c", "//ryu/benchmark:ryu_benchmark_shortest"),
  ]
]

# Generate stats using doubles grouped by number of digits
[genrule(
  name = lang + "-double-shortest-bydigits-time-pdf",
  srcs = [lang + "-double-shortest-bydigits-summary.csv"],
  tools = ["shortest-time.template"],
  outs = [lang + "-double-shortest-bydigits-time.pdf"],
  cmd = CONVERSION_CMD_RYU_SHORTEST % ("shortest-time", lang, s1, s2, s3),
) for (lang,s1,s2,s3) in [("c","snprintf %.17g","Ryū shortest","Doubleback dfmt")]
]

[genrule(
  name = lang + "-double-shortest-bydigits-time-png",
  srcs = [lang + "-double-shortest-bydigits-summary.csv"],
  tools = ["shortest-time-png.template"],
  outs = [lang + "-double-shortest-bydigits-time.png"],
  cmd = CONVERSION_CMD_RYU_SHORTEST % ("shortest-time-png", lang, s1, s2, s3),
) for (lang,s1,s2,s3) in [("c","snprintf %.17g","Ryū shortest","Doubleback dfmt")]
]

[genrule(
  name = lang + "-double-shortest-bydigits-length-pdf",
  srcs = [lang + "-double-shortest-bydigits-summary.csv"],
  tools = ["shortest-length.template"],
  outs = [lang + "-double-shortest-bydigits-length.pdf"],
  cmd = CONVERSION_CMD_RYU_SHORTEST % ("shortest-length", lang, s1, s2, s3),
) for (lang,s1,s2,s3) in [("c","snprintf %.17g","Ryū shortest","Doubleback dfmt")]
]

[genrule(
  name = lang + "-double-shortest-bydigits-length-png",
  srcs = [lang + "-double-shortest-bydigits-summary.csv"],
  tools = ["shortest-length-png.template"],
  outs = [lang + "-double-shortest-bydigits-length.png"],
  cmd = CONVERSION_CMD_RYU_SHORTEST % ("shortest-length-png", lang, s1, s2, s3),
) for (lang,s1,s2,s3) in [("c","snprintf %.17g","Ryū shortest","Doubleback dfmt")]
]

[genrule(
  name = lang + "-double-shortest-bydigits-parse-pdf",
  srcs = [lang + "-double-shortest-bydigits-summary.csv"],
  tools = ["shortest-parse.template"],
  outs = [lang + "-double-shortest-bydigits-parse.pdf"],
  cmd = CONVERSION_CMD_RYU_SHORTEST % ("shortest-parse", lang, s1, s2, s3),
) for (lang,s1,s2,s3) in [("c","snprintf %.17g","Ryū shortest","Doubleback dfmt")]
]

[genrule(
  name = lang + "-double-shortest-bydigits-parse-png",
  srcs = [lang + "-double-shortest-bydigits-summary.csv"],
  tools = ["shortest-parse-png.template"],
  outs = [lang + "-double-shortest-bydigits-parse.png"],
  cmd = CONVERSION_CMD_RYU_SHORTEST % ("shortest-parse-png", lang, s1, s2, s3),
) for (lang,s1,s2,s3) in [("c","snprintf %.17g","Ryū shortest","Doubleback dfmt")]
]
