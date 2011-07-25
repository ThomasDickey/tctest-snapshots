#!/bin/sh
# $Id: run_test.sh,v 1.7 2011/07/24 20:31:24 tom Exp $
# test-script for tctest

PROG="${TCTEST:-../tctest}"

PATH=/bin:/usr/bin:$PATH
export PATH

unset LINES
unset COLUMNS

TERMINFO=`pwd`; export TERMINFO
TERMPATH=`pwd`; export TERMPATH
TERMINFO_DIRS=`pwd`; export TERMINFO_DIRS

for name in *.tc
do
	root=`basename $name .tc`
	echo "** $name"
	"$PROG" -f $name -a >$root.tmp
	if test -f $root.ref
	then
		if cmp -s $root.ref $root.tmp
		then
			echo "...okay $name"
			rm -f $root.tmp
		else
			diff $root.ref $root.tmp |diffstat
		fi
	else
		mv $root.tmp $root.ref
		echo "...saved $root.ref"
	fi
done
