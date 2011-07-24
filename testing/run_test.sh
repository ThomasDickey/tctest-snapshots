#!/bin/sh
# $Id: run_test.sh,v 1.4 2011/07/23 20:05:27 tom Exp $
# test-script for tctest

PROG="${TCTEST:-../tctest}"

PATH=/bin:/usr/bin
export PATH

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
			diff -u $root.ref $root.tmp
		fi
	else
		mv $root.tmp $root.ref
		echo "...saved $root.ref"
	fi
done
