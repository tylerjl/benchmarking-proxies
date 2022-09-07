reset
set terminal svg size 700,300 mouse enhanced background rgb "#282c34" fontscale 1.1
set xlabel "Time" tc rgb "white"
unset xtics
set ylabel "CPU (%)" tc rgb "white"
set y2label "Memory (MB)" tc rgb "white"
set ytics 0,50
set y2tics 0,32
set grid ytics lw 0.5
set style fill solid border
set border lc rgb "white"
set key tc rgb "white" outside autotitle columnheader
set style data lines
set title sprintf("Resource Utilization - %s (%s clients)%s", test_type, par, append) enhanced font ",16" tc rgb "white"
plot caddy using 1:2 smooth csplines, \
     nginx using 1:2 smooth csplines, \
     caddy using 1:3 axes x1y2 smooth csplines, \
     nginx using 1:3 axes x1y2 smooth csplines