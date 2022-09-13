#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

test_duration=30
test_concurrency=${VUS:-200}

declare -A proxies
proxies[caddy]=Caddyfile
proxies[nginx]=nginx.conf

declare -A tests
tests[synthetic]=''
tests[proxy]=''
tests[html_small]='/index.html'
tests[html_large]='/jquery-3.6.1.js'

levels=(default optimized)

function ssh_ { ssh -F ssh_config $@; }
function scp_ { scp -F ssh_config $@; }
function config {
    NIX_SSHOPTS="-F ssh_config" \
               nixos-rebuild \
               --flake ".#$1" \
               --target-host root@$2 \
               --build-host root@$2 \
               test
}

function run_tests {
    #
    # Build machines
    #
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

    #
    # Configure driver
    #
    config aws-driver $dri_pub
    scp_ test.js $dri_pub:~/

    for svc in ${!proxies[@]}
    do
        for opt in ${levels[@]}
        do
            if [[ ${svc} == "caddy" && ${opt} == "optimized" ]]
            then
                continue
            fi
            for test_ in ${!tests[@]}
            do
                cp -f conf/$svc/$opt/$test_ ${proxies[$svc]}
                config aws-bench $sut_pub

                ssh_ $sut_pub systemctl start $svc
                sleep 3
                pid=$(ssh_ $sut_pub systemctl show $svc --property=MainPID --value)
                ssh_ $sut_pub "psrecord $pid \
                    --include-children \
                    --interval 0.1 \
                    --duration $(( $test_duration + 15 )) \
                    --log $svc-$opt-$test_-$test_concurrency.txt" &
                record=$!
                ssh_ $dri_pub \
                    "TEST_TARGET=http://${sut_pri}:8080${tests[$test_]} \
                    k6 run \
                    --vus $test_concurrency \
                    --duration ${test_duration}s \
                    test.js"
                ssh_ $sut_pub systemctl stop $svc
                scp_ $dri_pub:~/summary.json results/${svc}-${opt}-${test_}-${test_concurrency}.json
                wait $record
                scp_ $sut_pub:~/${svc}-${opt}-${test_}-${test_concurrency}.txt results/
            done
        done
    done

    terraform apply -destroy -auto-approve
}

function postprocess_resources {
    results=()
    for test_ in ${!tests[@]}
    do
        for opt in ${levels[@]}
        do
            for svc in ${!proxies[@]}
            do
                if [[ ${svc} == "caddy" && ${opt} == "optimized" ]]
                then
                    continue
                fi
                raw=results/${svc}-${opt}-${test_}-${test_concurrency}.txt

                sed 1d $raw \
                    | choose 0:2 \
                    | sed '1i Time "'$svc' '${test_/_/ }' '${opt}' CPU %" "'$svc' '${test_/_/ }' '${opt}' Memory"' \
                    | sponge $raw
                results+=(-e "${svc}_${opt}_${test_}='${raw}'")
            done
        done
    done

    gnuplot -e "par='${test_concurrency}'" ${results[@]} resources.gp \
        > results/resources-${test_concurrency}c.svg
}

function postprocess_metrics {
    echo "test min median average p90 p95 max requests errors" > results/plot.txt
    for test_ in ${!tests[@]}
    do
        for opt in ${levels[@]}
        do
            for svc in ${!proxies[@]}
            do
                if [[ ${svc} == "caddy" && ${opt} == "optimized" ]]
                then
                    continue
                fi
                raw=results/${svc}-${opt}-${test_}-${test_concurrency}.json
                jq --arg var http_req_duration -r -f metric.jq $raw \
                    | xargs echo "${svc}-${opt}-${test_/_/-}" \
                            >> results/plot.txt
            done
        done
    done

    rs -Tc' ' < results/plot.txt | sponge results/plot.txt
    cp results/{plot.txt,table-${test_concurrency}}
    sed -n '1p;/requests/p' results/plot.txt > results/requests.txt
    sed -n '1p;/error/p' results/plot.txt > results/errors.txt
    sed -i '/requests/d;/error/d;/max/d;/min/d' results/plot.txt
    gnuplot \
            -e "data='results/plot.txt'" \
            -e "requests='results/requests.txt'" \
            -e "errors='results/errors.txt'" \
            -e "concurrency='$test_concurrency'" \
            -e "test_type='duration'" \
            metrics.gp > results/metrics-duration-${test_concurrency}c.svg
    rm results/{errors,plot,requests}.txt
}

function postprocess_tests {
    postprocess_resources
    postprocess_metrics
}

run_tests
postprocess_tests
