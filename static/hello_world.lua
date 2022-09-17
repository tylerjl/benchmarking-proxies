--lighty.r.resp_header["Content-Type"] = "text/plain" -- omit for benchmarking
lighty.r.resp_body.set("Hello, world!")
return 200
