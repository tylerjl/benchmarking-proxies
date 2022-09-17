{
  html: {
    caddy: {
      requests: .[0].metrics.http_reqs.values.count,
      duration: .[0].metrics.http_req_duration.values,
      fail_rate: .[0].metrics.http_req_failed.values.rate,
      ttfb: .[0].metrics.http_req_waiting.values
    },
    nginx: {
      requests: .[2].metrics.http_reqs.values.count,
      duration: .[2].metrics.http_req_duration.values,
      fail_rate: .[2].metrics.http_req_failed.values.rate,
      ttfb: .[2].metrics.http_req_waiting.values
    },
    lighttpd: {
      requests: .[2].metrics.http_reqs.values.count,
      duration: .[2].metrics.http_req_duration.values,
      fail_rate: .[2].metrics.http_req_failed.values.rate,
      ttfb: .[2].metrics.http_req_waiting.values
    }
  },
  synthetic: {
    caddy: {
      requests: .[1].metrics.http_reqs.values.count,
      duration: .[1].metrics.http_req_duration.values,
      fail_rate: .[1].metrics.http_req_failed.values.rate,
      ttfb: .[1].metrics.http_req_waiting.values
    },
    nginx: {
      requests: .[3].metrics.http_reqs.values.count,
      duration: .[3].metrics.http_req_duration.values,
      fail_rate: .[3].metrics.http_req_failed.values.rate,
      ttfb: .[3].metrics.http_req_waiting.values
    },
    lighttpd: {
      requests: .[3].metrics.http_reqs.values.count,
      duration: .[3].metrics.http_req_duration.values,
      fail_rate: .[3].metrics.http_req_failed.values.rate,
      ttfb: .[3].metrics.http_req_waiting.values
    }
  }
}
