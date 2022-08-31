reset
set terminal svg size 900,500 mouse enhanced background rgb "#282c34" fontscale 1.1
set ylabel sprintf("%s (ms)", test_type) tc rgb "white"
set grid ytics lw 0.5
set style fill solid border
set border lc rgb "white"
set style data histograms
set style histogram clustered gap 1
set key tc rgb "white" outside below autotitle columnheader horizontal
set title sprintf("HTTP - %s (%s clients)", test_type, concurrency) enhanced font ",16" tc rgb "white"
set multiplot
set origin 0,0
set size 0.7,1
plot for [col=2:8] data using col:xtic(1)
unset xlabel
unset key
unset title
set ytics
set yrange [0:*]
set ylabel "count"
set origin 0.7,0
set size 0.3,0.5
plot for [col=2:5] requests using col:xtic(1) axes x1y1 notitle
set ylabel "%" tc rgb "white"
set ytics
set yrange [0:100]
set origin 0.7,0.5
set size 0.3,0.5
plot for [col=2:5] errors using col:xtic(1) axes x1y1 notitle