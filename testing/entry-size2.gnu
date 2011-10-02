# $Id: entry-size2.gnu,v 1.1 2011/10/01 19:13:43 tom Exp $
clear
reset
set key off

# the xrange and tic are setup to show the 1023 mark clearly
binwidth=64
#maxwidth=1088
#maxwidth=1600
maxwidth=1920
#set yrange[0:150]
set xrange[0:maxwidth]
set xtics maxwidth/16

set title "Number of entries versus size (BSD 4.3 / termcap 1.3.1)"
set xlabel "Entry size"
set ylabel "Number of entries"

set terminal png enhanced size 800, 600
ft="png"
set output "entry-size2.".ft

set style histogram clustered gap 1
set style fill solid 0.5 border -1

set boxwidth binwidth
bin(x,width)=width*floor(x/width) + binwidth/2.0

set multiplot
plot 'by-size-bsd43.dat' using (bin($1,binwidth)):2 smooth freq with boxes
#plot 'by-size-ncurses.dat' using (bin($1,binwidth)):2 smooth freq
plot 'by-size-termcap131.dat' using (bin($1,binwidth)):2 smooth freq
#plot 'by-size-bsd42.dat' using (bin($1,binwidth)):2 smooth freq
#plot 'by-size-bsd44.dat' using (bin($1,binwidth)):2 smooth freq
#plot 'by-size-freebsd.dat' using (bin($1,binwidth)):2 smooth freq
unset multiplot
