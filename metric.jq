(.metrics[$var].values
| [
  .min,
   .med,
   .avg,
   .["p(90)"],
   .["p(95)"],
   .max
]) + [
  .metrics.http_reqs.values.count,
  (.metrics.http_req_failed.values.rate * 100)
] | join(" ")
