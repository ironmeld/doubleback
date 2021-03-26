# Charts for "shortest" and corresponding implementations

# Generate data using doubles from 64bit ints
[genrule(
  name = lang + "-double-shortest-64bit-data-csv",
  tools = [dep],
  outs = [lang + "-double-shortest-64bit-data.csv"],
  cmd = "$(location " + dep + ") -data -csv -samples=50 > $@",
) for (lang,dep) in [
    ("java", "//test/java/info/adams/ryu/benchmark"),
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
    "  | sed \"s|SERIES4|%s|g\"",
    "  > $${TMP_FILE}",
    " && gnuplot $${TMP_FILE} > $@",
    " && rm -f $${TMP_FILE}"])

# Generate the chart for raw data
[genrule(
  name = lang + "-double-shortest-64bit-data-pdf",
  srcs = [lang + "-double-shortest-64bit-data.csv"],
  tools = ["shortest.template"],
  outs = [lang + "-double-shortest-64bit-data.pdf"],
  cmd = CONVERSION_CMD_RYU_SHORTEST % ("shortest", lang, s1, s2, s3, s4),
) for (lang,s1,s2,s3,s4) in [("java","jdk","Jaffer","Ryū shortest","Doubleback dfmt")]
]

# Generate stats using doubles grouped by number of digits
[genrule(
  name = lang + "-double-shortest-bydigits-summary-csv",
  tools = [dep],
  outs = [lang + "-double-shortest-bydigits-summary.csv"],
  cmd = "$(location " + dep + ") -csv -samples=50 > $@",
) for (lang,dep) in [
    ("java", "//test/java/info/adams/ryu/benchmark"),
  ]
]

# Generate stats using doubles grouped by number of digits
[genrule(
  name = lang + "-double-shortest-bydigits-time-pdf",
  srcs = [lang + "-double-shortest-bydigits-summary.csv"],
  tools = ["shortest-time.template"],
  outs = [lang + "-double-shortest-bydigits-time.pdf"],
  cmd = CONVERSION_CMD_RYU_SHORTEST % ("shortest-time", lang, s1, s2, s3, s4),
) for (lang,s1,s2,s3,s4) in [("java","jdk","Jaffer","Ryū shortest","Doubleback dfmt")]
]

[genrule(
  name = lang + "-double-shortest-bydigits-time-png",
  srcs = [lang + "-double-shortest-bydigits-summary.csv"],
  tools = ["shortest-time-png.template"],
  outs = [lang + "-double-shortest-bydigits-time.png"],
  cmd = CONVERSION_CMD_RYU_SHORTEST % ("shortest-time-png", lang, s1, s2, s3, s4),
) for (lang,s1,s2,s3,s4) in [("java","jdk","Jaffer","Ryū shortest","Doubleback dfmt")]
]

[genrule(
  name = lang + "-double-shortest-bydigits-length-pdf",
  srcs = [lang + "-double-shortest-bydigits-summary.csv"],
  tools = ["shortest-length.template"],
  outs = [lang + "-double-shortest-bydigits-length.pdf"],
  cmd = CONVERSION_CMD_RYU_SHORTEST % ("shortest-length", lang, s1, s2, s3, s4),
) for (lang,s1,s2,s3,s4) in [("java","jdk","Jaffer","Ryū shortest","Doubleback dfmt")]
]

[genrule(
  name = lang + "-double-shortest-bydigits-length-png",
  srcs = [lang + "-double-shortest-bydigits-summary.csv"],
  tools = ["shortest-length-png.template"],
  outs = [lang + "-double-shortest-bydigits-length.png"],
  cmd = CONVERSION_CMD_RYU_SHORTEST % ("shortest-length-png", lang, s1, s2, s3, s4),
) for (lang,s1,s2,s3,s4) in [("java","jdk","Jaffer","Ryū shortest","Doubleback dfmt")]
]

[genrule(
  name = lang + "-double-shortest-bydigits-parse-pdf",
  srcs = [lang + "-double-shortest-bydigits-summary.csv"],
  tools = ["shortest-parse.template"],
  outs = [lang + "-double-shortest-bydigits-parse.pdf"],
  cmd = CONVERSION_CMD_RYU_SHORTEST % ("shortest-parse", lang, s1, s2, s3, s4),
) for (lang,s1,s2,s3,s4) in [("java","jdk","dparse","","")]
]

[genrule(
  name = lang + "-double-shortest-bydigits-parse-png",
  srcs = [lang + "-double-shortest-bydigits-summary.csv"],
  tools = ["shortest-parse-png.template"],
  outs = [lang + "-double-shortest-bydigits-parse.png"],
  cmd = CONVERSION_CMD_RYU_SHORTEST % ("shortest-parse-png", lang, s1, s2, s3, s4),
) for (lang,s1,s2,s3,s4) in [("java","jdk","dparse","","")]
]
