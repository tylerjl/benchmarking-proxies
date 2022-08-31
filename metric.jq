((.metrics[$var].values
| [
    ["min", .min],
    ["med", .med],
    ["avg", .avg],
    ["p90", .["p(90)"]],
    ["p95", .["p(95)"]],
    ["max", .max]
]) + [["requests", .metrics.http_reqs.values.count]])[]
  | @tsv
