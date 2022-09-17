reset
set terminal svg size 1000,1000 mouse enhanced background rgb "#11191f" fontscale 1.1 jsdir "/js/"
set xlabel "Time" tc rgb "white"
unset xtics
set ylabel "CPU (%)" tc rgb "white"
set y2label "Memory (MB)" tc rgb "white"
set ytics 0,50
set y2tics 0,32
set grid ytics lw 0.5
set style fill solid border
set border lc rgb "white"
set key tc rgb "white" outside below autotitle columnheader
set style data lines
set title sprintf("Resource Utilization - Caddy - %s clients", par) enhanced font ",16" tc rgb "white"
set multiplot
set origin 0,0
set size 0.5,0.5
plot caddy_default_html_large_baseline using 1:2 smooth csplines, \
     caddy_default_html_large_baseline using 1:3 axes x1y2 smooth csplines, \
     caddy_default_html_small_baseline using 1:2 smooth csplines, \
     caddy_default_html_small_baseline using 1:3 axes x1y2 smooth csplines, \
     caddy_default_proxy_baseline using 1:2 smooth csplines, \
     caddy_default_proxy_baseline using 1:3 axes x1y2 smooth csplines, \
     caddy_default_synthetic_baseline using 1:2 smooth csplines, \
     caddy_default_synthetic_baseline using 1:3 axes x1y2 smooth csplines

set title sprintf("Resource Utilization - Nginx - Default - %s clients", par) enhanced font ",16" tc rgb "white"
set origin 0,0.5
set size 0.5,0.5
plot nginx_default_html_large_baseline using 1:2 smooth csplines, \
     nginx_default_html_large_baseline using 1:3 axes x1y2 smooth csplines, \
     nginx_default_html_small_baseline using 1:2 smooth csplines, \
     nginx_default_html_small_baseline using 1:3 axes x1y2 smooth csplines, \
     nginx_default_proxy_baseline using 1:2 smooth csplines, \
     nginx_default_proxy_baseline using 1:3 axes x1y2 smooth csplines, \
     nginx_default_synthetic_baseline using 1:2 smooth csplines, \
     nginx_default_synthetic_baseline using 1:3 axes x1y2 smooth csplines

set title sprintf("Resource Utilization - Nginx - Optimized - %s clients", par) enhanced font ",16" tc rgb "white"
set origin 0.5,0.5
set size 0.5,0.5
plot nginx_optimized_html_large_baseline using 1:2 smooth csplines, \
     nginx_optimized_html_large_baseline using 1:3 axes x1y2 smooth csplines, \
     nginx_optimized_html_small_baseline using 1:2 smooth csplines, \
     nginx_optimized_html_small_baseline using 1:3 axes x1y2 smooth csplines, \
     nginx_optimized_proxy_baseline using 1:2 smooth csplines, \
     nginx_optimized_proxy_baseline using 1:3 axes x1y2 smooth csplines, \
     nginx_optimized_synthetic_baseline using 1:2 smooth csplines, \
     nginx_optimized_synthetic_baseline using 1:3 axes x1y2 smooth csplines

set title sprintf("Resource Utilization - lighttpd - Default - %s clients", par) enhanced font ",16" tc rgb "white"
set origin 0,0.5
set size 0.5,0.5
plot lighttpd_default_html_large_baseline using 1:2 smooth csplines, \
     lighttpd_default_html_large_baseline using 1:3 axes x1y2 smooth csplines, \
     lighttpd_default_html_small_baseline using 1:2 smooth csplines, \
     lighttpd_default_html_small_baseline using 1:3 axes x1y2 smooth csplines, \
     lighttpd_default_proxy_baseline using 1:2 smooth csplines, \
     lighttpd_default_proxy_baseline using 1:3 axes x1y2 smooth csplines, \
     lighttpd_default_synthetic_baseline using 1:2 smooth csplines, \
     lighttpd_default_synthetic_baseline using 1:3 axes x1y2 smooth csplines

set title sprintf("Resource Utilization - lighttpd - Optimized - %s clients", par) enhanced font ",16" tc rgb "white"
set origin 0.5,0.5
set size 0.5,0.5
plot lighttpd_optimized_html_large_baseline using 1:2 smooth csplines, \
     lighttpd_optimized_html_large_baseline using 1:3 axes x1y2 smooth csplines, \
     lighttpd_optimized_html_small_baseline using 1:2 smooth csplines, \
     lighttpd_optimized_html_small_baseline using 1:3 axes x1y2 smooth csplines, \
     lighttpd_optimized_proxy_baseline using 1:2 smooth csplines, \
     lighttpd_optimized_proxy_baseline using 1:3 axes x1y2 smooth csplines, \
     lighttpd_optimized_synthetic_baseline using 1:2 smooth csplines, \
     lighttpd_optimized_synthetic_baseline using 1:3 axes x1y2 smooth csplines
