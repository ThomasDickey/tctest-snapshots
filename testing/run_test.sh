#!/bin/sh
# $Id: run_test.sh,v 1.19 2011/08/09 10:49:01 tom Exp $
# vi:ts=4 sw=4
# test-script for tctest

PROG="${TCTEST:-../tctest}"

PATH=/bin:/usr/bin:$PATH
export PATH

unset LINES
unset COLUMNS
unset TERMCAP

HERE=`pwd`
TYPE=none
OPTS=
while test $# != 0
do
	case $1 in
	-c)
		TYPE=cap
		OPTS=-e
		;;
	-t)
		TYPE=tic
		;;
	*)
		;;
	esac
	shift 1
done

for name in *.tc
do
	# Help persuade the termcap library to look only at our file.
	TERMINFO=$HERE/$name
	export TERMINFO

	TERMPATH=$TERMINFO
	export TERMINFO

	TERMINFO_DIRS=$TERMINFO
	export TERMINFO_DIRS

	root=`basename $name .tc`
	rm -rf $root.all $root.err $root.std $root
	trap "rm -rf $root.err $root.std *.db $root" 0 1 2 5 15

	echo "** $name"

	case $TYPE in
	cap)
		ln -s $name $root
		time sh -c "cap_mkdb -v $root 2>/dev/null"
		TERMCAP=$HERE/$root.db
		export TERMCAP
		TERMPATH=$TERMCAP
		export TERMPATH
		;;
	tic)
		mkdir $root
		TERMINFO=$HERE/$root
		export TERMINFO
		TERMINFO_DIR=$TERMINFO
		export TERMINFO_DIRS
		time sh -c "tic -NUTx $name 2>/dev/null"
		;;
	esac

	echo
	echo "...standard"
	time sh -c "$PROG -f $name -a -o $root.std -s $OPTS 2>$root.err"
	echo "** `egrep -v '^[#	]' $root.std |wc -l` entries, `egrep '^	' $root.std |wc -l` capabilities, `cat $root.err | wc -l` library warnings"
	test -s $root.err && ls -l $root.err

	echo
	echo "...complete"
	time sh -c "$PROG -b -f $name -a -o $root.all $OPTS 2>$root.err"
	echo "** `egrep -v '^[#	]' $root.std |wc -l` entries, `egrep '^	' $root.std |wc -l` capabilities, `cat $root.err | wc -l` library warnings"
	test -s $root.err && ls -l $root.err

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
	rm -rf $root.err $root.std *.db $root
done
