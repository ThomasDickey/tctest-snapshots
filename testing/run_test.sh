#!/bin/sh
# $Id: run_test.sh,v 1.11 2011/07/28 08:35:19 tom Exp $
# test-script for tctest

PROG="${TCTEST:-../tctest}"

PATH=/bin:/usr/bin:$PATH
export PATH

unset LINES
unset COLUMNS
unset TERMCAP

for name in *.tc
do
	# Help persuade the termcap library to look only at our file.
	TERMINFO=`pwd`/$name
	export TERMINFO

	TERMPATH=$TERMINFO
	export TERMINFO

	TERMINFO_DIRS=$TERMINFO
	export TERMINFO_DIRS

	root=`basename $name .tc`
	rm -f $root.all $root.std
	echo "** $name"

	echo
	echo "...standard"
	time "$PROG" -f $name -a -o $root.std
	echo "** `egrep -v '^[#	]' $root.std |wc -l` entries, `egrep '^	' $root.std |wc -l` capabilities"

	echo
	echo "...complete"
	time "$PROG" -b -f $name -a -o $root.all
	echo "** `egrep -v '^[#	]' $root.all |wc -l` entries, `egrep '^	' $root.all |wc -l` capabilities"

	echo
	if test -f $root.ref
	then
		if cmp -s $root.ref $root.all
		then
			echo "...okay $name"
			rm -f $root.all
		else
			diff -u $root.ref $root.all |diffstat
		fi
	else
		cp $root.all $root.ref
		echo "...saved $root.ref"
	fi
	if ! cmp -s $root.std $root.ref
	then
		diff -u $root.ref $root.std |diffstat
	fi
	rm -f $root.std
done
