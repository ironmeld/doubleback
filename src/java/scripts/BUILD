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
    ("java", "float", "-32", "//main/java/info/adams/ryu/benchmark"),
    ("java", "double", "-64", "//main/java/info/adams/ryu/benchmark"),
]]

[genrule(
  name = "shortest-" + t + "-" + f + "-pdf",
  srcs = ["shortest-" + t + "-" + f + ".csv"],
  tools = [f + ".template"],
  outs = ["shortest-" + t + "-" + f + ".pdf"],
  cmd = CONVERSION_CMD_RYU % (f, c, d),
) for (t,c,d) in [("java","Jdk","Jaffer")] for f in ["float","double"]]
