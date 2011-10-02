# $Id: entry-size.gnu,v 1.1 2011/10/01 19:11:28 tom Exp $
clear
reset
set key off

# the xrange and tic are setup to show the 1023 mark clearly
binwidth=64
maxwidth=1088
set xrange[0:maxwidth]
set xtics maxwidth/16

set title "Number of entries versus size (BSD 4.3 termcap)"
set xlabel "Entry size"
set ylabel "Number of entries"

set terminal png enhanced size 800, 600
ft="png"
set output "entry-size.".ft

set style histogram clustered gap 1
set style fill solid border -1

set boxwidth binwidth
bin(x,width)=width*floor(x/width) + binwidth/2.0

plot 'by-size-bsd43.dat' using (bin($1,binwidth)):2 smooth freq with boxes
