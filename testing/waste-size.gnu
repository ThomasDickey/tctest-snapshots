# $Id: waste-size.gnu,v 1.1 2011/10/01 19:08:58 tom Exp $
clear
reset
set key off

# the xrange and tic are setup to show the 1023 mark clearly
binwidth=64
maxwidth=1088
set xrange[0:maxwidth]
set xtics maxwidth/16

set title "Wasted space versus size (BSD 4.3 termcap file)"
set xlabel "Entry size"
set ylabel "Wasted space as percentage of size"

set terminal png enhanced size 800, 600
ft="png"
set output "waste-size.".ft

set style histogram clustered gap 1
set style fill solid border -1

set boxwidth binwidth
bin(x,width)=width*floor(x/width) + binwidth/2.0
pct(waste,entries,size)=(100 * waste)/(size * entries)

plot 'by-size-bsd43.dat' using (bin($1,binwidth)):(pct($3,$2,$1)) smooth unique with boxes
