#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

test_duration=30
test_concurrency=${VUS:-200}
tests=(synthetic html proxy)
proxies=(caddy nginx)
suffix=${SUFFIX:-''}

function ssh_ { ssh -F ssh_config $@; }
function scp_ { scp -F ssh_config $@; }
function config {
    NIX_SSHOPTS="-F ssh_config" \
               nixos-rebuild \
               --flake ".#$1" \
               --target-host root@$2 \
               --build-host localhost \
               test
}

function run_tests {
    terraform apply -auto-approve
    dns=$(terraform output -json dns)
    sut_pri=$(echo $dns | jq -r '.[0][0]')
    dri_pri=$(echo $dns | jq -r '.[0][1]')
    sut_pub=$(echo $dns | jq -r '.[1][0]')
    dri_pub=$(echo $dns | jq -r '.[1][1]')

    echo -n "Waiting for ssh..."
    for h in $dri_pub $sut_pub
    do
        until ssh_ $h id &>/dev/null ; do
            printf .
            sleep 1
        done
    done

    config aws-bench $sut_pub
    config aws-driver $dri_pub
    ssh_ $sut_pub systemctl stop nginx caddy || true

    scp_ test.js $dri_pub:~/

    for svc in ${proxies[@]}
    do
        for test_uri in ${tests[@]}
        do
            ssh_ $sut_pub systemctl start $svc
            sleep 3
            pid=$(ssh_ $sut_pub systemctl show $svc --property=MainPID --value)
            ssh_ $sut_pub "psrecord $pid \
                --include-children \
                --interval 0.1 \
                --duration $(( $test_duration + 15 )) \
                --log $svc-$test_uri-$test_concurrency$suffix.txt" &
            record=$!
            ssh_ $dri_pub \
                 "TEST_TARGET=http://${sut_pri}:8080/${test_uri} \
                k6 run \
                --vus $test_concurrency \
                --duration ${test_duration}s \
                test.js"
            ssh_ $sut_pub systemctl stop $svc
            scp_ $dri_pub:~/summary.json results/${svc}-${test_uri}-${test_concurrency}$suffix.json
            wait $record
            scp_ $sut_pub:~/${svc}-${test_uri}-${test_concurrency}${suffix}.txt results/
        done
    done

    terraform apply -destroy -auto-approve
}

function postprocess_resources {
    cleanup=()
    for test_type in ${tests[@]}
    do
        for svc in ${proxies[@]}
        do
            raw=results/${svc}-${test_type}-${test_concurrency}${suffix}.txt
            ready=results/${svc}-${test_type}-${test_concurrency}${suffix}-formatted.txt
            cleanup+=($ready)

            sed 1d $raw \
                | choose 0:2 \
                | sed '1i Time "'$svc' CPU %" "'$svc' Memory"' \
                      > $ready
        done

        gnuplot \
            -e "test_type='${test_type}'" \
            -e "par='${test_concurrency}'" \
            -e "caddy='results/caddy-$test_type-$test_concurrency$suffix-formatted.txt'" \
            -e "nginx='results/nginx-$test_type-$test_concurrency$suffix-formatted.txt'" \
            resources.gp \
            > results/resources-${test_type}-${test_concurrency}c${suffix}.svg
    done
    rm ${cleanup[@]}
}

function postprocess_metrics {
    echo "test min median average p90 p95 max requests errors" > results/plot.txt
    for test_type in ${tests[@]}
    do
        for svc in ${proxies[@]}
        do
            raw=results/${svc}-${test_type}-${test_concurrency}${suffix}.json
            jq --arg var http_req_duration -r -f metric.jq $raw \
                | xargs echo "${svc}-${test_type}" \
                        >> results/plot.txt
        done
    done

    rs -Tc' ' < results/plot.txt | sponge results/plot.txt
    cp results/{plot.txt,table-${test_concurrency}${suffix}.txt}
    sed -n '1p;/requests/p' results/plot.txt > results/requests.txt
    sed -n '1p;/error/p' results/plot.txt > results/errors.txt
    sed -i '/requests/d;/error/d;/max/d;/min/d' results/plot.txt
    gnuplot \
            -e "data='results/plot.txt'" \
            -e "requests='results/requests.txt'" \
            -e "errors='results/errors.txt'" \
            -e "concurrency='$test_concurrency'" \
            -e "test_type='duration'" \
            metrics.gp > results/metrics-duration-${test_concurrency}c${suffix}.svg
    rm results/{errors,plot,requests}.txt
}

function postprocess_tests {
    postprocess_resources
    postprocess_metrics
}

run_tests
postprocess_tests
