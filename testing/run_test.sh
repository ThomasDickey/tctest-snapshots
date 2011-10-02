#!/bin/sh
# $Id: run_test.sh,v 1.25 2011/09/27 00:05:39 tom Exp $
# vi:ts=4 sw=4
# test-script for tctest

PROG="${TCTEST:-../tctest}"
TIME="time -p"

unset LINES
unset COLUMNS
unset TERMCAP

case x`(infocmp |egrep '^#') 2>/dev/null` in
*.db)
	HASH=yes
	;;
*)
	HASH=no
	;;
esac

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
		$TIME sh -c "cap_mkdb -v $root 2>/dev/null"
		name=$root
		TERMCAP=$HERE/$root
		export TERMCAP
		TERMPATH=$TERMCAP
		export TERMPATH
		;;
	tic)
		if test $HASH = no
		then
			mkdir $root
		fi

		TERMINFO=$HERE/$root
		export TERMINFO
		TERMINFO_DIR=$TERMINFO
		export TERMINFO_DIRS

		DATE=`tic -V 2>/dev/null |fgrep ncurses|sed -e 's/^.*\.//'`
		TICS=
		if test -n "$DATE"
		then
			TICS=-NUTx
			if expr "$DATE" \>= 20111001 >/dev/null
			then
				TICS="${TICS}K"
			fi
		else
			echo "? this is not ncurses tic"
		fi
		$TIME sh -c "tic $TICS $name 2>/dev/null"
		;;
	esac

	echo
	echo "...tgetent*10"
	$TIME sh -c "$PROG -f $name -n -r 10 -s 2>$root.err"

	echo
	echo "...standard"
	$TIME sh -c "$PROG -f $name -a -o $root.std -s $OPTS 2>$root.err"
	echo "** `egrep -v '^[#	]' $root.std |wc -l` entries, `egrep '^	' $root.std |wc -l` capabilities, `cat $root.err | wc -l` library warnings"

	echo
	echo "...complete"
	$TIME sh -c "$PROG -b -f $name -a -o $root.all $OPTS 2>$root.err"
	echo "** `egrep -v '^[#	]' $root.std |wc -l` entries, `egrep '^	' $root.std |wc -l` capabilities, `cat $root.err | wc -l` library warnings"

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
	if cmp -s $root.std $root.ref
	then
		:
	else
		diff -u $root.ref $root.std |diffstat
	fi
	rm -rf $root.err $root.std *.db $root
done
