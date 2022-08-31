reset
set terminal svg size 700,300 mouse enhanced background rgb "#282c34" fontscale 1.1
set xlabel "Metric" tc rgb "white"
# set logscale y 2
set ylabel sprintf("%s (ms)", test_type) tc rgb "white"
set grid ytics lw 0.5
set style fill solid border
set border lc rgb "white"
set style data histograms
set style histogram clustered gap 1
set key tc rgb "white" outside autotitle columnheader
set title sprintf("HTTP - %s", test_type) enhanced font ",16" tc rgb "white"
plot for [col=2:5] data using col:xtic(1)