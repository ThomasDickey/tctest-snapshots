dnl $Id: aclocal.m4,v 1.15 2025/01/11 00:55:54 tom Exp $
dnl
dnl ---------------------------------------------------------------------------
dnl
dnl Copyright 2011-2024,2025 by Thomas E. Dickey
dnl
dnl                         All Rights Reserved
dnl
dnl Permission is hereby granted, free of charge, to any person obtaining a
dnl copy of this software and associated documentation files (the
dnl "Software"), to deal in the Software without restriction, including
dnl without limitation the rights to use, copy, modify, merge, publish,
dnl distribute, sublicense, and/or sell copies of the Software, and to
dnl permit persons to whom the Software is furnished to do so, subject to
dnl the following conditions:
dnl
dnl The above copyright notice and this permission notice shall be included
dnl in all copies or substantial portions of the Software.
dnl
dnl THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
dnl OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
dnl MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
dnl IN NO EVENT SHALL THE ABOVE LISTED COPYRIGHT HOLDER(S) BE LIABLE FOR ANY
dnl CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
dnl TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
dnl SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
dnl
dnl Except as contained in this notice, the name(s) of the above copyright
dnl holders shall not be used in advertising or otherwise to promote the
dnl sale, use or other dealings in this Software without prior written
dnl authorization.
dnl
dnl ---------------------------------------------------------------------------
dnl See
dnl		https://invisible-island.net/autoconf/autoconf.html
dnl     https://invisible-island.net/autoconf/my-autoconf.html
dnl ---------------------------------------------------------------------------
dnl ---------------------------------------------------------------------------
dnl CF_ACVERSION_CHECK version: 5 updated: 2014/06/04 19:11:49
dnl ------------------
dnl Conditionally generate script according to whether we're using a given autoconf.
dnl
dnl $1 = version to compare against
dnl $2 = code to use if AC_ACVERSION is at least as high as $1.
dnl $3 = code to use if AC_ACVERSION is older than $1.
define([CF_ACVERSION_CHECK],
[
ifdef([AC_ACVERSION], ,[ifdef([AC_AUTOCONF_VERSION],[m4_copy([AC_AUTOCONF_VERSION],[AC_ACVERSION])],[m4_copy([m4_PACKAGE_VERSION],[AC_ACVERSION])])])dnl
ifdef([m4_version_compare],
[m4_if(m4_version_compare(m4_defn([AC_ACVERSION]), [$1]), -1, [$3], [$2])],
[CF_ACVERSION_COMPARE(
AC_PREREQ_CANON(AC_PREREQ_SPLIT([$1])),
AC_PREREQ_CANON(AC_PREREQ_SPLIT(AC_ACVERSION)), AC_ACVERSION, [$2], [$3])])])dnl
dnl ---------------------------------------------------------------------------
dnl CF_ACVERSION_COMPARE version: 3 updated: 2012/10/03 18:39:53
dnl --------------------
dnl CF_ACVERSION_COMPARE(MAJOR1, MINOR1, TERNARY1,
dnl                      MAJOR2, MINOR2, TERNARY2,
dnl                      PRINTABLE2, not FOUND, FOUND)
define([CF_ACVERSION_COMPARE],
[ifelse(builtin([eval], [$2 < $5]), 1,
[ifelse([$8], , ,[$8])],
[ifelse([$9], , ,[$9])])])dnl
dnl ---------------------------------------------------------------------------
dnl CF_ADD_CFLAGS version: 15 updated: 2020/12/31 10:54:15
dnl -------------
dnl Copy non-preprocessor flags to $CFLAGS, preprocessor flags to $CPPFLAGS
dnl $1 = flags to add
dnl $2 = if given makes this macro verbose.
dnl
dnl Put any preprocessor definitions that use quoted strings in $EXTRA_CPPFLAGS,
dnl to simplify use of $CPPFLAGS in compiler checks, etc., that are easily
dnl confused by the quotes (which require backslashes to keep them usable).
AC_DEFUN([CF_ADD_CFLAGS],
[
cf_fix_cppflags=no
cf_new_cflags=
cf_new_cppflags=
cf_new_extra_cppflags=

for cf_add_cflags in $1
do
case "$cf_fix_cppflags" in
(no)
	case "$cf_add_cflags" in
	(-undef|-nostdinc*|-I*|-D*|-U*|-E|-P|-C)
		case "$cf_add_cflags" in
		(-D*)
			cf_tst_cflags=`echo "${cf_add_cflags}" |sed -e 's/^-D[[^=]]*='\''\"[[^"]]*//'`

			test "x${cf_add_cflags}" != "x${cf_tst_cflags}" \
				&& test -z "${cf_tst_cflags}" \
				&& cf_fix_cppflags=yes

			if test "$cf_fix_cppflags" = yes ; then
				CF_APPEND_TEXT(cf_new_extra_cppflags,$cf_add_cflags)
				continue
			elif test "${cf_tst_cflags}" = "\"'" ; then
				CF_APPEND_TEXT(cf_new_extra_cppflags,$cf_add_cflags)
				continue
			fi
			;;
		esac
		case "$CPPFLAGS" in
		(*$cf_add_cflags)
			;;
		(*)
			case "$cf_add_cflags" in
			(-D*)
				cf_tst_cppflags=`echo "x$cf_add_cflags" | sed -e 's/^...//' -e 's/=.*//'`
				CF_REMOVE_DEFINE(CPPFLAGS,$CPPFLAGS,$cf_tst_cppflags)
				;;
			esac
			CF_APPEND_TEXT(cf_new_cppflags,$cf_add_cflags)
			;;
		esac
		;;
	(*)
		CF_APPEND_TEXT(cf_new_cflags,$cf_add_cflags)
		;;
	esac
	;;
(yes)
	CF_APPEND_TEXT(cf_new_extra_cppflags,$cf_add_cflags)

	cf_tst_cflags=`echo "${cf_add_cflags}" |sed -e 's/^[[^"]]*"'\''//'`

	test "x${cf_add_cflags}" != "x${cf_tst_cflags}" \
		&& test -z "${cf_tst_cflags}" \
		&& cf_fix_cppflags=no
	;;
esac
done

if test -n "$cf_new_cflags" ; then
	ifelse([$2],,,[CF_VERBOSE(add to \$CFLAGS $cf_new_cflags)])
	CF_APPEND_TEXT(CFLAGS,$cf_new_cflags)
fi

if test -n "$cf_new_cppflags" ; then
	ifelse([$2],,,[CF_VERBOSE(add to \$CPPFLAGS $cf_new_cppflags)])
	CF_APPEND_TEXT(CPPFLAGS,$cf_new_cppflags)
fi

if test -n "$cf_new_extra_cppflags" ; then
	ifelse([$2],,,[CF_VERBOSE(add to \$EXTRA_CPPFLAGS $cf_new_extra_cppflags)])
	CF_APPEND_TEXT(EXTRA_CPPFLAGS,$cf_new_extra_cppflags)
fi

AC_SUBST(EXTRA_CPPFLAGS)

])dnl
dnl ---------------------------------------------------------------------------
dnl CF_ADD_INCDIR version: 17 updated: 2021/09/04 06:35:04
dnl -------------
dnl Add an include-directory to $CPPFLAGS.  Don't add /usr/include, since it is
dnl redundant.  We don't normally need to add -I/usr/local/include for gcc,
dnl but old versions (and some misinstalled ones) need that.  To make things
dnl worse, gcc 3.x may give error messages if -I/usr/local/include is added to
dnl the include-path).
AC_DEFUN([CF_ADD_INCDIR],
[
if test -n "$1" ; then
  for cf_add_incdir in $1
  do
	while test "$cf_add_incdir" != /usr/include
	do
	  if test -d "$cf_add_incdir"
	  then
		cf_have_incdir=no
		if test -n "$CFLAGS$CPPFLAGS" ; then
		  # a loop is needed to ensure we can add subdirs of existing dirs
		  for cf_test_incdir in $CFLAGS $CPPFLAGS ; do
			if test ".$cf_test_incdir" = ".-I$cf_add_incdir" ; then
			  cf_have_incdir=yes; break
			fi
		  done
		fi

		if test "$cf_have_incdir" = no ; then
		  if test "$cf_add_incdir" = /usr/local/include ; then
			if test "$GCC" = yes
			then
			  cf_save_CPPFLAGS=$CPPFLAGS
			  CF_APPEND_TEXT(CPPFLAGS,-I$cf_add_incdir)
			  AC_TRY_COMPILE([#include <stdio.h>],
				  [printf("Hello")],
				  [],
				  [cf_have_incdir=yes])
			  CPPFLAGS=$cf_save_CPPFLAGS
			fi
		  fi
		fi

		if test "$cf_have_incdir" = no ; then
		  CF_VERBOSE(adding $cf_add_incdir to include-path)
		  ifelse([$2],,CPPFLAGS,[$2])="$ifelse([$2],,CPPFLAGS,[$2]) -I$cf_add_incdir"

		  cf_top_incdir=`echo "$cf_add_incdir" | sed -e 's%/include/.*$%/include%'`
		  test "$cf_top_incdir" = "$cf_add_incdir" && break
		  cf_add_incdir="$cf_top_incdir"
		else
		  break
		fi
	  else
		break
	  fi
	done
  done
fi
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_ADD_LIB version: 2 updated: 2010/06/02 05:03:05
dnl ----------
dnl Add a library, used to enforce consistency.
dnl
dnl $1 = library to add, without the "-l"
dnl $2 = variable to update (default $LIBS)
AC_DEFUN([CF_ADD_LIB],[CF_ADD_LIBS(-l$1,ifelse($2,,LIBS,[$2]))])dnl
dnl ---------------------------------------------------------------------------
dnl CF_ADD_LIBDIR version: 11 updated: 2020/12/31 20:19:42
dnl -------------
dnl	Adds to the library-path
dnl
dnl	Some machines have trouble with multiple -L options.
dnl
dnl $1 is the (list of) directory(s) to add
dnl $2 is the optional name of the variable to update (default LDFLAGS)
dnl
AC_DEFUN([CF_ADD_LIBDIR],
[
if test -n "$1" ; then
	for cf_add_libdir in $1
	do
		if test "$cf_add_libdir" = /usr/lib ; then
			:
		elif test -d "$cf_add_libdir"
		then
			cf_have_libdir=no
			if test -n "$LDFLAGS$LIBS" ; then
				# a loop is needed to ensure we can add subdirs of existing dirs
				for cf_test_libdir in $LDFLAGS $LIBS ; do
					if test ".$cf_test_libdir" = ".-L$cf_add_libdir" ; then
						cf_have_libdir=yes; break
					fi
				done
			fi
			if test "$cf_have_libdir" = no ; then
				CF_VERBOSE(adding $cf_add_libdir to library-path)
				ifelse([$2],,LDFLAGS,[$2])="-L$cf_add_libdir $ifelse([$2],,LDFLAGS,[$2])"
			fi
		fi
	done
fi
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_ADD_LIBS version: 3 updated: 2019/11/02 16:47:33
dnl -----------
dnl Add one or more libraries, used to enforce consistency.  Libraries are
dnl prepended to an existing list, since their dependencies are assumed to
dnl already exist in the list.
dnl
dnl $1 = libraries to add, with the "-l", etc.
dnl $2 = variable to update (default $LIBS)
AC_DEFUN([CF_ADD_LIBS],[
cf_add_libs="[$]ifelse($2,,LIBS,[$2])"
# reverse order
cf_add_0lib=
for cf_add_1lib in $1; do cf_add_0lib="$cf_add_1lib $cf_add_0lib"; done
# filter duplicates
for cf_add_1lib in $cf_add_0lib; do
	for cf_add_2lib in $cf_add_libs; do
		if test "x$cf_add_1lib" = "x$cf_add_2lib"; then
			cf_add_1lib=
			break
		fi
	done
	test -n "$cf_add_1lib" && cf_add_libs="$cf_add_1lib $cf_add_libs"
done
ifelse($2,,LIBS,[$2])="$cf_add_libs"
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_ADD_SUBDIR_PATH version: 5 updated: 2020/12/31 20:19:42
dnl ------------------
dnl Append to a search-list for a nonstandard header/lib-file
dnl	$1 = the variable to return as result
dnl	$2 = the package name
dnl	$3 = the subdirectory, e.g., bin, include or lib
dnl $4 = the directory under which we will test for subdirectories
dnl $5 = a directory that we do not want $4 to match
AC_DEFUN([CF_ADD_SUBDIR_PATH],
[
test "x$4" != "x$5" && \
test -d "$4" && \
ifelse([$5],NONE,,[{ test -z "$5" || test "x$5" = xNONE || test "x$4" != "x$5"; } &&]) {
	test -n "$verbose" && echo "	... testing for $3-directories under $4"
	test -d "$4/$3" &&          $1="[$]$1 $4/$3"
	test -d "$4/$3/$2" &&       $1="[$]$1 $4/$3/$2"
	test -d "$4/$3/$2/$3" &&    $1="[$]$1 $4/$3/$2/$3"
	test -d "$4/$2/$3" &&       $1="[$]$1 $4/$2/$3"
	test -d "$4/$2/$3/$2" &&    $1="[$]$1 $4/$2/$3/$2"
}
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_APPEND_CFLAGS version: 3 updated: 2021/09/05 17:25:40
dnl ----------------
dnl Use CF_ADD_CFLAGS after first checking for potential redefinitions.
dnl $1 = flags to add
dnl $2 = if given makes this macro verbose.
define([CF_APPEND_CFLAGS],
[
for cf_add_cflags in $1
do
	case "x$cf_add_cflags" in
	(x-[[DU]]*)
		CF_REMOVE_CFLAGS($cf_add_cflags,CFLAGS,[$2])
		CF_REMOVE_CFLAGS($cf_add_cflags,CPPFLAGS,[$2])
		;;
	esac
	CF_ADD_CFLAGS([$cf_add_cflags],[$2])
done
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_APPEND_TEXT version: 1 updated: 2017/02/25 18:58:55
dnl --------------
dnl use this macro for appending text without introducing an extra blank at
dnl the beginning
define([CF_APPEND_TEXT],
[
	test -n "[$]$1" && $1="[$]$1 "
	$1="[$]{$1}$2"
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_ARG_DISABLE version: 3 updated: 1999/03/30 17:24:31
dnl --------------
dnl Allow user to disable a normally-on option.
AC_DEFUN([CF_ARG_DISABLE],
[CF_ARG_OPTION($1,[$2],[$3],[$4],yes)])dnl
dnl ---------------------------------------------------------------------------
dnl CF_ARG_ENABLE version: 3 updated: 1999/03/30 17:24:31
dnl -------------
dnl Allow user to enable a normally-off option.
AC_DEFUN([CF_ARG_ENABLE],
[CF_ARG_OPTION($1,[$2],[$3],[$4],no)])dnl
dnl ---------------------------------------------------------------------------
dnl CF_ARG_OPTION version: 5 updated: 2015/05/10 19:52:14
dnl -------------
dnl Restricted form of AC_ARG_ENABLE that ensures user doesn't give bogus
dnl values.
dnl
dnl Parameters:
dnl $1 = option name
dnl $2 = help-string
dnl $3 = action to perform if option is not default
dnl $4 = action if perform if option is default
dnl $5 = default option value (either 'yes' or 'no')
AC_DEFUN([CF_ARG_OPTION],
[AC_ARG_ENABLE([$1],[$2],[test "$enableval" != ifelse([$5],no,yes,no) && enableval=ifelse([$5],no,no,yes)
	if test "$enableval" != "$5" ; then
ifelse([$3],,[    :]dnl
,[    $3]) ifelse([$4],,,[
	else
		$4])
	fi],[enableval=$5 ifelse([$4],,,[
	$4
])dnl
])])dnl
dnl ---------------------------------------------------------------------------
dnl CF_BROKEN_TGETENT_STATUS version: 2 updated: 2023/01/05 18:00:52
dnl ------------------------
dnl Some implementors read the (incorrect) X/Open documentation when providing
dnl tgetent as part of the terminfo library.
dnl tgetent should return
dnl		>0 for success,
dnl		0  for unknown entry
dnl		<0 for no database
dnl X/Open implied that the success would be OK (0) and failure ERR (-1).
dnl
dnl This test checks for an unknown entry rather than for success, since the
dnl latter is not guaranteed.
AC_DEFUN([CF_BROKEN_TGETENT_STATUS],
[
AC_CACHE_CHECK(for broken tgetent status returned, cf_cv_status_tgetent,[
AC_TRY_RUN([
extern int tgetent(char *, char *);
int main(void)
{
	char buffer[[1024]];
	static char name[[20]] = "..............";
	int code = tgetent(buffer, name);
	${cf_cv_main_return:-return} (code != 0);}],
	[cf_cv_status_tgetent=yes],
	[cf_cv_status_tgetent=no],
	[cf_cv_status_tgetent=no])])

if test $cf_cv_status_tgetent = yes
then
	AC_DEFINE(BROKEN_TGETENT_STATUS)
fi
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_C11_NORETURN version: 4 updated: 2023/02/18 17:41:25
dnl ---------------
AC_DEFUN([CF_C11_NORETURN],
[
AC_MSG_CHECKING(if you want to use C11 _Noreturn feature)
CF_ARG_ENABLE(stdnoreturn,
	[  --enable-stdnoreturn    enable C11 _Noreturn feature for diagnostics],
	[enable_stdnoreturn=yes],
	[enable_stdnoreturn=no])
AC_MSG_RESULT($enable_stdnoreturn)

if test $enable_stdnoreturn = yes; then
AC_CACHE_CHECK([for C11 _Noreturn feature], cf_cv_c11_noreturn,
	[AC_TRY_COMPILE([
$ac_includes_default
#include <stdnoreturn.h>
static _Noreturn void giveup(void) { exit(0); }
	],
	[if (feof(stdin)) giveup()],
	cf_cv_c11_noreturn=yes,
	cf_cv_c11_noreturn=no)
	])
else
	cf_cv_c11_noreturn=no,
fi

if test "$cf_cv_c11_noreturn" = yes; then
	AC_DEFINE(HAVE_STDNORETURN_H, 1,[Define if <stdnoreturn.h> header is available and working])
	AC_DEFINE_UNQUOTED(STDC_NORETURN,_Noreturn,[Define if C11 _Noreturn keyword is supported])
	HAVE_STDNORETURN_H=1
else
	HAVE_STDNORETURN_H=0
fi

AC_SUBST(HAVE_STDNORETURN_H)
AC_SUBST(STDC_NORETURN)
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_CC_ENV_FLAGS version: 11 updated: 2023/02/20 11:15:46
dnl ---------------
dnl Check for user's environment-breakage by stuffing CFLAGS/CPPFLAGS content
dnl into CC.  This will not help with broken scripts that wrap the compiler
dnl with options, but eliminates a more common category of user confusion.
dnl
dnl In particular, it addresses the problem of being able to run the C
dnl preprocessor in a consistent manner.
dnl
dnl Caveat: this also disallows blanks in the pathname for the compiler, but
dnl the nuisance of having inconsistent settings for compiler and preprocessor
dnl outweighs that limitation.
AC_DEFUN([CF_CC_ENV_FLAGS],
[
# This should have been defined by AC_PROG_CC
: "${CC:=cc}"

AC_MSG_CHECKING(\$CFLAGS variable)
case "x$CFLAGS" in
(*-[[IUD]]*)
	AC_MSG_RESULT(broken)
	AC_MSG_WARN(your environment uses the CFLAGS variable to hold CPPFLAGS options)
	cf_flags="$CFLAGS"
	CFLAGS=
	for cf_arg in $cf_flags
	do
		CF_ADD_CFLAGS($cf_arg)
	done
	;;
(*)
	AC_MSG_RESULT(ok)
	;;
esac

AC_MSG_CHECKING(\$CC variable)
case "$CC" in
(*[[\ \	]]-*)
	AC_MSG_RESULT(broken)
	AC_MSG_WARN(your environment uses the CC variable to hold CFLAGS/CPPFLAGS options)
	# humor him...
	cf_prog=`echo "$CC" | sed -e 's/	/ /g' -e 's/[[ ]]* / /g' -e 's/[[ ]]*[[ ]]-[[^ ]].*//'`
	cf_flags=`echo "$CC" | sed -e "s%^$cf_prog%%"`
	CC="$cf_prog"
	for cf_arg in $cf_flags
	do
		case "x$cf_arg" in
		(x-[[IUDfgOW]]*)
			CF_ADD_CFLAGS($cf_arg)
			;;
		(*)
			CC="$CC $cf_arg"
			;;
		esac
	done
	CF_VERBOSE(resulting CC: '$CC')
	CF_VERBOSE(resulting CFLAGS: '$CFLAGS')
	CF_VERBOSE(resulting CPPFLAGS: '$CPPFLAGS')
	;;
(*)
	AC_MSG_RESULT(ok)
	;;
esac
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_CHECK_CACHE version: 13 updated: 2020/12/31 10:54:15
dnl --------------
dnl Check if we're accidentally using a cache from a different machine.
dnl Derive the system name, as a check for reusing the autoconf cache.
dnl
dnl If we've packaged config.guess and config.sub, run that (since it does a
dnl better job than uname).  Normally we'll use AC_CANONICAL_HOST, but allow
dnl an extra parameter that we may override, e.g., for AC_CANONICAL_SYSTEM
dnl which is useful in cross-compiles.
dnl
dnl Note: we would use $ac_config_sub, but that is one of the places where
dnl autoconf 2.5x broke compatibility with autoconf 2.13
AC_DEFUN([CF_CHECK_CACHE],
[
if test -f "$srcdir/config.guess" || test -f "$ac_aux_dir/config.guess" ; then
	ifelse([$1],,[AC_CANONICAL_HOST],[$1])
	system_name="$host_os"
else
	system_name="`(uname -s -r) 2>/dev/null`"
	if test -z "$system_name" ; then
		system_name="`(hostname) 2>/dev/null`"
	fi
fi
test -n "$system_name" && AC_DEFINE_UNQUOTED(SYSTEM_NAME,"$system_name",[Define to the system name.])
AC_CACHE_VAL(cf_cv_system_name,[cf_cv_system_name="$system_name"])

test -z "$system_name" && system_name="$cf_cv_system_name"
test -n "$cf_cv_system_name" && AC_MSG_RESULT(Configuring for $cf_cv_system_name)

if test ".$system_name" != ".$cf_cv_system_name" ; then
	AC_MSG_RESULT(Cached system name ($system_name) does not agree with actual ($cf_cv_system_name))
	AC_MSG_ERROR("Please remove config.cache and try again.")
fi
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_CLANG_COMPILER version: 9 updated: 2023/02/18 17:41:25
dnl -----------------
dnl Check if the given compiler is really clang.  clang's C driver defines
dnl __GNUC__ (fooling the configure script into setting $GCC to yes) but does
dnl not ignore some gcc options.
dnl
dnl This macro should be run "soon" after AC_PROG_CC or AC_PROG_CPLUSPLUS, to
dnl ensure that it is not mistaken for gcc/g++.  It is normally invoked from
dnl the wrappers for gcc and g++ warnings.
dnl
dnl $1 = GCC (default) or GXX
dnl $2 = CLANG_COMPILER (default)
dnl $3 = CFLAGS (default) or CXXFLAGS
AC_DEFUN([CF_CLANG_COMPILER],[
ifelse([$2],,CLANG_COMPILER,[$2])=no

if test "$ifelse([$1],,[$1],GCC)" = yes ; then
	AC_MSG_CHECKING(if this is really Clang ifelse([$1],GXX,C++,C) compiler)
	cf_save_CFLAGS="$ifelse([$3],,CFLAGS,[$3])"
	AC_TRY_COMPILE([],[
#ifdef __clang__
#else
#error __clang__ is not defined
#endif
],[ifelse([$2],,CLANG_COMPILER,[$2])=yes
],[])
	ifelse([$3],,CFLAGS,[$3])="$cf_save_CFLAGS"
	AC_MSG_RESULT($ifelse([$2],,CLANG_COMPILER,[$2]))
fi

CLANG_VERSION=none

if test "x$ifelse([$2],,CLANG_COMPILER,[$2])" = "xyes" ; then
	case "$CC" in
	(c[[1-9]][[0-9]]|*/c[[1-9]][[0-9]])
		AC_MSG_WARN(replacing broken compiler alias $CC)
		CFLAGS="$CFLAGS -std=`echo "$CC" | sed -e 's%.*/%%'`"
		CC=clang
		;;
	esac

	AC_MSG_CHECKING(version of $CC)
	CLANG_VERSION="`$CC --version 2>/dev/null | sed -e '2,$d' -e 's/^.*(CLANG[[^)]]*) //' -e 's/^.*(Debian[[^)]]*) //' -e 's/^[[^0-9.]]*//' -e 's/[[^0-9.]].*//'`"
	test -z "$CLANG_VERSION" && CLANG_VERSION=unknown
	AC_MSG_RESULT($CLANG_VERSION)

	for cf_clang_opt in \
		-Qunused-arguments \
		-Wno-error=implicit-function-declaration
	do
		AC_MSG_CHECKING(if option $cf_clang_opt works)
		cf_save_CFLAGS="$CFLAGS"
		CFLAGS="$CFLAGS $cf_clang_opt"
		AC_TRY_LINK([
			#include <stdio.h>],[
			printf("hello!\\n");],[
			cf_clang_optok=yes],[
			cf_clang_optok=no])
		AC_MSG_RESULT($cf_clang_optok)
		CFLAGS="$cf_save_CFLAGS"
		if test "$cf_clang_optok" = yes; then
			CF_VERBOSE(adding option $cf_clang_opt)
			CF_APPEND_TEXT(CFLAGS,$cf_clang_opt)
		fi
	done
fi
])
dnl ---------------------------------------------------------------------------
dnl CF_CURSES_CONFIG version: 2 updated: 2006/10/29 11:06:27
dnl ----------------
dnl Tie together the configure-script macros for curses.  It may be ncurses,
dnl but unless asked, we do not make a special search for ncurses.  However,
dnl still check for the ncurses version number, for use in other macros.
AC_DEFUN([CF_CURSES_CONFIG],
[
CF_CURSES_CPPFLAGS
CF_NCURSES_VERSION
CF_CURSES_LIBS
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_CURSES_CPPFLAGS version: 14 updated: 2021/01/02 09:31:20
dnl ------------------
dnl Look for the curses headers.
AC_DEFUN([CF_CURSES_CPPFLAGS],[

AC_CACHE_CHECK(for extra include directories,cf_cv_curses_incdir,[
cf_cv_curses_incdir=no
case "$host_os" in
(hpux10.*)
	if test "x$cf_cv_screen" = "xcurses_colr"
	then
		test -d /usr/include/curses_colr && \
		cf_cv_curses_incdir="-I/usr/include/curses_colr"
	fi
	;;
(sunos3*|sunos4*)
	if test "x$cf_cv_screen" = "xcurses_5lib"
	then
		test -d /usr/5lib && \
		test -d /usr/5include && \
		cf_cv_curses_incdir="-I/usr/5include"
	fi
	;;
esac
])
if test "$cf_cv_curses_incdir" != no
then
	CF_APPEND_TEXT(CPPFLAGS,$cf_cv_curses_incdir)
fi

CF_CURSES_HEADER
CF_TERM_HEADER
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_CURSES_HEADER version: 6 updated: 2022/12/02 20:06:52
dnl ----------------
dnl Find a "curses" header file, e.g,. "curses.h", or one of the more common
dnl variations of ncurses' installs.
dnl
dnl $1 = ncurses when looking for ncurses, or is empty
AC_DEFUN([CF_CURSES_HEADER],[
AC_CACHE_CHECK(if we have identified curses headers,cf_cv_ncurses_header,[
cf_cv_ncurses_header=none
for cf_header in \
	ncurses.h ifelse($1,,,[$1/ncurses.h]) \
	curses.h ifelse($1,,,[$1/curses.h]) ifelse($1,,[ncurses/ncurses.h ncurses/curses.h])
do
AC_TRY_COMPILE([#include <${cf_header}>],
	[initscr(); endwin()],
	[cf_cv_ncurses_header=$cf_header; break],[])
done
])

if test "$cf_cv_ncurses_header" = none ; then
	AC_MSG_ERROR(No curses header-files found)
fi

# cheat, to get the right #define's for HAVE_NCURSES_H, etc.
AC_CHECK_HEADERS($cf_cv_ncurses_header)
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_CURSES_LIBS version: 45 updated: 2022/12/02 20:06:52
dnl --------------
dnl Look for the curses libraries.  Older curses implementations may require
dnl termcap/termlib to be linked as well.  Call CF_CURSES_CPPFLAGS first.
AC_DEFUN([CF_CURSES_LIBS],[

AC_REQUIRE([CF_CURSES_CPPFLAGS])dnl
AC_MSG_CHECKING(if we have identified curses libraries)
AC_TRY_LINK([#include <${cf_cv_ncurses_header:-curses.h}>],
	[initscr(); endwin()],
	cf_result=yes,
	cf_result=no)
AC_MSG_RESULT($cf_result)

if test "$cf_result" = no ; then
case "$host_os" in
(freebsd*)
	AC_CHECK_LIB(mytinfo,tgoto,[CF_ADD_LIBS(-lmytinfo)])
	;;
(hpux10.*)
	# Looking at HPUX 10.20, the Hcurses library is the oldest (1997), cur_colr
	# next (1998), and xcurses "newer" (2000).  There is no header file for
	# Hcurses; the subdirectory curses_colr has the headers (curses.h and
	# term.h) for cur_colr
	if test "x$cf_cv_screen" = "xcurses_colr"
	then
		AC_CHECK_LIB(cur_colr,initscr,[
			CF_ADD_LIBS(-lcur_colr)
			ac_cv_func_initscr=yes
			],[
		AC_CHECK_LIB(Hcurses,initscr,[
			# HP's header uses __HP_CURSES, but user claims _HP_CURSES.
			CF_ADD_LIBS(-lHcurses)
			CF_APPEND_TEXT(CPPFLAGS,-D__HP_CURSES -D_HP_CURSES)
			ac_cv_func_initscr=yes
			])])
	fi
	;;
(linux*)
	case `arch 2>/dev/null` in
	(x86_64)
		if test -d /lib64
		then
			CF_ADD_LIBDIR(/lib64)
		else
			CF_ADD_LIBDIR(/lib)
		fi
		;;
	(*)
		CF_ADD_LIBDIR(/lib)
		;;
	esac
	;;
(sunos3*|sunos4*)
	if test "x$cf_cv_screen" = "xcurses_5lib"
	then
		if test -d /usr/5lib ; then
			CF_ADD_LIBDIR(/usr/5lib)
			CF_ADD_LIBS(-lcurses -ltermcap)
		fi
	fi
	ac_cv_func_initscr=yes
	;;
esac

if test ".$ac_cv_func_initscr" != .yes ; then
	cf_save_LIBS="$LIBS"

	if test ".${cf_cv_ncurses_version:-no}" != .no
	then
		cf_check_list="ncurses curses cursesX"
	else
		cf_check_list="cursesX curses ncurses"
	fi

	# Check for library containing tgoto.  Do this before curses library
	# because it may be needed to link the test-case for initscr.
	if test "x$cf_term_lib" = x
	then
		AC_CHECK_FUNC(tgoto,[cf_term_lib=predefined],[
			for cf_term_lib in $cf_check_list otermcap termcap tinfo termlib unknown
			do
				AC_CHECK_LIB($cf_term_lib,tgoto,[
					: "${cf_nculib_root:=$cf_term_lib}"
					break
				])
			done
		])
	fi

	# Check for library containing initscr
	test "$cf_term_lib" != predefined && test "$cf_term_lib" != unknown && LIBS="-l$cf_term_lib $cf_save_LIBS"
	if test "x$cf_curs_lib" = x
	then
		for cf_curs_lib in $cf_check_list xcurses jcurses pdcurses unknown
		do
			LIBS="-l$cf_curs_lib $cf_save_LIBS"
			if test "$cf_term_lib" = unknown || test "$cf_term_lib" = "$cf_curs_lib" ; then
				AC_MSG_CHECKING(if we can link with $cf_curs_lib library)
				AC_TRY_LINK([#include <${cf_cv_ncurses_header:-curses.h}>],
					[initscr()],
					[cf_result=yes],
					[cf_result=no])
				AC_MSG_RESULT($cf_result)
				test "$cf_result" = yes && break
			elif test "$cf_curs_lib" = "$cf_term_lib" ; then
				cf_result=no
			elif test "$cf_term_lib" != predefined ; then
				AC_MSG_CHECKING(if we need both $cf_curs_lib and $cf_term_lib libraries)
				AC_TRY_LINK([#include <${cf_cv_ncurses_header:-curses.h}>],
					[initscr(); endwin();],
					[cf_result=no],
					[
					LIBS="-l$cf_curs_lib -l$cf_term_lib $cf_save_LIBS"
					AC_TRY_LINK([#include <${cf_cv_ncurses_header:-curses.h}>],
						[initscr()],
						[cf_result=yes],
						[cf_result=error])
					])
				AC_MSG_RESULT($cf_result)
				test "$cf_result" != error && break
			fi
		done
	fi
	test "$cf_curs_lib" = unknown && AC_MSG_ERROR(no curses library found)
fi
fi

])dnl
dnl ---------------------------------------------------------------------------
dnl CF_CURSES_TERMCAP version: 15 updated: 2023/12/09 10:53:57
dnl -----------------
dnl Check if we should include <curses.h> to pick up prototypes for termcap
dnl functions.  On terminfo systems, these are normally declared in <curses.h>,
dnl but may be in <term.h>.  We check for termcap.h as an alternate, but it
dnl isn't standard (usually associated with GNU termcap).
dnl
dnl The 'tgoto()' function is declared in both terminfo and termcap.
dnl
dnl See CF_TYPE_OUTCHAR for more details.
AC_DEFUN([CF_CURSES_TERMCAP],
[
AC_REQUIRE([CF_CURSES_TERM_H])
AC_CACHE_CHECK(if we should include curses.h or termcap.h, cf_cv_need_curses_h,[
cf_save_CPPFLAGS="$CPPFLAGS"
cf_cv_need_curses_h=no

for cf_t_opts in "" "NEED_TERMCAP_H"
do
for cf_c_opts in "" "NEED_CURSES_H"
do

    CPPFLAGS="$cf_save_CPPFLAGS $CHECK_DECL_FLAG"
    test -n "$cf_c_opts" && CPPFLAGS="$CPPFLAGS -D$cf_c_opts"
    test -n "$cf_t_opts" && CPPFLAGS="$CPPFLAGS -D$cf_t_opts"
	cf_tgoto_decl="
	extern char *tgoto(char*,int,int);"
	test -n "${cf_c_opts}${cf_t_opts}" && cf_tgoto_decl=

    AC_TRY_LINK([/* $cf_c_opts $cf_t_opts */
$CHECK_DECL_HDRS $cf_tgoto_decl],
	[static char fmt[] = ""; char *x = tgoto(fmt); (void)x],
	[test "$cf_cv_need_curses_h" = no && {
	     cf_cv_need_curses_h=maybe
	     cf_ok_c_opts=$cf_c_opts
	     cf_ok_t_opts=$cf_t_opts
	}],
	[echo "Recompiling with corrected call (C:$cf_c_opts, T:$cf_t_opts)" >&AC_FD_CC
	AC_TRY_LINK([
$CHECK_DECL_HDRS $cf_tgoto_decl],
	[static char fmt[] = ""; char *x = tgoto(fmt,0,0); (void)x],
	[cf_cv_need_curses_h=yes
	 cf_ok_c_opts=$cf_c_opts
	 cf_ok_t_opts=$cf_t_opts])])

	CPPFLAGS="$cf_save_CPPFLAGS"
	test "$cf_cv_need_curses_h" = yes && break
done
	test "$cf_cv_need_curses_h" = yes && break
done

if test "$cf_cv_need_curses_h" != no ; then
	echo "Curses/termcap test = $cf_cv_need_curses_h (C:$cf_ok_c_opts, T:$cf_ok_t_opts)" >&AC_FD_CC
	if test -n "$cf_ok_c_opts" ; then
		if test -n "$cf_ok_t_opts" ; then
			cf_cv_need_curses_h=both
		else
			cf_cv_need_curses_h=curses.h
		fi
	elif test -n "$cf_ok_t_opts" ; then
		cf_cv_need_curses_h=termcap.h
	elif test "$cf_cv_term_header" != no ; then
		cf_cv_need_curses_h=term.h
	else
		cf_cv_need_curses_h=no
	fi
fi
])

case $cf_cv_need_curses_h in
(both)
	AC_DEFINE_UNQUOTED(NEED_CURSES_H,1,[Define to 1 if we must include curses.h])
	AC_DEFINE_UNQUOTED(NEED_TERMCAP_H,1,[Define to 1 if we must include termcap.h])
	;;
(curses.h)
	AC_DEFINE_UNQUOTED(NEED_CURSES_H,1,[Define to 1 if we must include curses.h])
	;;
(term.h)
	AC_DEFINE_UNQUOTED(NEED_TERM_H,1,[Define to 1 if we must include term.h])
	;;
(termcap.h)
	AC_DEFINE_UNQUOTED(NEED_TERMCAP_H,1,[Define to 1 if we must include termcap.h])
	;;
esac

])dnl
dnl ---------------------------------------------------------------------------
dnl CF_CURSES_TERM_H version: 16 updated: 2024/01/07 06:34:16
dnl ----------------
dnl SVr4 curses should have term.h as well (where it puts the definitions of
dnl the low-level interface).  This may not be true in old/broken implementations,
dnl as well as in misconfigured systems (e.g., gcc configured for Solaris 2.4
dnl running with Solaris 2.5.1).
AC_DEFUN([CF_CURSES_TERM_H],
[
AC_REQUIRE([CF_CURSES_CPPFLAGS])dnl

AC_CACHE_CHECK(for term.h, cf_cv_term_header,[

# If we found <ncurses/curses.h>, look for <ncurses/term.h>, but always look
# for <term.h> if we do not find the variant.

cf_header_list="term.h ncurses/term.h ncursesw/term.h"

case "${cf_cv_ncurses_header:-curses.h}" in
(*/*)
	cf_header_item=`echo "${cf_cv_ncurses_header:-curses.h}" | sed -e 's%\..*%%' -e 's%/.*%/%'`term.h
	cf_header_list="$cf_header_item $cf_header_list"
	;;
esac

for cf_header in $cf_header_list
do
	AC_TRY_COMPILE([
#include <${cf_cv_ncurses_header:-curses.h}>
#include <${cf_header}>],
	[WINDOW *x; (void)x],
	[cf_cv_term_header=$cf_header
	 break],
	[cf_cv_term_header=no])
done

case "$cf_cv_term_header" in
(no)
	# If curses is ncurses, some packagers still mess it up by trying to make
	# us use GNU termcap.  This handles the most common case.
	for cf_header in ncurses/term.h ncursesw/term.h
	do
		AC_TRY_COMPILE([
#include <${cf_cv_ncurses_header:-curses.h}>
#ifdef NCURSES_VERSION
#include <${cf_header}>
#else
#error expected NCURSES_VERSION to be defined
#endif],
			[WINDOW *x; (void)x],
			[cf_cv_term_header=$cf_header
			 break],
			[cf_cv_term_header=no])
	done
	;;
esac
])

case "$cf_cv_term_header" in
(term.h)
	AC_DEFINE(HAVE_TERM_H,1,[Define to 1 if we have term.h])
	;;
(ncurses/term.h)
	AC_DEFINE(HAVE_NCURSES_TERM_H,1,[Define to 1 if we have ncurses/term.h])
	;;
(ncursesw/term.h)
	AC_DEFINE(HAVE_NCURSESW_TERM_H,1,[Define to 1 if we have ncursesw/term.h])
	;;
esac
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_DIRNAME version: 5 updated: 2020/12/31 20:19:42
dnl ----------
dnl "dirname" is not portable, so we fake it with a shell script.
AC_DEFUN([CF_DIRNAME],[$1=`echo "$2" | sed -e 's%/[[^/]]*$%%'`])dnl
dnl ---------------------------------------------------------------------------
dnl CF_DISABLE_ECHO version: 14 updated: 2021/09/04 06:35:04
dnl ---------------
dnl You can always use "make -n" to see the actual options, but it is hard to
dnl pick out/analyze warning messages when the compile-line is long.
dnl
dnl Sets:
dnl	ECHO_LT - symbol to control if libtool is verbose
dnl	ECHO_LD - symbol to prefix "cc -o" lines
dnl	RULE_CC - symbol to put before implicit "cc -c" lines (e.g., .c.o)
dnl	SHOW_CC - symbol to put before explicit "cc -c" lines
dnl	ECHO_CC - symbol to put before any "cc" line
dnl
AC_DEFUN([CF_DISABLE_ECHO],[
AC_MSG_CHECKING(if you want to see long compiling messages)
CF_ARG_DISABLE(echo,
	[  --disable-echo          do not display "compiling" commands],
	[
	ECHO_LT='--silent'
	ECHO_LD='@echo linking [$]@;'
	RULE_CC='@echo compiling [$]<'
	SHOW_CC='@echo compiling [$]@'
	ECHO_CC='@'
],[
	ECHO_LT=''
	ECHO_LD=''
	RULE_CC=''
	SHOW_CC=''
	ECHO_CC=''
])
AC_MSG_RESULT($enableval)
AC_SUBST(ECHO_LT)
AC_SUBST(ECHO_LD)
AC_SUBST(RULE_CC)
AC_SUBST(SHOW_CC)
AC_SUBST(ECHO_CC)
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_DISABLE_RPATH_HACK version: 3 updated: 2021/01/05 20:14:44
dnl ---------------------
dnl The rpath-hack makes it simpler to build programs, particularly with the
dnl *BSD ports which may have essential libraries in unusual places.  But it
dnl can interfere with building an executable for the base system.  Use this
dnl option in that case.
AC_DEFUN([CF_DISABLE_RPATH_HACK],
[
AC_MSG_CHECKING(if rpath-hack should be disabled)
CF_ARG_DISABLE(rpath-hack,
	[  --disable-rpath-hack    don't add rpath options for additional libraries],
	[enable_rpath_hack=no],
	[enable_rpath_hack=yes])
dnl TODO - drop cf_disable_rpath_hack
if test "x$enable_rpath_hack" = xno; then cf_disable_rpath_hack=yes; else cf_disable_rpath_hack=no; fi
AC_MSG_RESULT($cf_disable_rpath_hack)

if test "$enable_rpath_hack" = yes ; then
	CF_RPATH_HACK
fi
])
dnl ---------------------------------------------------------------------------
dnl CF_FIND_LIBRARY version: 11 updated: 2021/01/02 09:31:20
dnl ---------------
dnl Look for a non-standard library, given parameters for AC_TRY_LINK.  We
dnl prefer a standard location, and use -L options only if we do not find the
dnl library in the standard library location(s).
dnl	$1 = library name
dnl	$2 = library class, usually the same as library name
dnl	$3 = includes
dnl	$4 = code fragment to compile/link
dnl	$5 = corresponding function-name
dnl	$6 = flag, nonnull if failure should not cause an error-exit
dnl
dnl Sets the variable "$cf_libdir" as a side-effect, so we can see if we had
dnl to use a -L option.
AC_DEFUN([CF_FIND_LIBRARY],
[
	eval 'cf_cv_have_lib_'"$1"'=no'
	cf_libdir=""
	AC_CHECK_FUNC($5,
		eval 'cf_cv_have_lib_'"$1"'=yes',[
		cf_save_LIBS="$LIBS"
		AC_MSG_CHECKING(for $5 in -l$1)
		LIBS="-l$1 $LIBS"
		AC_TRY_LINK([$3],[$4],
			[AC_MSG_RESULT(yes)
			 eval 'cf_cv_have_lib_'"$1"'=yes'
			],
			[AC_MSG_RESULT(no)
			CF_LIBRARY_PATH(cf_search,$2)
			for cf_libdir in $cf_search
			do
				AC_MSG_CHECKING(for -l$1 in $cf_libdir)
				LIBS="-L$cf_libdir -l$1 $cf_save_LIBS"
				AC_TRY_LINK([$3],[$4],
					[AC_MSG_RESULT(yes)
			 		 eval 'cf_cv_have_lib_'"$1"'=yes'
					 break],
					[AC_MSG_RESULT(no)
					 LIBS="$cf_save_LIBS"])
			done
			])
		])
eval 'cf_found_library="[$]cf_cv_have_lib_'"$1"\"
ifelse($6,,[
if test "$cf_found_library" = no ; then
	AC_MSG_ERROR(Cannot link $1 library)
fi
])
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_FUNC_TGETENT version: 27 updated: 2023/12/01 17:22:50
dnl ---------------
dnl Check for tgetent function in termcap library.  If we cannot find this,
dnl we'll use the $LINES and $COLUMNS environment variables to pass screen
dnl size information to subprocesses.  (We cannot use terminfo's compatibility
dnl function, since it cannot provide the termcap-format data).
dnl
dnl If the --disable-full-tgetent option is given, we'll settle for the first
dnl tgetent function we find.  Since the search list in that case does not
dnl include the termcap library, that allows us to default to terminfo.
AC_DEFUN([CF_FUNC_TGETENT],
[
# compute a reasonable value for $TERM to give tgetent(), since we may be
# running in 'screen', which sets $TERMCAP to a specific entry that is not
# necessarily in /etc/termcap - unsetenv is not portable, so we cannot simply
# discard $TERMCAP.
cf_TERMVAR=vt100
if test -n "$TERMCAP"
then
	cf_TERMCAP=`echo "$TERMCAP" | tr '\n' ' ' | sed -e 's/^..|//' -e 's/|.*//'`
	case "$cf_TERMCAP" in
	(screen*.*)
		;;
	(*)
		cf_TERMVAR="$cf_TERMCAP"
		;;
	esac
fi
test -z "$cf_TERMVAR" && cf_TERMVAR=vt100

# BSD termcap used no header file
# SVr4 provided termcap prototypes as a legacy feature in term.h
# GNU termcap provided termcap prototypes in termcap.h
# ncurses provides termcap prototypes in both term.h and termcap.h
#
# The terminfo-based termcap interfaces do not provide a full tgetent (i.e., do
# not return the text of the termcap entry in the buffer), but as a special
# case, FreeBSD provides ncurses' termcap.h with a modified termcap reader that
# returns the termcap text.
AC_CHECK_HEADERS(termcap.h)

cf_termcap_h="\
#ifdef HAVE_TERMCAP_H
#include <termcap.h>
#else
extern int tgetent(char *, const char *);
#endif"

AC_MSG_CHECKING(if we want full tgetent function)
CF_ARG_DISABLE(full-tgetent,
	[  --disable-full-tgetent  disable check for full tgetent function],
	cf_full_tgetent=no,
	cf_full_tgetent=yes,yes)
AC_MSG_RESULT($cf_full_tgetent)

if test "$cf_full_tgetent" = yes ; then
	cf_test_message="full tgetent"
else
	cf_test_message="tgetent"
fi

AC_CACHE_CHECK(for $cf_test_message function,cf_cv_lib_tgetent,[
cf_save_LIBS="$LIBS"
cf_cv_lib_tgetent=no
cf_TERMLIB="termlib ncursesw ncurses curses"
if test "$cf_full_tgetent" = yes ; then
	cf_TERMLIB="otermcap termcap $cf_TERMLIB"
	cf_TERMTST="buffer[[0]] == 0"
else
	cf_TERMLIB="tinfow tinfo $cf_TERMLIB"
	cf_TERMTST="0"
fi
for cf_termlib in '' $cf_TERMLIB ; do
	LIBS="$cf_save_LIBS"
	test -n "$cf_termlib" && { CF_ADD_LIB($cf_termlib) }
	AC_TRY_RUN([
$cf_termcap_h

/* terminfo implementations ignore the buffer argument, making it useless for
 * the xterm application, which uses this information to make a new TERMCAP
 * environment variable.
 */
int main(void)
{
	char buffer[1024];
	buffer[0] = 0;
	tgetent(buffer, "$cf_TERMVAR");
	${cf_cv_main_return:-return} ($cf_TERMTST); }],
	[echo "yes, there is a termcap/tgetent in $cf_termlib" 1>&AC_FD_CC
	 if test -n "$cf_termlib" ; then
	 	cf_cv_lib_tgetent="-l$cf_termlib"
	 else
	 	cf_cv_lib_tgetent=yes
	 fi
	 break],
	[echo "no, there is no termcap/tgetent in $cf_termlib" 1>&AC_FD_CC],
	[echo "cross-compiling, cannot verify if a termcap/tgetent is present in $cf_termlib" 1>&AC_FD_CC])
done
LIBS="$cf_save_LIBS"
])

# If we found a working tgetent(), set LIBS and check for termcap.h.
# (LIBS cannot be set inside AC_CACHE_CHECK; the commands there should
# not have side effects other than setting the cache variable, because
# they are not executed when a cached value exists.)
if test "x$cf_cv_lib_tgetent" != xno ; then
	test "x$cf_cv_lib_tgetent" != xyes && { CF_ADD_LIBS($cf_cv_lib_tgetent) }
	AC_DEFINE(USE_TERMCAP,1,[Define 1 to indicate that working tgetent is found])
	if test "$cf_full_tgetent" = no ; then
		AC_TRY_COMPILE([
#include <termcap.h>],[
#ifdef NCURSES_VERSION
#error do not use ncurses termcap.h
#endif],[AC_DEFINE(HAVE_TERMCAP_H)])
	fi
else
        # If we didn't find a tgetent() that supports the buffer
        # argument, look again to see whether we can find even
        # a crippled one.  A crippled tgetent() is still useful to
        # validate values for the TERM environment variable given to
        # child processes.
	AC_CACHE_CHECK(for partial tgetent function,cf_cv_lib_part_tgetent,[
	cf_cv_lib_part_tgetent=no
	for cf_termlib in $cf_TERMLIB ; do
		LIBS="$cf_save_LIBS -l$cf_termlib"
		AC_TRY_LINK([$cf_termcap_h],[tgetent(0, "$cf_TERMVAR")],
			[echo "there is a terminfo/tgetent in $cf_termlib" 1>&AC_FD_CC
			 cf_cv_lib_part_tgetent="-l$cf_termlib"
			 break])
	done
	LIBS="$cf_save_LIBS"
	])

	if test "$cf_cv_lib_part_tgetent" != no ; then
		CF_ADD_LIBS($cf_cv_lib_part_tgetent)
                # If this is linking against ncurses, we'll trigger the
                # ifdef in resize.c that turns the termcap stuff back off.
		AC_DEFINE(USE_TERMINFO,1,[Define to 1 to indicate that terminfo provides the tgetent interface])
	fi
fi
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_GCC_ATTRIBUTES version: 24 updated: 2021/03/20 12:00:25
dnl -----------------
dnl Test for availability of useful gcc __attribute__ directives to quiet
dnl compiler warnings.  Though useful, not all are supported -- and contrary
dnl to documentation, unrecognized directives cause older compilers to barf.
AC_DEFUN([CF_GCC_ATTRIBUTES],
[AC_REQUIRE([AC_PROG_FGREP])dnl
AC_REQUIRE([CF_C11_NORETURN])dnl

if test "$GCC" = yes || test "$GXX" = yes
then
cat > conftest.i <<EOF
#ifndef GCC_PRINTF
#define GCC_PRINTF 0
#endif
#ifndef GCC_SCANF
#define GCC_SCANF 0
#endif
#ifndef GCC_NORETURN
#define GCC_NORETURN /* nothing */
#endif
#ifndef GCC_UNUSED
#define GCC_UNUSED /* nothing */
#endif
EOF
if test "$GCC" = yes
then
	AC_CHECKING([for $CC __attribute__ directives])
cat > "conftest.$ac_ext" <<EOF
#line __oline__ "${as_me:-configure}"
#include <stdio.h>
#include "confdefs.h"
#include "conftest.h"
#include "conftest.i"
#if	GCC_PRINTF
#define GCC_PRINTFLIKE(fmt,var) __attribute__((format(printf,fmt,var)))
#else
#define GCC_PRINTFLIKE(fmt,var) /*nothing*/
#endif
#if	GCC_SCANF
#define GCC_SCANFLIKE(fmt,var)  __attribute__((format(scanf,fmt,var)))
#else
#define GCC_SCANFLIKE(fmt,var)  /*nothing*/
#endif
extern void wow(char *,...) GCC_SCANFLIKE(1,2);
extern GCC_NORETURN void oops(char *,...) GCC_PRINTFLIKE(1,2);
extern GCC_NORETURN void foo(void);
int main(int argc GCC_UNUSED, char *argv[[]] GCC_UNUSED) { (void)argc; (void)argv; return 0; }
EOF
	cf_printf_attribute=no
	cf_scanf_attribute=no
	for cf_attribute in scanf printf unused noreturn
	do
		CF_UPPER(cf_ATTRIBUTE,$cf_attribute)
		cf_directive="__attribute__(($cf_attribute))"
		echo "checking for $CC $cf_directive" 1>&AC_FD_CC

		case "$cf_attribute" in
		(printf)
			cf_printf_attribute=yes
			cat >conftest.h <<EOF
#define GCC_$cf_ATTRIBUTE 1
EOF
			;;
		(scanf)
			cf_scanf_attribute=yes
			cat >conftest.h <<EOF
#define GCC_$cf_ATTRIBUTE 1
EOF
			;;
		(*)
			cat >conftest.h <<EOF
#define GCC_$cf_ATTRIBUTE $cf_directive
EOF
			;;
		esac

		if AC_TRY_EVAL(ac_compile); then
			test -n "$verbose" && AC_MSG_RESULT(... $cf_attribute)
			cat conftest.h >>confdefs.h
			case "$cf_attribute" in
			(noreturn)
				AC_DEFINE_UNQUOTED(GCC_NORETURN,$cf_directive,[Define to noreturn-attribute for gcc])
				;;
			(printf)
				cf_value='/* nothing */'
				if test "$cf_printf_attribute" != no ; then
					cf_value='__attribute__((format(printf,fmt,var)))'
					AC_DEFINE(GCC_PRINTF,1,[Define to 1 if the compiler supports gcc-like printf attribute.])
				fi
				AC_DEFINE_UNQUOTED(GCC_PRINTFLIKE(fmt,var),$cf_value,[Define to printf-attribute for gcc])
				;;
			(scanf)
				cf_value='/* nothing */'
				if test "$cf_scanf_attribute" != no ; then
					cf_value='__attribute__((format(scanf,fmt,var)))'
					AC_DEFINE(GCC_SCANF,1,[Define to 1 if the compiler supports gcc-like scanf attribute.])
				fi
				AC_DEFINE_UNQUOTED(GCC_SCANFLIKE(fmt,var),$cf_value,[Define to sscanf-attribute for gcc])
				;;
			(unused)
				AC_DEFINE_UNQUOTED(GCC_UNUSED,$cf_directive,[Define to unused-attribute for gcc])
				;;
			esac
		fi
	done
else
	${FGREP-fgrep} define conftest.i >>confdefs.h
fi
rm -rf ./conftest*
fi
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_GCC_VERSION version: 9 updated: 2023/03/05 14:30:13
dnl --------------
dnl Find version of gcc, and (because icc/clang pretend to be gcc without being
dnl compatible), attempt to determine if icc/clang is actually used.
AC_DEFUN([CF_GCC_VERSION],[
AC_REQUIRE([AC_PROG_CC])
GCC_VERSION=none
if test "$GCC" = yes ; then
	AC_MSG_CHECKING(version of $CC)
	GCC_VERSION="`${CC} --version 2>/dev/null | sed -e '2,$d' -e 's/^[[^(]]*([[^)]][[^)]]*) //' -e 's/^[[^0-9.]]*//' -e 's/[[^0-9.]].*//'`"
	test -z "$GCC_VERSION" && GCC_VERSION=unknown
	AC_MSG_RESULT($GCC_VERSION)
fi
CF_INTEL_COMPILER(GCC,INTEL_COMPILER,CFLAGS)
CF_CLANG_COMPILER(GCC,CLANG_COMPILER,CFLAGS)
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_GCC_WARNINGS version: 43 updated: 2024/12/21 08:44:12
dnl ---------------
dnl Check if the compiler supports useful warning options.  There's a few that
dnl we don't use, simply because they're too noisy:
dnl
dnl	-Wconversion (useful in older versions of gcc, but not in gcc 2.7.x)
dnl	-Winline (usually not worthwhile)
dnl	-Wredundant-decls (system headers make this too noisy)
dnl	-Wtraditional (combines too many unrelated messages, only a few useful)
dnl	-Wwrite-strings (too noisy, but should review occasionally).  This
dnl		is enabled for ncurses using "--enable-const".
dnl	-pedantic
dnl
dnl Parameter:
dnl	$1 is an optional list of gcc warning flags that a particular
dnl		application might want to use, e.g., "no-unused" for
dnl		-Wno-unused
dnl Special:
dnl	If $with_ext_const is "yes", add a check for -Wwrite-strings
dnl
AC_DEFUN([CF_GCC_WARNINGS],
[
AC_REQUIRE([CF_GCC_VERSION])
if test "x$have_x" = xyes; then CF_CONST_X_STRING fi
cat > "conftest.$ac_ext" <<EOF
#line __oline__ "${as_me:-configure}"
int main(int argc, char *argv[[]]) { return (argv[[argc-1]] == 0) ; }
EOF
if test "$INTEL_COMPILER" = yes
then
# The "-wdXXX" options suppress warnings:
# remark #1419: external declaration in primary source file
# remark #1683: explicit conversion of a 64-bit integral type to a smaller integral type (potential portability problem)
# remark #1684: conversion from pointer to same-sized integral type (potential portability problem)
# remark #193: zero used for undefined preprocessing identifier
# remark #593: variable "curs_sb_left_arrow" was set but never used
# remark #810: conversion from "int" to "Dimension={unsigned short}" may lose significant bits
# remark #869: parameter "tw" was never referenced
# remark #981: operands are evaluated in unspecified order
# warning #279: controlling expression is constant

	AC_CHECKING([for $CC warning options])
	cf_save_CFLAGS="$CFLAGS"
	EXTRA_CFLAGS="$EXTRA_CFLAGS -Wall"
	for cf_opt in \
		wd1419 \
		wd1683 \
		wd1684 \
		wd193 \
		wd593 \
		wd279 \
		wd810 \
		wd869 \
		wd981
	do
		CFLAGS="$cf_save_CFLAGS $EXTRA_CFLAGS -$cf_opt"
		if AC_TRY_EVAL(ac_compile); then
			test -n "$verbose" && AC_MSG_RESULT(... -$cf_opt)
			EXTRA_CFLAGS="$EXTRA_CFLAGS -$cf_opt"
		fi
	done
	CFLAGS="$cf_save_CFLAGS"
elif test "$GCC" = yes && test "$GCC_VERSION" != "unknown"
then
	AC_CHECKING([for $CC warning options])
	cf_save_CFLAGS="$CFLAGS"
	cf_warn_CONST=""
	test "$with_ext_const" = yes && cf_warn_CONST="Wwrite-strings"
	cf_gcc_warnings="Wignored-qualifiers Wlogical-op Wvarargs"
	test "x$CLANG_COMPILER" = xyes && cf_gcc_warnings=
	for cf_opt in W Wall \
		Wbad-function-cast \
		Wcast-align \
		Wcast-qual \
		Wdeclaration-after-statement \
		Wextra \
		Winline \
		Wmissing-declarations \
		Wmissing-prototypes \
		Wnested-externs \
		Wpointer-arith \
		Wshadow \
		Wstrict-prototypes \
		Wundef Wno-inline $cf_gcc_warnings $cf_warn_CONST $1
	do
		CFLAGS="$cf_save_CFLAGS $EXTRA_CFLAGS -$cf_opt"
		if AC_TRY_EVAL(ac_compile); then
			test -n "$verbose" && AC_MSG_RESULT(... -$cf_opt)
			case "$cf_opt" in
			(Winline)
				case "$GCC_VERSION" in
				([[34]].*)
					CF_VERBOSE(feature is broken in gcc $GCC_VERSION)
					continue;;
				esac
				;;
			(Wpointer-arith)
				case "$GCC_VERSION" in
				([[12]].*)
					CF_VERBOSE(feature is broken in gcc $GCC_VERSION)
					continue;;
				esac
				;;
			esac
			EXTRA_CFLAGS="$EXTRA_CFLAGS -$cf_opt"
		fi
	done
	CFLAGS="$cf_save_CFLAGS"
fi
rm -rf ./conftest*

AC_SUBST(EXTRA_CFLAGS)
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_GLOB_FULLPATH version: 2 updated: 2024/08/03 12:34:02
dnl ----------------
dnl Use this in case-statements to check for pathname syntax, i.e., absolute
dnl pathnames.  The "x" is assumed since we provide an alternate form for DOS.
AC_DEFUN([CF_GLOB_FULLPATH],[
AC_REQUIRE([CF_WITH_SYSTYPE])dnl
case "$cf_cv_system_name" in
(cygwin*|msys*|mingw32*|mingw64|os2*)
	GLOB_FULLPATH_POSIX='/*'
	GLOB_FULLPATH_OTHER='[[a-zA-Z]]:[[\\/]]*'
	;;
(*)
	GLOB_FULLPATH_POSIX='/*'
	GLOB_FULLPATH_OTHER=$GLOB_FULLPATH_POSIX
	;;
esac
AC_SUBST(GLOB_FULLPATH_POSIX)
AC_SUBST(GLOB_FULLPATH_OTHER)
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_GNU_SOURCE version: 10 updated: 2018/12/10 20:09:41
dnl -------------
dnl Check if we must define _GNU_SOURCE to get a reasonable value for
dnl _XOPEN_SOURCE, upon which many POSIX definitions depend.  This is a defect
dnl (or misfeature) of glibc2, which breaks portability of many applications,
dnl since it is interwoven with GNU extensions.
dnl
dnl Well, yes we could work around it...
dnl
dnl Parameters:
dnl	$1 is the nominal value for _XOPEN_SOURCE
AC_DEFUN([CF_GNU_SOURCE],
[
cf_gnu_xopen_source=ifelse($1,,500,$1)

AC_CACHE_CHECK(if this is the GNU C library,cf_cv_gnu_library,[
AC_TRY_COMPILE([#include <sys/types.h>],[
	#if __GLIBC__ > 0 && __GLIBC_MINOR__ >= 0
		return 0;
	#elif __NEWLIB__ > 0 && __NEWLIB_MINOR__ >= 0
		return 0;
	#else
	#	error not GNU C library
	#endif],
	[cf_cv_gnu_library=yes],
	[cf_cv_gnu_library=no])
])

if test x$cf_cv_gnu_library = xyes; then

	# With glibc 2.19 (13 years after this check was begun), _DEFAULT_SOURCE
	# was changed to help a little.  newlib incorporated the change about 4
	# years later.
	AC_CACHE_CHECK(if _DEFAULT_SOURCE can be used as a basis,cf_cv_gnu_library_219,[
		cf_save="$CPPFLAGS"
		CF_APPEND_TEXT(CPPFLAGS,-D_DEFAULT_SOURCE)
		AC_TRY_COMPILE([#include <sys/types.h>],[
			#if (__GLIBC__ == 2 && __GLIBC_MINOR__ >= 19) || (__GLIBC__ > 2)
				return 0;
			#elif (__NEWLIB__ == 2 && __NEWLIB_MINOR__ >= 4) || (__GLIBC__ > 3)
				return 0;
			#else
			#	error GNU C library __GLIBC__.__GLIBC_MINOR__ is too old
			#endif],
			[cf_cv_gnu_library_219=yes],
			[cf_cv_gnu_library_219=no])
		CPPFLAGS="$cf_save"
	])

	if test "x$cf_cv_gnu_library_219" = xyes; then
		cf_save="$CPPFLAGS"
		AC_CACHE_CHECK(if _XOPEN_SOURCE=$cf_gnu_xopen_source works with _DEFAULT_SOURCE,cf_cv_gnu_dftsrc_219,[
			CF_ADD_CFLAGS(-D_DEFAULT_SOURCE -D_XOPEN_SOURCE=$cf_gnu_xopen_source)
			AC_TRY_COMPILE([
				#include <limits.h>
				#include <sys/types.h>
				],[
				#if (_XOPEN_SOURCE >= $cf_gnu_xopen_source) && (MB_LEN_MAX > 1)
					return 0;
				#else
				#	error GNU C library is too old
				#endif],
				[cf_cv_gnu_dftsrc_219=yes],
				[cf_cv_gnu_dftsrc_219=no])
			])
		test "x$cf_cv_gnu_dftsrc_219" = "xyes" || CPPFLAGS="$cf_save"
	else
		cf_cv_gnu_dftsrc_219=maybe
	fi

	if test "x$cf_cv_gnu_dftsrc_219" != xyes; then

		AC_CACHE_CHECK(if we must define _GNU_SOURCE,cf_cv_gnu_source,[
		AC_TRY_COMPILE([#include <sys/types.h>],[
			#ifndef _XOPEN_SOURCE
			#error	expected _XOPEN_SOURCE to be defined
			#endif],
			[cf_cv_gnu_source=no],
			[cf_save="$CPPFLAGS"
			 CF_ADD_CFLAGS(-D_GNU_SOURCE)
			 AC_TRY_COMPILE([#include <sys/types.h>],[
				#ifdef _XOPEN_SOURCE
				#error	expected _XOPEN_SOURCE to be undefined
				#endif],
				[cf_cv_gnu_source=no],
				[cf_cv_gnu_source=yes])
			CPPFLAGS="$cf_save"
			])
		])

		if test "$cf_cv_gnu_source" = yes
		then
		AC_CACHE_CHECK(if we should also define _DEFAULT_SOURCE,cf_cv_default_source,[
			CF_APPEND_TEXT(CPPFLAGS,-D_GNU_SOURCE)
			AC_TRY_COMPILE([#include <sys/types.h>],[
				#ifdef _DEFAULT_SOURCE
				#error	expected _DEFAULT_SOURCE to be undefined
				#endif],
				[cf_cv_default_source=no],
				[cf_cv_default_source=yes])
			])
			if test "$cf_cv_default_source" = yes
			then
				CF_APPEND_TEXT(CPPFLAGS,-D_DEFAULT_SOURCE)
			fi
		fi
	fi

fi
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_HEADER_PATH version: 15 updated: 2021/01/01 13:31:04
dnl --------------
dnl Construct a search-list of directories for a nonstandard header-file
dnl
dnl Parameters
dnl	$1 = the variable to return as result
dnl	$2 = the package name
AC_DEFUN([CF_HEADER_PATH],
[
$1=

# collect the current set of include-directories from compiler flags
cf_header_path_list=""
if test -n "${CFLAGS}${CPPFLAGS}" ; then
	for cf_header_path in $CPPFLAGS $CFLAGS
	do
		case "$cf_header_path" in
		(-I*)
			cf_header_path=`echo ".$cf_header_path" |sed -e 's/^...//' -e 's,/include$,,'`
			CF_ADD_SUBDIR_PATH($1,$2,include,$cf_header_path,NONE)
			cf_header_path_list="$cf_header_path_list [$]$1"
			;;
		esac
	done
fi

# add the variations for the package we are looking for
CF_SUBDIR_PATH($1,$2,include)

test "$includedir" != NONE && \
test "$includedir" != "/usr/include" && \
test -d "$includedir" && {
	test -d "$includedir" &&    $1="[$]$1 $includedir"
	test -d "$includedir/$2" && $1="[$]$1 $includedir/$2"
}

test "$oldincludedir" != NONE && \
test "$oldincludedir" != "/usr/include" && \
test -d "$oldincludedir" && {
	test -d "$oldincludedir"    && $1="[$]$1 $oldincludedir"
	test -d "$oldincludedir/$2" && $1="[$]$1 $oldincludedir/$2"
}

$1="[$]$1 $cf_header_path_list"
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_INTEL_COMPILER version: 9 updated: 2023/02/18 17:41:25
dnl -----------------
dnl Check if the given compiler is really the Intel compiler for Linux.  It
dnl tries to imitate gcc, but does not return an error when it finds a mismatch
dnl between prototypes, e.g., as exercised by CF_MISSING_CHECK.
dnl
dnl This macro should be run "soon" after AC_PROG_CC or AC_PROG_CPLUSPLUS, to
dnl ensure that it is not mistaken for gcc/g++.  It is normally invoked from
dnl the wrappers for gcc and g++ warnings.
dnl
dnl $1 = GCC (default) or GXX
dnl $2 = INTEL_COMPILER (default) or INTEL_CPLUSPLUS
dnl $3 = CFLAGS (default) or CXXFLAGS
AC_DEFUN([CF_INTEL_COMPILER],[
AC_REQUIRE([AC_CANONICAL_HOST])
ifelse([$2],,INTEL_COMPILER,[$2])=no

if test "$ifelse([$1],,[$1],GCC)" = yes ; then
	case "$host_os" in
	(linux*|gnu*)
		AC_MSG_CHECKING(if this is really Intel ifelse([$1],GXX,C++,C) compiler)
		cf_save_CFLAGS="$ifelse([$3],,CFLAGS,[$3])"
		ifelse([$3],,CFLAGS,[$3])="$ifelse([$3],,CFLAGS,[$3]) -no-gcc"
		AC_TRY_COMPILE([],[
#ifdef __INTEL_COMPILER
#else
#error __INTEL_COMPILER is not defined
#endif
],[ifelse([$2],,INTEL_COMPILER,[$2])=yes
cf_save_CFLAGS="$cf_save_CFLAGS -we147"
],[])
		ifelse([$3],,CFLAGS,[$3])="$cf_save_CFLAGS"
		AC_MSG_RESULT($ifelse([$2],,INTEL_COMPILER,[$2]))
		;;
	esac
fi
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_LARGEFILE version: 13 updated: 2023/12/03 19:09:59
dnl ------------
dnl Add checks for large file support.
AC_DEFUN([CF_LARGEFILE],[
ifdef([AC_FUNC_FSEEKO],[
	AC_SYS_LARGEFILE
	if test "$enable_largefile" != no ; then
	AC_FUNC_FSEEKO

	# Normally we would collect these definitions in the config.h,
	# but (like _XOPEN_SOURCE), some environments rely on having these
	# defined before any of the system headers are included.  Another
	# case comes up with C++, e.g., on AIX the compiler compiles the
	# header files by themselves before looking at the body files it is
	# told to compile.  For ncurses, those header files do not include
	# the config.h
	if test "$ac_cv_sys_large_files" != no
	then
		CF_APPEND_TEXT(CPPFLAGS,-D_LARGE_FILES)
	fi
	if test "$ac_cv_sys_largefile_source" != no
	then
		CF_APPEND_TEXT(CPPFLAGS,-D_LARGEFILE_SOURCE)
	fi
	if test "$ac_cv_sys_file_offset_bits" != no
	then
		CF_APPEND_TEXT(CPPFLAGS,-D_FILE_OFFSET_BITS=$ac_cv_sys_file_offset_bits)
	fi

	AC_CACHE_CHECK(whether to use struct dirent64, cf_cv_struct_dirent64,[
		AC_TRY_COMPILE([
#pragma GCC diagnostic error "-Wincompatible-pointer-types"
#include <sys/types.h>
#include <dirent.h>

#ifndef __REDIRECT
/* if transitional largefile support is setup, this is true */
extern struct dirent64 * readdir(DIR *);
#endif
		],[
		DIR *dp = opendir(".");
		struct dirent64 *x = readdir(dp);
		struct dirent *y = readdir(dp);
		int z = x - y;
		(void)z;
		],
		[cf_cv_struct_dirent64=yes],
		[cf_cv_struct_dirent64=no])
	])
	test "$cf_cv_struct_dirent64" = yes && AC_DEFINE(HAVE_STRUCT_DIRENT64,1,[Define to 1 if we have struct dirent64])
	fi
])
])
dnl ---------------------------------------------------------------------------
dnl CF_LD_RPATH_OPT version: 9 updated: 2021/01/01 13:31:04
dnl ---------------
dnl For the given system and compiler, find the compiler flags to pass to the
dnl loader to use the "rpath" feature.
AC_DEFUN([CF_LD_RPATH_OPT],
[
AC_REQUIRE([CF_CHECK_CACHE])

LD_RPATH_OPT=
if test "x$cf_cv_enable_rpath" != xno
then
	AC_MSG_CHECKING(for an rpath option)
	case "$cf_cv_system_name" in
	(irix*)
		if test "$GCC" = yes; then
			LD_RPATH_OPT="-Wl,-rpath,"
		else
			LD_RPATH_OPT="-rpath "
		fi
		;;
	(linux*|gnu*|k*bsd*-gnu|freebsd*)
		LD_RPATH_OPT="-Wl,-rpath,"
		;;
	(openbsd[[2-9]].*|mirbsd*)
		LD_RPATH_OPT="-Wl,-rpath,"
		;;
	(dragonfly*)
		LD_RPATH_OPT="-rpath "
		;;
	(netbsd*)
		LD_RPATH_OPT="-Wl,-rpath,"
		;;
	(osf*|mls+*)
		LD_RPATH_OPT="-rpath "
		;;
	(solaris2*)
		LD_RPATH_OPT="-R"
		;;
	(*)
		;;
	esac
	AC_MSG_RESULT($LD_RPATH_OPT)

	case "x$LD_RPATH_OPT" in
	(x-R*)
		AC_MSG_CHECKING(if we need a space after rpath option)
		cf_save_LIBS="$LIBS"
		CF_ADD_LIBS(${LD_RPATH_OPT}$libdir)
		AC_TRY_LINK(, , cf_rpath_space=no, cf_rpath_space=yes)
		LIBS="$cf_save_LIBS"
		AC_MSG_RESULT($cf_rpath_space)
		test "$cf_rpath_space" = yes && LD_RPATH_OPT="$LD_RPATH_OPT "
		;;
	esac
fi
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_LIBRARY_PATH version: 11 updated: 2021/01/01 13:31:04
dnl ---------------
dnl Construct a search-list of directories for a nonstandard library-file
dnl
dnl Parameters
dnl	$1 = the variable to return as result
dnl	$2 = the package name
AC_DEFUN([CF_LIBRARY_PATH],
[
$1=
cf_library_path_list=""
if test -n "${LDFLAGS}${LIBS}" ; then
	for cf_library_path in $LDFLAGS $LIBS
	do
		case "$cf_library_path" in
		(-L*)
			cf_library_path=`echo ".$cf_library_path" |sed -e 's/^...//' -e 's,/lib$,,'`
			CF_ADD_SUBDIR_PATH($1,$2,lib,$cf_library_path,NONE)
			cf_library_path_list="$cf_library_path_list [$]$1"
			;;
		esac
	done
fi

CF_SUBDIR_PATH($1,$2,lib)

$1="$cf_library_path_list [$]$1"
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_MAKEFLAGS version: 21 updated: 2021/09/04 06:47:34
dnl ------------
dnl Some 'make' programs support ${MAKEFLAGS}, some ${MFLAGS}, to pass 'make'
dnl options to lower-levels.  It is very useful for "make -n" -- if we have it.
dnl (GNU 'make' does both, something POSIX 'make', which happens to make the
dnl ${MAKEFLAGS} variable incompatible because it adds the assignments :-)
AC_DEFUN([CF_MAKEFLAGS],
[AC_REQUIRE([AC_PROG_FGREP])dnl

AC_CACHE_CHECK(for makeflags variable, cf_cv_makeflags,[
	cf_cv_makeflags=''
	for cf_option in '-${MAKEFLAGS}' '${MFLAGS}'
	do
		cat >cf_makeflags.tmp <<CF_EOF
SHELL = $SHELL
all :
	@ echo '.$cf_option'
CF_EOF
		cf_result=`${MAKE:-make} -k -f cf_makeflags.tmp 2>/dev/null | ${FGREP-fgrep} -v "ing directory" | sed -e 's,[[ 	]]*$,,'`
		case "$cf_result" in
		(.*k|.*kw)
			cf_result="`${MAKE:-make} -k -f cf_makeflags.tmp CC=cc 2>/dev/null`"
			case "$cf_result" in
			(.*CC=*)	cf_cv_makeflags=
				;;
			(*)	cf_cv_makeflags=$cf_option
				;;
			esac
			break
			;;
		(.-)
			;;
		(*)
			CF_MSG_LOG(given option \"$cf_option\", no match \"$cf_result\")
			;;
		esac
	done
	rm -f cf_makeflags.tmp
])

AC_SUBST(cf_cv_makeflags)
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_MAKE_DOCS version: 5 updated: 2021/01/10 16:05:11
dnl ------------
dnl $1 = name(s) to generate rules for
dnl $2 = suffix of corresponding manpages used as input.
dnl
dnl This works best if called at the end of configure.in, following CF_WITH_MAN2HTML
define([CF_MAKE_DOCS],[
test -z "$cf_make_docs" && cf_make_docs=0

cf_output=makefile
test -f "$cf_output" || cf_output=Makefile

if test "$cf_make_docs" = 0
then
cat >>$cf_output <<CF_EOF
################################################################################
## generated by $0
.SUFFIXES : .html .$2 .man .ps .pdf .txt

${NROFF_NOTE}.$2.txt :
${NROFF_NOTE}	[\$](SHELL) -c "tbl [\$]*.$2 | nroff -man | col -bx" >[\$]@

${GROFF_NOTE}.ps.pdf :
${GROFF_NOTE}	ps2pdf [\$]*.ps
${GROFF_NOTE}
${GROFF_NOTE}.$2.ps :
${GROFF_NOTE}	[\$](SHELL) -c "tbl [\$]*.$2 | groff -man" >[\$]@
${GROFF_NOTE}
${GROFF_NOTE}.$2.txt :
${GROFF_NOTE}	GROFF_NO_SGR=stupid [\$](SHELL) -c "tbl [\$]*.$2 | nroff -rHY=0 -Tascii -man | col -bx" >[\$]@

${MAN2HTML_NOTE}.$2.html :
${MAN2HTML_NOTE}	./${MAN2HTML_TEMP} [\$]* $2 man >[\$]@

CF_EOF
	cf_make_docs=1
fi

for cf_name in $1
do
cat >>$cf_output <<CF_EOF
################################################################################
${NROFF_NOTE}docs docs-$cf_name :: $cf_name.txt
${MAN2HTML_NOTE}docs docs-$cf_name :: $cf_name.html
${GROFF_NOTE}docs docs-$cf_name :: $cf_name.pdf
${GROFF_NOTE}docs docs-$cf_name :: $cf_name.ps
${GROFF_NOTE}docs docs-$cf_name :: $cf_name.txt

clean \\
docs-clean ::
${NROFF_NOTE}	rm -f $cf_name.txt
${MAN2HTML_NOTE}	rm -f $cf_name.html
${GROFF_NOTE}	rm -f $cf_name.pdf
${GROFF_NOTE}	rm -f $cf_name.ps
${GROFF_NOTE}	rm -f $cf_name.txt

${NROFF_NOTE}$cf_name.txt  : $cf_name.$2
${MAN2HTML_NOTE}$cf_name.html : $cf_name.$2
${GROFF_NOTE}$cf_name.pdf  : $cf_name.ps
${GROFF_NOTE}$cf_name.ps   : $cf_name.$2
${GROFF_NOTE}$cf_name.txt  : $cf_name.$2
CF_EOF
done
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_MAKE_TAGS version: 6 updated: 2010/10/23 15:52:32
dnl ------------
dnl Generate tags/TAGS targets for makefiles.  Do not generate TAGS if we have
dnl a monocase filesystem.
AC_DEFUN([CF_MAKE_TAGS],[
AC_REQUIRE([CF_MIXEDCASE_FILENAMES])

AC_CHECK_PROGS(CTAGS, exctags ctags)
AC_CHECK_PROGS(ETAGS, exetags etags)

AC_CHECK_PROG(MAKE_LOWER_TAGS, ${CTAGS:-ctags}, yes, no)

if test "$cf_cv_mixedcase" = yes ; then
	AC_CHECK_PROG(MAKE_UPPER_TAGS, ${ETAGS:-etags}, yes, no)
else
	MAKE_UPPER_TAGS=no
fi

if test "$MAKE_UPPER_TAGS" = yes ; then
	MAKE_UPPER_TAGS=
else
	MAKE_UPPER_TAGS="#"
fi

if test "$MAKE_LOWER_TAGS" = yes ; then
	MAKE_LOWER_TAGS=
else
	MAKE_LOWER_TAGS="#"
fi

AC_SUBST(CTAGS)
AC_SUBST(ETAGS)

AC_SUBST(MAKE_UPPER_TAGS)
AC_SUBST(MAKE_LOWER_TAGS)
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_MISSING_CHECK version: 9 updated: 2023/01/15 05:38:19
dnl ----------------
dnl
AC_DEFUN([CF_MISSING_CHECK],
[
AC_MSG_CHECKING([for missing \"$1\" extern])
AC_CACHE_VAL([cf_cv_func_$1],[
cf_save_CPPFLAGS="$CPPFLAGS"
CPPFLAGS="$CPPFLAGS $CHECK_DECL_FLAG"
AC_TRY_LINK([
$CHECK_DECL_HDRS

#undef $1
struct zowie { int a; double b; struct zowie *c; char d; };
extern struct zowie *$1(struct zowie *);
],
[
#ifdef HAVE_LIBXT		/* needed for SunOS 4.0.3 or 4.1 */
extern void XtToolkitInitialize(void);
#endif
],
[eval 'cf_cv_func_'"$1"'=yes'],
[eval 'cf_cv_func_'"$1"'=no'])
CPPFLAGS="$cf_save_CPPFLAGS"
])
eval 'cf_result="$cf_cv_func_'"$1"\"
AC_MSG_RESULT($cf_result)
test "$cf_result" = yes && AC_DEFINE_UNQUOTED(MISSING_EXTERN_$2)
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_MISSING_EXTERN version: 3 updated: 1997/09/06 15:25:32
dnl -----------------
dnl
AC_DEFUN([CF_MISSING_EXTERN],
[for ac_func in $1
do
CF_UPPER(ac_tr_func,$ac_func)
CF_MISSING_CHECK(${ac_func}, ${ac_tr_func})dnl
done
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_MIXEDCASE_FILENAMES version: 9 updated: 2021/01/01 16:53:59
dnl ----------------------
dnl Check if the file-system supports mixed-case filenames.  If we're able to
dnl create a lowercase name and see it as uppercase, it doesn't support that.
AC_DEFUN([CF_MIXEDCASE_FILENAMES],
[
AC_CACHE_CHECK(if filesystem supports mixed-case filenames,cf_cv_mixedcase,[
if test "$cross_compiling" = yes ; then
	case "$target_alias" in
	(*-os2-emx*|*-msdosdjgpp*|*-cygwin*|*-msys*|*-mingw*|*-uwin*|darwin*)
		cf_cv_mixedcase=no
		;;
	(*)
		cf_cv_mixedcase=yes
		;;
	esac
else
	rm -f conftest CONFTEST
	echo test >conftest
	if test -f CONFTEST ; then
		cf_cv_mixedcase=no
	else
		cf_cv_mixedcase=yes
	fi
	rm -f conftest CONFTEST
fi
])
test "$cf_cv_mixedcase" = yes && AC_DEFINE(MIXEDCASE_FILENAMES,1,[Define to 1 if filesystem supports mixed-case filenames.])
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_MSG_LOG version: 5 updated: 2010/10/23 15:52:32
dnl ----------
dnl Write a debug message to config.log, along with the line number in the
dnl configure script.
AC_DEFUN([CF_MSG_LOG],[
echo "${as_me:-configure}:__oline__: testing $* ..." 1>&AC_FD_CC
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_NCURSES_CC_CHECK version: 6 updated: 2023/02/18 17:47:58
dnl -------------------
dnl Check if we can compile with ncurses' header file
dnl $1 is the cache variable to set
dnl $2 is the header-file to include
dnl $3 is the root name (ncurses or ncursesw)
AC_DEFUN([CF_NCURSES_CC_CHECK],[
	AC_TRY_COMPILE([
]ifelse($3,ncursesw,[
#define _XOPEN_SOURCE_EXTENDED
#undef  HAVE_LIBUTF8_H	/* in case we used CF_UTF8_LIB */
#define HAVE_LIBUTF8_H	/* to force ncurses' header file to use cchar_t */
])[
#include <$2>],[
#ifdef NCURSES_VERSION
]ifelse($3,ncursesw,[
#ifndef WACS_BSSB
	#error WACS_BSSB is not defined
#endif
])[
printf("%s\\n", NCURSES_VERSION);
#else
#ifdef __NCURSES_H
printf("old\\n");
#else
	#error __NCURSES_H is not defined
#endif
#endif
	]
	,[$1=$2]
	,[$1=no])
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_NCURSES_CONFIG version: 29 updated: 2025/01/10 19:55:54
dnl -----------------
dnl Tie together the configure-script macros for ncurses, preferring these in
dnl order:
dnl a) ".pc" files for pkg-config, using $NCURSES_CONFIG_PKG
dnl b) the "-config" script from ncurses, using $NCURSES_CONFIG
dnl c) just plain libraries
dnl
dnl $1 is the root library name (default: "ncurses")
AC_DEFUN([CF_NCURSES_CONFIG],[
AC_REQUIRE([CF_PKG_CONFIG])
cf_ncuconfig_root=ifelse($1,,ncurses,$1)
cf_have_ncuconfig=no

if test "x${PKG_CONFIG:=none}" != xnone; then
	AC_MSG_CHECKING(pkg-config for $cf_ncuconfig_root)
	if "$PKG_CONFIG" --exists $cf_ncuconfig_root ; then
		AC_MSG_RESULT(yes)

		AC_MSG_CHECKING(if the $cf_ncuconfig_root package files work)
		cf_have_ncuconfig=unknown

		cf_save_CFLAGS="$CFLAGS"
		cf_save_CPPFLAGS="$CPPFLAGS"
		cf_save_LIBS="$LIBS"

		cf_pkg_cflags="`$PKG_CONFIG --cflags $cf_ncuconfig_root`"
		cf_pkg_libs="`$PKG_CONFIG --libs $cf_ncuconfig_root`"

		# while -W for passing linker flags is prevalent, it is not "standard".
		# At least one wrapper for c89/c99 (in Apple's xcode) has its own
		# incompatible _and_ non-standard -W option which gives an error.  Work
		# around that pitfall.
		case "x${CC}@@${cf_pkg_libs}@${cf_pkg_cflags}" in
		(x*c[[89]]9@@*-W*)
			CF_ADD_CFLAGS($cf_pkg_cflags)
			CF_ADD_LIBS($cf_pkg_libs)

			AC_TRY_LINK([#include <${cf_cv_ncurses_header:-curses.h}>],
				[initscr(); mousemask(0,0); tigetstr((char *)0);],
				[AC_TRY_RUN([#include <${cf_cv_ncurses_header:-curses.h}>
					int main(void)
					{ const char *xx = curses_version(); return (xx == 0); }],
					[cf_test_ncuconfig=yes],
					[cf_test_ncuconfig=no],
					[cf_test_ncuconfig=maybe])],
				[cf_test_ncuconfig=no])

			CFLAGS="$cf_save_CFLAGS"
			CPPFLAGS="$cf_save_CPPFLAGS"
			LIBS="$cf_save_LIBS"

			if test "x$cf_test_ncuconfig" != xyes; then
				cf_temp=`echo "x$cf_pkg_cflags" | sed -e s/^x// -e 's/-W[[^ 	]]*//g'`
				cf_pkg_cflags="$cf_temp"
				cf_temp=`echo "x$cf_pkg_libs" | sed -e s/^x// -e 's/-W[[^ 	]]*//g'`
				cf_pkg_libs="$cf_temp"
			fi
			;;
		esac

		CF_REQUIRE_PKG($cf_ncuconfig_root)
		CF_APPEND_CFLAGS($cf_pkg_cflags)
		CF_ADD_LIBS($cf_pkg_libs)

		AC_TRY_LINK([#include <${cf_cv_ncurses_header:-curses.h}>],
			[initscr(); mousemask(0,0); tigetstr((char *)0);],
			[AC_TRY_RUN([#include <${cf_cv_ncurses_header:-curses.h}>
				int main(void)
				{ const char *xx = curses_version(); return (xx == 0); }],
				[cf_have_ncuconfig=yes],
				[cf_have_ncuconfig=no],
				[cf_have_ncuconfig=maybe])],
			[cf_have_ncuconfig=no])
		AC_MSG_RESULT($cf_have_ncuconfig)
		test "$cf_have_ncuconfig" = maybe && cf_have_ncuconfig=yes
		if test "$cf_have_ncuconfig" != "yes"
		then
			CPPFLAGS="$cf_save_CPPFLAGS"
			LIBS="$cf_save_LIBS"
			NCURSES_CONFIG_PKG=none
		else
			AC_DEFINE(NCURSES,1,[Define to 1 if we are using ncurses headers/libraries])
			NCURSES_CONFIG_PKG=$cf_ncuconfig_root
			CF_TERM_HEADER
		fi

	else
		AC_MSG_RESULT(no)
		NCURSES_CONFIG_PKG=none
	fi
else
	NCURSES_CONFIG_PKG=none
fi

if test "x$cf_have_ncuconfig" = "xno"; then
	cf_ncurses_config="${cf_ncuconfig_root}${NCURSES_CONFIG_SUFFIX}-config"; echo "Looking for ${cf_ncurses_config}"

	CF_ACVERSION_CHECK(2.52,
		[AC_CHECK_TOOLS(NCURSES_CONFIG, ${cf_ncurses_config} ${cf_ncuconfig_root}6-config ${cf_ncuconfig_root}6-config ${cf_ncuconfig_root}5-config, none)],
		[AC_PATH_PROGS(NCURSES_CONFIG,  ${cf_ncurses_config} ${cf_ncuconfig_root}6-config ${cf_ncuconfig_root}6-config ${cf_ncuconfig_root}5-config, none)])

	if test "$NCURSES_CONFIG" != none ; then

		CF_APPEND_CFLAGS(`$NCURSES_CONFIG --cflags`)
		CF_ADD_LIBS(`$NCURSES_CONFIG --libs`)

		# even with config script, some packages use no-override for curses.h
		CF_CURSES_HEADER(ifelse($1,,ncurses,$1))

		dnl like CF_NCURSES_CPPFLAGS
		AC_DEFINE(NCURSES,1,[Define to 1 if we are using ncurses headers/libraries])

		dnl like CF_NCURSES_LIBS
		CF_UPPER(cf_nculib_ROOT,HAVE_LIB$cf_ncuconfig_root)
		AC_DEFINE_UNQUOTED($cf_nculib_ROOT)

		dnl like CF_NCURSES_VERSION
		cf_cv_ncurses_version="`$NCURSES_CONFIG --version`"

	else

		CF_NCURSES_CPPFLAGS(ifelse($1,,ncurses,$1))
		CF_NCURSES_LIBS(ifelse($1,,ncurses,$1))

	fi
else
	NCURSES_CONFIG=none
fi
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_NCURSES_CPPFLAGS version: 22 updated: 2021/01/02 09:31:20
dnl -------------------
dnl Look for the SVr4 curses clone 'ncurses' in the standard places, adjusting
dnl the CPPFLAGS variable so we can include its header.
dnl
dnl The header files may be installed as either curses.h, or ncurses.h (would
dnl be obsolete, except that some packagers prefer this name to distinguish it
dnl from a "native" curses implementation).  If not installed for overwrite,
dnl the curses.h file would be in an ncurses subdirectory (e.g.,
dnl /usr/include/ncurses), but someone may have installed overwriting the
dnl vendor's curses.  Only very old versions (pre-1.9.2d, the first autoconf'd
dnl version) of ncurses don't define either __NCURSES_H or NCURSES_VERSION in
dnl the header.
dnl
dnl If the installer has set $CFLAGS or $CPPFLAGS so that the ncurses header
dnl is already in the include-path, don't even bother with this, since we cannot
dnl easily determine which file it is.  In this case, it has to be <curses.h>.
dnl
dnl The optional parameter gives the root name of the library, in case it is
dnl not installed as the default curses library.  That is how the
dnl wide-character version of ncurses is installed.
AC_DEFUN([CF_NCURSES_CPPFLAGS],
[AC_REQUIRE([CF_WITH_CURSES_DIR])

AC_PROVIDE([CF_CURSES_CPPFLAGS])dnl
cf_ncuhdr_root=ifelse($1,,ncurses,$1)

test -n "$cf_cv_curses_dir" && \
test "$cf_cv_curses_dir" != "no" && { \
  CF_ADD_INCDIR($cf_cv_curses_dir/include/$cf_ncuhdr_root)
}

AC_CACHE_CHECK(for $cf_ncuhdr_root header in include-path, cf_cv_ncurses_h,[
	cf_header_list="$cf_ncuhdr_root/curses.h $cf_ncuhdr_root/ncurses.h"
	{ test "$cf_ncuhdr_root" = ncurses || test "$cf_ncuhdr_root" = ncursesw; } && cf_header_list="$cf_header_list curses.h ncurses.h"
	for cf_header in $cf_header_list
	do
		CF_NCURSES_CC_CHECK(cf_cv_ncurses_h,$cf_header,$1)
		test "$cf_cv_ncurses_h" != no && break
	done
])

CF_NCURSES_HEADER
CF_TERM_HEADER

# some applications need this, but should check for NCURSES_VERSION
AC_DEFINE(NCURSES,1,[Define to 1 if we are using ncurses headers/libraries])

CF_NCURSES_VERSION
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_NCURSES_HEADER version: 7 updated: 2021/01/04 19:33:05
dnl -----------------
dnl Find a "curses" header file, e.g,. "curses.h", or one of the more common
dnl variations of ncurses' installs.
dnl
dnl See also CF_CURSES_HEADER, which sets the same cache variable.
AC_DEFUN([CF_NCURSES_HEADER],[

if test "$cf_cv_ncurses_h" != no ; then
	cf_cv_ncurses_header=$cf_cv_ncurses_h
else

AC_CACHE_CHECK(for $cf_ncuhdr_root include-path, cf_cv_ncurses_h2,[
	test -n "$verbose" && echo
	CF_HEADER_PATH(cf_search,$cf_ncuhdr_root)
	test -n "$verbose" && echo "search path $cf_search"
	cf_save2_CPPFLAGS="$CPPFLAGS"
	for cf_incdir in $cf_search
	do
		CF_ADD_INCDIR($cf_incdir)
		for cf_header in \
			ncurses.h \
			curses.h
		do
			CF_NCURSES_CC_CHECK(cf_cv_ncurses_h2,$cf_header,$1)
			if test "$cf_cv_ncurses_h2" != no ; then
				cf_cv_ncurses_h2=$cf_incdir/$cf_header
				test -n "$verbose" && echo $ECHO_N "	... found $ECHO_C" 1>&AC_FD_MSG
				break
			fi
			test -n "$verbose" && echo "	... tested $cf_incdir/$cf_header" 1>&AC_FD_MSG
		done
		CPPFLAGS="$cf_save2_CPPFLAGS"
		test "$cf_cv_ncurses_h2" != no && break
	done
	test "$cf_cv_ncurses_h2" = no && AC_MSG_ERROR(not found)
	])

	CF_DIRNAME(cf_1st_incdir,$cf_cv_ncurses_h2)
	cf_cv_ncurses_header="`basename "$cf_cv_ncurses_h2"`"
	if test "`basename "$cf_1st_incdir"`" = "$cf_ncuhdr_root" ; then
		cf_cv_ncurses_header="$cf_ncuhdr_root/$cf_cv_ncurses_header"
	fi
	CF_ADD_INCDIR($cf_1st_incdir)

fi

# Set definitions to allow ifdef'ing for ncurses.h

case "$cf_cv_ncurses_header" in
(*ncurses.h)
	AC_DEFINE(HAVE_NCURSES_H,1,[Define to 1 if we have ncurses.h])
	;;
esac

case "$cf_cv_ncurses_header" in
(ncurses/curses.h|ncurses/ncurses.h)
	AC_DEFINE(HAVE_NCURSES_NCURSES_H,1,[Define to 1 if we have ncurses/ncurses.h])
	;;
(ncursesw/curses.h|ncursesw/ncurses.h)
	AC_DEFINE(HAVE_NCURSESW_NCURSES_H,1,[Define to 1 if we have ncursesw/ncurses.h])
	;;
esac

])dnl
dnl ---------------------------------------------------------------------------
dnl CF_NCURSES_LIBS version: 21 updated: 2021/09/04 06:37:12
dnl ---------------
dnl Look for the ncurses library.  This is a little complicated on Linux,
dnl because it may be linked with the gpm (general purpose mouse) library.
dnl Some distributions have gpm linked with (bsd) curses, which makes it
dnl unusable with ncurses.  However, we don't want to link with gpm unless
dnl ncurses has a dependency, since gpm is normally set up as a shared library,
dnl and the linker will record a dependency.
dnl
dnl The optional parameter gives the root name of the library, in case it is
dnl not installed as the default curses library.  That is how the
dnl wide-character version of ncurses is installed.
AC_DEFUN([CF_NCURSES_LIBS],
[AC_REQUIRE([CF_NCURSES_CPPFLAGS])

cf_nculib_root=ifelse($1,,ncurses,$1)
	# This works, except for the special case where we find gpm, but
	# ncurses is in a nonstandard location via $LIBS, and we really want
	# to link gpm.
cf_ncurses_LIBS=""
cf_ncurses_SAVE="$LIBS"
AC_CHECK_LIB(gpm,Gpm_Open,
	[AC_CHECK_LIB(gpm,initscr,
		[LIBS="$cf_ncurses_SAVE"],
		[cf_ncurses_LIBS="-lgpm"])])

case "$host_os" in
(freebsd*)
	# This is only necessary if you are linking against an obsolete
	# version of ncurses (but it should do no harm, since it is static).
	if test "$cf_nculib_root" = ncurses ; then
		AC_CHECK_LIB(mytinfo,tgoto,[cf_ncurses_LIBS="-lmytinfo $cf_ncurses_LIBS"])
	fi
	;;
esac

CF_ADD_LIBS($cf_ncurses_LIBS)

if test -n "$cf_cv_curses_dir" && test "$cf_cv_curses_dir" != "no"
then
	CF_ADD_LIBS(-l$cf_nculib_root)
else
	CF_FIND_LIBRARY($cf_nculib_root,$cf_nculib_root,
		[#include <${cf_cv_ncurses_header:-curses.h}>],
		[initscr()],
		initscr)
fi

if test -n "$cf_ncurses_LIBS" ; then
	AC_MSG_CHECKING(if we can link $cf_nculib_root without $cf_ncurses_LIBS)
	cf_ncurses_SAVE="$LIBS"
	for p in $cf_ncurses_LIBS ; do
		q=`echo "$LIBS" | sed -e "s%$p %%" -e "s%$p$%%"`
		if test "$q" != "$LIBS" ; then
			LIBS="$q"
		fi
	done
	AC_TRY_LINK([#include <${cf_cv_ncurses_header:-curses.h}>],
		[initscr(); mousemask(0,0); tigetstr((char *)0);],
		[AC_MSG_RESULT(yes)],
		[AC_MSG_RESULT(no)
		 LIBS="$cf_ncurses_SAVE"])
fi

CF_UPPER(cf_nculib_ROOT,HAVE_LIB$cf_nculib_root)
AC_DEFINE_UNQUOTED($cf_nculib_ROOT)
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_NCURSES_VERSION version: 18 updated: 2024/01/07 06:34:16
dnl ------------------
dnl Check for the version of ncurses, to aid in reporting bugs, etc.
dnl Call CF_CURSES_CPPFLAGS first, or CF_NCURSES_CPPFLAGS.  We don't use
dnl AC_REQUIRE since that does not work with the shell's if/then/else/fi.
AC_DEFUN([CF_NCURSES_VERSION],
[
AC_REQUIRE([CF_CURSES_CPPFLAGS])dnl
AC_CACHE_CHECK(for ncurses version, cf_cv_ncurses_version,[
	cf_cv_ncurses_version=no
	cf_tempfile=out$$
	rm -f "$cf_tempfile"
	AC_TRY_RUN([
$ac_includes_default

#include <${cf_cv_ncurses_header:-curses.h}>

int main(void)
{
	FILE *fp = fopen("$cf_tempfile", "w");
#ifdef NCURSES_VERSION
# ifdef NCURSES_VERSION_PATCH
	fprintf(fp, "%s.%d\\n", NCURSES_VERSION, NCURSES_VERSION_PATCH);
# else
	fprintf(fp, "%s\\n", NCURSES_VERSION);
# endif
#else
# ifdef __NCURSES_H
	fprintf(fp, "old\\n");
# else
	#error expected ncurses header to define __NCURSES_H
# endif
#endif
	${cf_cv_main_return:-return}(0);
}],[
	cf_cv_ncurses_version=`cat $cf_tempfile`],,[

	# This will not work if the preprocessor splits the line after the
	# Autoconf token.  The 'unproto' program does that.
	cat > "conftest.$ac_ext" <<EOF
#include <${cf_cv_ncurses_header:-curses.h}>
#undef Autoconf
#ifdef NCURSES_VERSION
Autoconf NCURSES_VERSION
#else
#ifdef __NCURSES_H
Autoconf "old"
#endif
;
#endif
EOF
	cf_try="$ac_cpp conftest.$ac_ext 2>&AC_FD_CC | grep '^Autoconf ' >conftest.out"
	AC_TRY_EVAL(cf_try)
	if test -f conftest.out ; then
		cf_out=`sed -e 's%^Autoconf %%' -e 's%^[[^"]]*"%%' -e 's%".*%%' conftest.out`
		test -n "$cf_out" && cf_cv_ncurses_version="$cf_out"
		rm -f conftest.out
	fi
])
	rm -f "$cf_tempfile"
])
test "$cf_cv_ncurses_version" = no || AC_DEFINE(NCURSES,1,[Define to 1 if we are using ncurses headers/libraries])
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_NO_LEAKS_OPTION version: 9 updated: 2021/06/13 19:45:41
dnl ------------------
dnl see CF_WITH_NO_LEAKS
dnl
dnl $1 = option/name
dnl $2 = help-text
dnl $3 = symbol to define if the option is set
dnl $4 = additional actions to take if the option is set
AC_DEFUN([CF_NO_LEAKS_OPTION],[
AC_MSG_CHECKING(if you want to use $1 for testing)
AC_ARG_WITH($1,
	[$2],
	[case "x$withval" in
	(x|xno) ;;
	(*)
		: "${with_cflags:=-g}"
		: "${enable_leaks:=no}"
		with_$1=yes
		AC_DEFINE_UNQUOTED($3,1,"Define to 1 if you want to use $1 for testing.")ifelse([$4],,[
	 $4
])
		;;
	esac],
	[with_$1=])
AC_MSG_RESULT(${with_$1:-no})

case ".$with_cflags" in
(.*-g*)
	case .$CFLAGS in
	(.*-g*)
		;;
	(*)
		CF_ADD_CFLAGS([-g])
		;;
	esac
	;;
esac
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_PATH_SYNTAX version: 19 updated: 2024/08/03 13:08:58
dnl --------------
dnl Check the argument to see that it looks like a pathname.  Rewrite it if it
dnl begins with one of the prefix/exec_prefix variables, and then again if the
dnl result begins with 'NONE'.  This is necessary to work around autoconf's
dnl delayed evaluation of those symbols.
AC_DEFUN([CF_PATH_SYNTAX],[
AC_REQUIRE([CF_GLOB_FULLPATH])dnl

if test "x$prefix" != xNONE; then
	cf_path_syntax="$prefix"
else
	cf_path_syntax="$ac_default_prefix"
fi

case "x[$]$1" in
(x\[$]\(*\)*|x\'*\'*)
	;;
(x.|x$GLOB_FULLPATH_POSIX|x$GLOB_FULLPATH_OTHER)
	;;
(x\[$]\{*prefix\}*|x\[$]\{*dir\}*)
	eval $1="[$]$1"
	case "x[$]$1" in
	(xNONE/*)
		$1=`echo "[$]$1" | sed -e s%NONE%$cf_path_syntax%`
		;;
	esac
	;;
(xno|xNONE/*)
	$1=`echo "[$]$1" | sed -e s%NONE%$cf_path_syntax%`
	;;
(*)
	ifelse([$2],,[AC_MSG_ERROR([expected a pathname, not \"[$]$1\"])],$2)
	;;
esac
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_PKG_CONFIG version: 13 updated: 2023/10/28 11:59:01
dnl -------------
dnl Check for the package-config program, unless disabled by command-line.
dnl
dnl Sets $PKG_CONFIG to the pathname of the pkg-config program.
AC_DEFUN([CF_PKG_CONFIG],
[
AC_MSG_CHECKING(if you want to use pkg-config)
AC_ARG_WITH(pkg-config,
	[[  --with-pkg-config[=CMD] enable/disable use of pkg-config and its name CMD]],
	[cf_pkg_config=$withval],
	[cf_pkg_config=yes])
AC_MSG_RESULT($cf_pkg_config)

case "$cf_pkg_config" in
(no)
	PKG_CONFIG=none
	;;
(yes)
	CF_ACVERSION_CHECK(2.52,
		[AC_PATH_TOOL(PKG_CONFIG, pkg-config, none)],
		[AC_PATH_PROG(PKG_CONFIG, pkg-config, none)])
	;;
(*)
	PKG_CONFIG=$withval
	;;
esac

test -z "$PKG_CONFIG" && PKG_CONFIG=none
if test "$PKG_CONFIG" != none ; then
	CF_PATH_SYNTAX(PKG_CONFIG)
elif test "x$cf_pkg_config" != xno ; then
	AC_MSG_WARN(pkg-config is not installed)
fi

AC_SUBST(PKG_CONFIG)
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_POSIX_C_SOURCE version: 12 updated: 2023/02/18 17:41:25
dnl -----------------
dnl Define _POSIX_C_SOURCE to the given level, and _POSIX_SOURCE if needed.
dnl
dnl	POSIX.1-1990				_POSIX_SOURCE
dnl	POSIX.1-1990 and			_POSIX_SOURCE and
dnl		POSIX.2-1992 C-Language			_POSIX_C_SOURCE=2
dnl		Bindings Option
dnl	POSIX.1b-1993				_POSIX_C_SOURCE=199309L
dnl	POSIX.1c-1996				_POSIX_C_SOURCE=199506L
dnl	X/Open 2000				_POSIX_C_SOURCE=200112L
dnl
dnl Parameters:
dnl	$1 is the nominal value for _POSIX_C_SOURCE
AC_DEFUN([CF_POSIX_C_SOURCE],
[AC_REQUIRE([CF_POSIX_VISIBLE])dnl

if test "$cf_cv_posix_visible" = no; then

cf_POSIX_C_SOURCE=ifelse([$1],,199506L,[$1])

cf_save_CFLAGS="$CFLAGS"
cf_save_CPPFLAGS="$CPPFLAGS"

CF_REMOVE_DEFINE(cf_trim_CFLAGS,$cf_save_CFLAGS,_POSIX_C_SOURCE)
CF_REMOVE_DEFINE(cf_trim_CPPFLAGS,$cf_save_CPPFLAGS,_POSIX_C_SOURCE)

AC_CACHE_CHECK(if we should define _POSIX_C_SOURCE,cf_cv_posix_c_source,[
	CF_MSG_LOG(if the symbol is already defined go no further)
	AC_TRY_COMPILE([#include <sys/types.h>],[
#ifndef _POSIX_C_SOURCE
#error _POSIX_C_SOURCE is not defined
#endif],
	[cf_cv_posix_c_source=no],
	[cf_want_posix_source=no
	 case .$cf_POSIX_C_SOURCE in
	 (.[[12]]??*)
		cf_cv_posix_c_source="-D_POSIX_C_SOURCE=$cf_POSIX_C_SOURCE"
		;;
	 (.2)
		cf_cv_posix_c_source="-D_POSIX_C_SOURCE=$cf_POSIX_C_SOURCE"
		cf_want_posix_source=yes
		;;
	 (.*)
		cf_want_posix_source=yes
		;;
	 esac
	 if test "$cf_want_posix_source" = yes ; then
		AC_TRY_COMPILE([#include <sys/types.h>],[
#ifdef _POSIX_SOURCE
#error _POSIX_SOURCE is defined
#endif],[],
		cf_cv_posix_c_source="$cf_cv_posix_c_source -D_POSIX_SOURCE")
	 fi
	 CF_MSG_LOG(ifdef from value $cf_POSIX_C_SOURCE)
	 CFLAGS="$cf_trim_CFLAGS"
	 CPPFLAGS="$cf_trim_CPPFLAGS"
	 CF_APPEND_TEXT(CPPFLAGS,$cf_cv_posix_c_source)
	 CF_MSG_LOG(if the second compile does not leave our definition intact error)
	 AC_TRY_COMPILE([#include <sys/types.h>],[
#ifndef _POSIX_C_SOURCE
#error _POSIX_C_SOURCE is not defined
#endif],,
	 [cf_cv_posix_c_source=no])
	 CFLAGS="$cf_save_CFLAGS"
	 CPPFLAGS="$cf_save_CPPFLAGS"
	])
])

if test "$cf_cv_posix_c_source" != no ; then
	CFLAGS="$cf_trim_CFLAGS"
	CPPFLAGS="$cf_trim_CPPFLAGS"
	CF_ADD_CFLAGS($cf_cv_posix_c_source)
fi

fi # cf_cv_posix_visible

])dnl
dnl ---------------------------------------------------------------------------
dnl CF_POSIX_VISIBLE version: 1 updated: 2018/12/31 20:46:17
dnl ----------------
dnl POSIX documents test-macros which an application may set before any system
dnl headers are included to make features available.
dnl
dnl Some BSD platforms (originally FreeBSD, but copied by a few others)
dnl diverged from POSIX in 2002 by setting symbols which make all of the most
dnl recent features visible in the system header files unless the application
dnl overrides the corresponding test-macros.  Doing that introduces portability
dnl problems.
dnl
dnl This macro makes a special check for the symbols used for this, to avoid a
dnl conflicting definition.
AC_DEFUN([CF_POSIX_VISIBLE],
[
AC_CACHE_CHECK(if the POSIX test-macros are already defined,cf_cv_posix_visible,[
AC_TRY_COMPILE([#include <stdio.h>],[
#if defined(__POSIX_VISIBLE) && ((__POSIX_VISIBLE - 0L) > 0) \
	&& defined(__XSI_VISIBLE) && ((__XSI_VISIBLE - 0L) > 0) \
	&& defined(__BSD_VISIBLE) && ((__BSD_VISIBLE - 0L) > 0) \
	&& defined(__ISO_C_VISIBLE) && ((__ISO_C_VISIBLE - 0L) > 0)
#error conflicting symbols found
#endif
],[cf_cv_posix_visible=no],[cf_cv_posix_visible=yes])
])
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_PROG_CC version: 5 updated: 2019/12/31 08:53:54
dnl ----------
dnl standard check for CC, plus followup sanity checks
dnl $1 = optional parameter to pass to AC_PROG_CC to specify compiler name
AC_DEFUN([CF_PROG_CC],[
CF_ACVERSION_CHECK(2.53,
	[AC_MSG_WARN(this will incorrectly handle gnatgcc choice)
	 AC_REQUIRE([AC_PROG_CC])],
	[])
ifelse($1,,[AC_PROG_CC],[AC_PROG_CC($1)])
CF_GCC_VERSION
CF_ACVERSION_CHECK(2.52,
	[AC_PROG_CC_STDC],
	[CF_ANSI_CC_REQD])
CF_CC_ENV_FLAGS
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_PROG_EXT version: 15 updated: 2021/01/02 09:31:20
dnl -----------
dnl Compute $PROG_EXT, used for non-Unix ports, such as OS/2 EMX.
AC_DEFUN([CF_PROG_EXT],
[
AC_REQUIRE([CF_CHECK_CACHE])
case "$cf_cv_system_name" in
(os2*)
	CFLAGS="$CFLAGS -Zmt"
	CF_APPEND_TEXT(CPPFLAGS,-D__ST_MT_ERRNO__)
	CXXFLAGS="$CXXFLAGS -Zmt"
	# autoconf's macro sets -Zexe and suffix both, which conflict:w
	LDFLAGS="$LDFLAGS -Zmt -Zcrtdll"
	ac_cv_exeext=.exe
	;;
esac

AC_EXEEXT
AC_OBJEXT

PROG_EXT="$EXEEXT"
AC_SUBST(PROG_EXT)
test -n "$PROG_EXT" && AC_DEFINE_UNQUOTED(PROG_EXT,"$PROG_EXT",[Define to the program extension (normally blank)])
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_PROG_GROFF version: 3 updated: 2018/01/07 13:16:19
dnl -------------
dnl Check if groff is available, for cases (such as html output) where nroff
dnl is not enough.
AC_DEFUN([CF_PROG_GROFF],[
AC_PATH_PROG(GROFF_PATH,groff,no)
AC_PATH_PROGS(NROFF_PATH,nroff mandoc,no)
AC_PATH_PROG(TBL_PATH,tbl,cat)
if test "x$GROFF_PATH" = xno
then
	NROFF_NOTE=
	GROFF_NOTE="#"
else
	NROFF_NOTE="#"
	GROFF_NOTE=
fi
AC_SUBST(GROFF_NOTE)
AC_SUBST(NROFF_NOTE)
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_PROG_LINT version: 7 updated: 2024/11/30 14:37:45
dnl ------------
AC_DEFUN([CF_PROG_LINT],
[
AC_CHECK_PROGS(LINT, lint cppcheck splint)
case "x$LINT" in
(xlint|x*/lint) # NetBSD 10
	test -z "$LINT_OPTS" && LINT_OPTS="-chapbrxzgFS -v -Ac11"
	;;
(xcppcheck|x*/cppcheck)
	test -z "$LINT_OPTS" && LINT_OPTS="--enable=all -D__CPPCHECK__"
	;;
esac
AC_SUBST(LINT_OPTS)
AC_SUBST(LINT_LIBS)
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_REMOVE_CFLAGS version: 3 updated: 2021/09/05 17:25:40
dnl ----------------
dnl Remove a given option from CFLAGS/CPPFLAGS
dnl $1 = option to remove
dnl $2 = variable to update
dnl $3 = nonempty to allow verbose message
define([CF_REMOVE_CFLAGS],
[
cf_tmp_cflag=`echo "x$1" | sed -e 's/^.//' -e 's/=.*//'`
while true
do
	cf_old_cflag=`echo "x[$]$2" | sed -e 's/^.//' -e 's/[[ 	]][[ 	]]*-/ -/g' -e "s%$cf_tmp_cflag\\(=[[^ 	]][[^ 	]]*\\)\?%%" -e 's/^[[ 	]]*//' -e 's%[[ ]][[ ]]*-D% -D%g' -e 's%[[ ]][[ ]]*-I% -I%g'`
	test "[$]$2" != "$cf_old_cflag" || break
	ifelse([$3],,,[CF_VERBOSE(removing old option $1 from $2)])
	$2="$cf_old_cflag"
done
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_REMOVE_DEFINE version: 3 updated: 2010/01/09 11:05:50
dnl ----------------
dnl Remove all -U and -D options that refer to the given symbol from a list
dnl of C compiler options.  This works around the problem that not all
dnl compilers process -U and -D options from left-to-right, so a -U option
dnl cannot be used to cancel the effect of a preceding -D option.
dnl
dnl $1 = target (which could be the same as the source variable)
dnl $2 = source (including '$')
dnl $3 = symbol to remove
define([CF_REMOVE_DEFINE],
[
$1=`echo "$2" | \
	sed	-e 's/-[[UD]]'"$3"'\(=[[^ 	]]*\)\?[[ 	]]/ /g' \
		-e 's/-[[UD]]'"$3"'\(=[[^ 	]]*\)\?[$]//g'`
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_REQUIRE_PKG version: 1 updated: 2025/01/10 19:55:54
dnl --------------
dnl Update $REQUIRE_PKG, which lists the known required packages for this
dnl program.
dnl
dnl $1 = package(s) to require, e.g., in the generated ".pc" file
define([CF_REQUIRE_PKG],
[
for cf_required in $1
do
	# check for duplicates
	for cf_require_pkg in $REQUIRE_PKG
	do
		if test "$cf_required" = "$cf_require_pkg"
		then
			cf_required=
			break
		fi
	done
	test -n "$cf_required" && REQUIRE_PKG="$REQUIRE_PKG $cf_required"
done
AC_SUBST(REQUIRE_PKG)
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_RPATH_HACK version: 13 updated: 2021/01/03 18:30:50
dnl -------------
AC_DEFUN([CF_RPATH_HACK],
[AC_REQUIRE([AC_PROG_FGREP])dnl
AC_REQUIRE([CF_LD_RPATH_OPT])dnl

AC_MSG_CHECKING(for updated LDFLAGS)
if test -n "$LD_RPATH_OPT" ; then
	AC_MSG_RESULT(maybe)

	AC_CHECK_PROGS(cf_ldd_prog,ldd,no)
	cf_rpath_list="/usr/lib /lib"
	if test "$cf_ldd_prog" != no
	then
		cf_rpath_oops=

AC_TRY_LINK([#include <stdio.h>],
		[printf("Hello");],
		[cf_rpath_oops=`"$cf_ldd_prog" "conftest$ac_exeext" | ${FGREP-fgrep} ' not found' | sed -e 's% =>.*$%%' |sort | uniq`
		 cf_rpath_list=`"$cf_ldd_prog" "conftest$ac_exeext" | ${FGREP-fgrep} / | sed -e 's%^.*[[ 	]]/%/%' -e 's%/[[^/]][[^/]]*$%%' |sort | uniq`])

		# If we passed the link-test, but get a "not found" on a given library,
		# this could be due to inept reconfiguration of gcc to make it only
		# partly honor /usr/local/lib (or whatever).  Sometimes this behavior
		# is intentional, e.g., installing gcc in /usr/bin and suppressing the
		# /usr/local libraries.
		if test -n "$cf_rpath_oops"
		then
			for cf_rpath_src in $cf_rpath_oops
			do
				for cf_rpath_dir in \
					/usr/local \
					/usr/pkg \
					/opt/sfw
				do
					if test -f "$cf_rpath_dir/lib/$cf_rpath_src"
					then
						CF_VERBOSE(...adding -L$cf_rpath_dir/lib to LDFLAGS for $cf_rpath_src)
						LDFLAGS="$LDFLAGS -L$cf_rpath_dir/lib"
						break
					fi
				done
			done
		fi
	fi

	CF_VERBOSE(...checking EXTRA_LDFLAGS $EXTRA_LDFLAGS)

	CF_RPATH_HACK_2(LDFLAGS)
	CF_RPATH_HACK_2(LIBS)

	CF_VERBOSE(...checked EXTRA_LDFLAGS $EXTRA_LDFLAGS)
else
	AC_MSG_RESULT(no)
fi
AC_SUBST(EXTRA_LDFLAGS)
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_RPATH_HACK_2 version: 8 updated: 2021/01/01 13:31:04
dnl ---------------
dnl Do one set of substitutions for CF_RPATH_HACK, adding an rpath option to
dnl EXTRA_LDFLAGS for each -L option found.
dnl
dnl $cf_rpath_list contains a list of directories to ignore.
dnl
dnl $1 = variable name to update.  The LDFLAGS variable should be the only one,
dnl      but LIBS often has misplaced -L options.
AC_DEFUN([CF_RPATH_HACK_2],
[
CF_VERBOSE(...checking $1 [$]$1)

cf_rpath_dst=
for cf_rpath_src in [$]$1
do
	case "$cf_rpath_src" in
	(-L*)

		# check if this refers to a directory which we will ignore
		cf_rpath_skip=no
		if test -n "$cf_rpath_list"
		then
			for cf_rpath_item in $cf_rpath_list
			do
				if test "x$cf_rpath_src" = "x-L$cf_rpath_item"
				then
					cf_rpath_skip=yes
					break
				fi
			done
		fi

		if test "$cf_rpath_skip" = no
		then
			# transform the option
			if test "$LD_RPATH_OPT" = "-R " ; then
				cf_rpath_tmp=`echo "$cf_rpath_src" |sed -e "s%-L%-R %"`
			else
				cf_rpath_tmp=`echo "$cf_rpath_src" |sed -e "s%-L%$LD_RPATH_OPT%"`
			fi

			# if we have not already added this, add it now
			cf_rpath_tst=`echo "$EXTRA_LDFLAGS" | sed -e "s%$cf_rpath_tmp %%"`
			if test "x$cf_rpath_tst" = "x$EXTRA_LDFLAGS"
			then
				CF_VERBOSE(...Filter $cf_rpath_src ->$cf_rpath_tmp)
				EXTRA_LDFLAGS="$cf_rpath_tmp $EXTRA_LDFLAGS"
			fi
		fi
		;;
	esac
	cf_rpath_dst="$cf_rpath_dst $cf_rpath_src"
done
$1=$cf_rpath_dst

CF_VERBOSE(...checked $1 [$]$1)
AC_SUBST(EXTRA_LDFLAGS)
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_SUBDIR_PATH version: 7 updated: 2014/12/04 04:33:06
dnl --------------
dnl Construct a search-list for a nonstandard header/lib-file
dnl	$1 = the variable to return as result
dnl	$2 = the package name
dnl	$3 = the subdirectory, e.g., bin, include or lib
AC_DEFUN([CF_SUBDIR_PATH],
[
$1=

CF_ADD_SUBDIR_PATH($1,$2,$3,$prefix,NONE)

for cf_subdir_prefix in \
	/usr \
	/usr/local \
	/usr/pkg \
	/opt \
	/opt/local \
	[$]HOME
do
	CF_ADD_SUBDIR_PATH($1,$2,$3,$cf_subdir_prefix,$prefix)
done
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_TERMCAP_LIBS version: 18 updated: 2023/01/14 07:19:05
dnl ---------------
dnl Look for termcap libraries, or the equivalent in terminfo.
dnl
dnl The optional parameter may be "ncurses", "ncursesw".
AC_DEFUN([CF_TERMCAP_LIBS],
[
AC_CACHE_VAL(cf_cv_termlib,[
cf_cv_termlib=none
AC_TRY_LINK(
	[extern char *tgoto(const char*,int,int);],
	[char *x=tgoto("",0,0); (void)x;],
[AC_TRY_LINK(
	[extern char *tigetstr(const char *);],
	[char *x=tigetstr(""); (void)x;],
	[cf_cv_termlib=terminfo],
	[cf_cv_termlib=termcap])
	CF_VERBOSE(using functions in predefined $cf_cv_termlib LIBS)
],[
ifelse([$1],,,[
case "$1" in
(ncurses*)
	CF_NCURSES_CONFIG($1)
	cf_cv_termlib=terminfo
	;;
esac
])
if test "$cf_cv_termlib" = none; then
	# FreeBSD's linker gives bogus results for AC_CHECK_LIB, saying that
	# tgetstr lives in -lcurses when it is only an unsatisfied extern.
	cf_save_LIBS="$LIBS"
	for cf_lib in tinfo curses ncurses termlib termcap
	do
		LIBS="-l$cf_lib $cf_save_LIBS"
		for cf_func in tigetstr tgetstr
		do
			AC_MSG_CHECKING(for $cf_func in -l$cf_lib)
			AC_TRY_LINK(
				[extern char *$cf_func(const char *);],
				[char *x = $cf_func(""); (void)x],
				[cf_result=yes],
				[cf_result=no])
			AC_MSG_RESULT($cf_result)
			if test "$cf_result" = yes ; then
				if test "$cf_func" = tigetstr ; then
					cf_cv_termlib=terminfo
				else
					cf_cv_termlib=termcap
				fi
				break
			fi
		done
		test "$cf_result" = yes && break
	done
	test "$cf_result" = no && LIBS="$cf_save_LIBS"
fi
if test "$cf_cv_termlib" = none; then
	# allow curses library for broken AIX system.
	AC_CHECK_LIB(curses, initscr, [CF_ADD_LIBS(-lcurses)])
	AC_CHECK_LIB(termcap, tgoto, [CF_ADD_LIBS(-ltermcap) cf_cv_termlib=termcap])
fi
])
if test "$cf_cv_termlib" = none; then
	AC_MSG_WARN([Cannot find -ltermlib, -lcurses, or -ltermcap])
fi
])])dnl
dnl ---------------------------------------------------------------------------
dnl CF_TERM_HEADER version: 6 updated: 2021/01/02 09:31:20
dnl --------------
dnl Look for term.h, which is part of X/Open curses.  It defines the interface
dnl to terminfo database.  Usually it is in the same include-path as curses.h,
dnl but some packagers change this, breaking various applications.
AC_DEFUN([CF_TERM_HEADER],[
AC_CACHE_CHECK(for terminfo header, cf_cv_term_header,[
case "${cf_cv_ncurses_header}" in
(*/ncurses.h|*/ncursesw.h)
	cf_term_header=`echo "$cf_cv_ncurses_header" | sed -e 's%ncurses[[^.]]*\.h$%term.h%'`
	;;
(*)
	cf_term_header=term.h
	;;
esac

for cf_test in $cf_term_header "ncurses/term.h" "ncursesw/term.h"
do
AC_TRY_COMPILE([#include <stdio.h>
#include <${cf_cv_ncurses_header:-curses.h}>
#include <$cf_test>
],[int x = auto_left_margin; (void)x],[
	cf_cv_term_header="$cf_test"],[
	cf_cv_term_header=unknown
	])
	test "$cf_cv_term_header" != unknown && break
done
])

# Set definitions to allow ifdef'ing to accommodate subdirectories

case "$cf_cv_term_header" in
(*term.h)
	AC_DEFINE(HAVE_TERM_H,1,[Define to 1 if we have term.h])
	;;
esac

case "$cf_cv_term_header" in
(ncurses/term.h)
	AC_DEFINE(HAVE_NCURSES_TERM_H,1,[Define to 1 if we have ncurses/term.h])
	;;
(ncursesw/term.h)
	AC_DEFINE(HAVE_NCURSESW_TERM_H,1,[Define to 1 if we have ncursesw/term.h])
	;;
esac
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_TRY_XOPEN_SOURCE version: 4 updated: 2022/09/10 15:16:16
dnl -------------------
dnl If _XOPEN_SOURCE is not defined in the compile environment, check if we
dnl can define it successfully.
AC_DEFUN([CF_TRY_XOPEN_SOURCE],[
AC_CACHE_CHECK(if we should define _XOPEN_SOURCE,cf_cv_xopen_source,[
	AC_TRY_COMPILE(CF__XOPEN_SOURCE_HEAD,CF__XOPEN_SOURCE_BODY,
	[cf_cv_xopen_source=no],
	[cf_save="$CPPFLAGS"
	 CF_APPEND_TEXT(CPPFLAGS,-D_XOPEN_SOURCE=$cf_XOPEN_SOURCE)
	 AC_TRY_COMPILE(CF__XOPEN_SOURCE_HEAD,CF__XOPEN_SOURCE_BODY,
		[cf_cv_xopen_source=no],
		[cf_cv_xopen_source=$cf_XOPEN_SOURCE])
		CPPFLAGS="$cf_save"
	])
])

if test "$cf_cv_xopen_source" != no ; then
	CF_REMOVE_DEFINE(CFLAGS,$CFLAGS,_XOPEN_SOURCE)
	CF_REMOVE_DEFINE(CPPFLAGS,$CPPFLAGS,_XOPEN_SOURCE)
	cf_temp_xopen_source="-D_XOPEN_SOURCE=$cf_cv_xopen_source"
	CF_APPEND_CFLAGS($cf_temp_xopen_source)
fi
])
dnl ---------------------------------------------------------------------------
dnl CF_TYPE_OUTCHAR version: 16 updated: 2023/12/09 10:53:57
dnl ---------------
dnl Check for return and param type of 3rd -- OutChar() -- param of tputs().
dnl
dnl For this check, and for CF_CURSES_TERMCAP, the $CHECK_DECL_HDRS variable
dnl must point to a header file containing this (or equivalent):
dnl
dnl	#ifdef NEED_CURSES_H
dnl	# ifdef HAVE_NCURSES_NCURSES_H
dnl	#  include <ncurses/ncurses.h>
dnl	# else
dnl	#  ifdef HAVE_NCURSES_H
dnl	#   include <ncurses.h>
dnl	#  else
dnl	#   include <curses.h>
dnl	#  endif
dnl	# endif
dnl	#endif
dnl
dnl	#ifdef HAVE_NCURSES_TERM_H
dnl	#  include <ncurses/term.h>
dnl	#else
dnl	# ifdef HAVE_TERM_H
dnl	#  include <term.h>
dnl	# endif
dnl	#endif
dnl
dnl	#if NEED_TERMCAP_H
dnl	# include <termcap.h>
dnl	#endif
dnl
AC_DEFUN([CF_TYPE_OUTCHAR],
[
AC_REQUIRE([CF_CURSES_TERMCAP])

AC_CACHE_CHECK(declaration of tputs 3rd param, cf_cv_type_outchar,[

cf_cv_type_outchar="int OutChar(int)"
cf_cv_found=no
cf_save_CPPFLAGS="$CPPFLAGS"
CPPFLAGS="$CPPFLAGS $CHECK_DECL_FLAG"

for P in int void; do
for Q in int void; do
for R in int char; do
for S in "" const; do
	CF_MSG_LOG(loop variables [P:[$]P, Q:[$]Q, R:[$]R, S:[$]S])
	AC_TRY_COMPILE([$CHECK_DECL_HDRS
	extern $Q OutChar($R);
	extern $P tputs ($S char *string, int nlines, $Q (*_f)($R));
	static char fmt[] = "";],
	[tputs(fmt, 1, OutChar)],
	[cf_cv_type_outchar="$Q OutChar($R)"
	 cf_cv_found=yes
	 break])
done
	test $cf_cv_found = yes && break
done
	test $cf_cv_found = yes && break
done
	test $cf_cv_found = yes && break
done
])

case $cf_cv_type_outchar in
(int*)
	AC_DEFINE(OUTC_RETURN,1,[Define to 1 if tputs outc function returns a value])
	;;
esac
case $cf_cv_type_outchar in
(*char*)
	AC_DEFINE(OUTC_ARGS,char c,[Define to actual type to override tputs outc parameter type])
	;;
esac

CPPFLAGS="$cf_save_CPPFLAGS"
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_UPPER version: 5 updated: 2001/01/29 23:40:59
dnl --------
dnl Make an uppercase version of a variable
dnl $1=uppercase($2)
AC_DEFUN([CF_UPPER],
[
$1=`echo "$2" | sed y%abcdefghijklmnopqrstuvwxyz./-%ABCDEFGHIJKLMNOPQRSTUVWXYZ___%`
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_VERBOSE version: 3 updated: 2007/07/29 09:55:12
dnl ----------
dnl Use AC_VERBOSE w/o the warnings
AC_DEFUN([CF_VERBOSE],
[test -n "$verbose" && echo "	$1" 1>&AC_FD_MSG
CF_MSG_LOG([$1])
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_WITHOUT_X version: 3 updated: 2021/01/13 16:51:52
dnl ------------
dnl Use this to cancel the check for X headers/libraries which would be pulled
dnl in via CF_GCC_WARNINGS.
define([CF_WITHOUT_X],
AC_DEFUN([AC_PATH_XTRA],[])
AC_DEFUN([CF_SAVE_XTRA_FLAGS],[])
AC_DEFUN([CF_RESTORE_XTRA_FLAGS],[])
AC_DEFUN([CF_CONST_X_STRING],[echo "skipping X-const check";])dnl
AC_SUBST(X_CFLAGS)
AC_SUBST(X_LIBS)
[])dnl
dnl ---------------------------------------------------------------------------
dnl CF_WITH_CURSES_DIR version: 4 updated: 2021/01/02 19:22:58
dnl ------------------
dnl Wrapper for AC_ARG_WITH to specify directory under which to look for curses
dnl libraries.
AC_DEFUN([CF_WITH_CURSES_DIR],[

AC_MSG_CHECKING(for specific curses-directory)
AC_ARG_WITH(curses-dir,
	[  --with-curses-dir=DIR   directory in which (n)curses is installed],
	[cf_cv_curses_dir=$withval],
	[cf_cv_curses_dir=no])
AC_MSG_RESULT($cf_cv_curses_dir)

if test -n "$cf_cv_curses_dir" && test "$cf_cv_curses_dir" != "no"
then
	CF_PATH_SYNTAX(withval)
	if test -d "$cf_cv_curses_dir"
	then
		CF_ADD_INCDIR($cf_cv_curses_dir/include)
		CF_ADD_LIBDIR($cf_cv_curses_dir/lib)
	fi
fi
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_WITH_DBMALLOC version: 7 updated: 2010/06/21 17:26:47
dnl ----------------
dnl Configure-option for dbmalloc.  The optional parameter is used to override
dnl the updating of $LIBS, e.g., to avoid conflict with subsequent tests.
AC_DEFUN([CF_WITH_DBMALLOC],[
CF_NO_LEAKS_OPTION(dbmalloc,
	[  --with-dbmalloc         test: use Conor Cahill's dbmalloc library],
	[USE_DBMALLOC])

if test "$with_dbmalloc" = yes ; then
	AC_CHECK_HEADER(dbmalloc.h,
		[AC_CHECK_LIB(dbmalloc,[debug_malloc]ifelse([$1],,[],[,$1]))])
fi
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_WITH_DMALLOC version: 7 updated: 2010/06/21 17:26:47
dnl ---------------
dnl Configure-option for dmalloc.  The optional parameter is used to override
dnl the updating of $LIBS, e.g., to avoid conflict with subsequent tests.
AC_DEFUN([CF_WITH_DMALLOC],[
CF_NO_LEAKS_OPTION(dmalloc,
	[  --with-dmalloc          test: use Gray Watson's dmalloc library],
	[USE_DMALLOC])

if test "$with_dmalloc" = yes ; then
	AC_CHECK_HEADER(dmalloc.h,
		[AC_CHECK_LIB(dmalloc,[dmalloc_debug]ifelse([$1],,[],[,$1]))])
fi
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_WITH_MAN2HTML version: 14 updated: 2024/09/09 17:17:46
dnl ----------------
dnl Check for man2html and groff.  Prefer man2html over groff, but use groff
dnl as a fallback.  See
dnl
dnl		https://invisible-island.net/scripts/man2html.html
dnl
dnl Generate a shell script which hides the differences between the two.
dnl
dnl We name that "man2html.tmp".
dnl
dnl The shell script can be removed later, e.g., using "make distclean".
AC_DEFUN([CF_WITH_MAN2HTML],[
AC_REQUIRE([CF_PROG_GROFF])dnl
AC_REQUIRE([AC_PROG_FGREP])dnl

case "x${with_man2html}" in
(xno)
	cf_man2html=no
	;;
(x|xyes)
	AC_PATH_PROG(cf_man2html,man2html,no)
	case "x$cf_man2html" in
	(x/*)
		AC_MSG_CHECKING(for the modified Earl Hood script)
		if ( $cf_man2html -help 2>&1 | grep 'Make an index of headers at the end' >/dev/null )
		then
			cf_man2html_ok=yes
		else
			cf_man2html=no
			cf_man2html_ok=no
		fi
		AC_MSG_RESULT($cf_man2html_ok)
		;;
	(*)
		cf_man2html=no
		;;
	esac
esac

AC_MSG_CHECKING(for program to convert manpage to html)
AC_ARG_WITH(man2html,
	[[  --with-man2html[=XXX]   use XXX rather than groff]],
	[cf_man2html=$withval],
	[cf_man2html=$cf_man2html])

cf_with_groff=no

case $cf_man2html in
(yes)
	AC_MSG_RESULT(man2html)
	AC_PATH_PROG(cf_man2html,man2html,no)
	;;
(no|groff|*/groff*)
	cf_with_groff=yes
	cf_man2html=$GROFF_PATH
	AC_MSG_RESULT($cf_man2html)
	;;
(*)
	AC_MSG_RESULT($cf_man2html)
	;;
esac

MAN2HTML_TEMP="man2html.tmp"
	cat >$MAN2HTML_TEMP <<CF_EOF
#!$SHELL
# Temporary script generated by CF_WITH_MAN2HTML
# Convert inputs to html, sending result to standard output.
#
# Parameters:
# \${1} = rootname of file to convert
# \${2} = suffix of file to convert, e.g., "1"
# \${3} = macros to use, e.g., "man"
#
ROOT=\[$]1
TYPE=\[$]2
MACS=\[$]3

unset LANG
unset LC_ALL
unset LC_CTYPE
unset LANGUAGE
GROFF_NO_SGR=stupid
export GROFF_NO_SGR

CF_EOF

NROFF_OPTS=
if test "x$cf_with_groff" = xyes
then
	MAN2HTML_NOTE="$GROFF_NOTE"
	MAN2HTML_PATH="$GROFF_PATH"
	cat >>$MAN2HTML_TEMP <<CF_EOF
$SHELL -c "$TBL_PATH \${ROOT}.\${TYPE} | $GROFF_PATH -P -o0 -I\${ROOT}_ -Thtml -\${MACS}"
CF_EOF
else
	# disable hyphenation if this is groff
	if test "x$GROFF_PATH" != xno
	then
		AC_MSG_CHECKING(if nroff is really groff)
		cf_check_groff="`$NROFF_PATH --version 2>/dev/null | grep groff`"
		test -n "$cf_check_groff" && cf_check_groff=yes
		test -n "$cf_check_groff" || cf_check_groff=no
		AC_MSG_RESULT($cf_check_groff)
		test "x$cf_check_groff" = xyes && NROFF_OPTS="-rHY=0"
	fi
	MAN2HTML_NOTE=""
	CF_PATH_SYNTAX(cf_man2html)
	MAN2HTML_PATH="$cf_man2html"
	AC_MSG_CHECKING(for $cf_man2html top/bottom margins)

	# for this example, expect 3 lines of content, the remainder is head/foot
	cat >conftest.in <<CF_EOF
.TH HEAD1 HEAD2 HEAD3 HEAD4 HEAD5
.SH SECTION
MARKER
CF_EOF

	LC_ALL=C LC_CTYPE=C LANG=C LANGUAGE=C $NROFF_PATH -man conftest.in >conftest.out

	cf_man2html_1st="`${FGREP-fgrep} -n MARKER conftest.out |sed -e 's/^[[^0-9]]*://' -e 's/:.*//'`"
	cf_man2html_top=`expr "$cf_man2html_1st" - 2`
	cf_man2html_bot="`wc -l conftest.out |sed -e 's/[[^0-9]]//g'`"
	cf_man2html_bot=`expr "$cf_man2html_bot" - 2 - "$cf_man2html_top"`
	cf_man2html_top_bot="-topm=$cf_man2html_top -botm=$cf_man2html_bot"

	AC_MSG_RESULT($cf_man2html_top_bot)

	AC_MSG_CHECKING(for pagesize to use)
	for cf_block in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20
	do
	cat >>conftest.in <<CF_EOF
.nf
0
1
2
3
4
5
6
7
8
9
CF_EOF
	done

	LC_ALL=C LC_CTYPE=C LANG=C LANGUAGE=C $NROFF_PATH -man conftest.in >conftest.out
	cf_man2html_page="`${FGREP-fgrep} -n HEAD1 conftest.out |sed -n '$p' |sed -e 's/^[[^0-9]]*://' -e 's/:.*//'`"
	test -z "$cf_man2html_page" && cf_man2html_page=99999
	test "$cf_man2html_page" -gt 100 && cf_man2html_page=99999

	rm -rf conftest*
	AC_MSG_RESULT($cf_man2html_page)

	cat >>$MAN2HTML_TEMP <<CF_EOF
: \${MAN2HTML_PATH=$MAN2HTML_PATH}
MAN2HTML_OPTS="\$MAN2HTML_OPTS -index -title=\"\$ROOT(\$TYPE)\" -compress -pgsize $cf_man2html_page"
case \${TYPE} in
(ms)
	$TBL_PATH \${ROOT}.\${TYPE} | $NROFF_PATH $NROFF_OPTS -\${MACS} | \$MAN2HTML_PATH -topm=0 -botm=0 \$MAN2HTML_OPTS
	;;
(*)
	$TBL_PATH \${ROOT}.\${TYPE} | $NROFF_PATH $NROFF_OPTS -\${MACS} | \$MAN2HTML_PATH $cf_man2html_top_bot \$MAN2HTML_OPTS
	;;
esac
CF_EOF
fi

chmod 700 $MAN2HTML_TEMP

AC_SUBST(MAN2HTML_NOTE)
AC_SUBST(MAN2HTML_PATH)
AC_SUBST(MAN2HTML_TEMP)
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_WITH_NO_LEAKS version: 6 updated: 2021/11/25 17:10:01
dnl ----------------
AC_DEFUN([CF_WITH_NO_LEAKS],[
AC_REQUIRE([CF_WITH_DMALLOC])
AC_REQUIRE([CF_WITH_DBMALLOC])
AC_REQUIRE([CF_WITH_PURIFY])
AC_REQUIRE([CF_WITH_VALGRIND])

AC_MSG_CHECKING(if you want to perform memory-leak testing)
AC_ARG_WITH(no-leaks,
	[  --with-no-leaks         test: free permanent memory, analyze leaks],
	[case "x$withval" in
	 (xno|x)
		: ${enable_leaks:=yes}
	 	;;
	 (*)
		enable_leaks=no
	 	;;
	esac],
	[: ${enable_leaks:=yes}])

dnl TODO - drop with_no_leaks
if test "x$enable_leaks" = xno
then
	with_no_leaks=yes
else
	with_no_leaks=no
fi

AC_MSG_RESULT($with_no_leaks)

if test "x$enable_leaks" = xno
then
	AC_DEFINE(NO_LEAKS,1,[Define to 1 to enable leak-checking])
	cf_doalloc=".${with_dmalloc}${with_dbmalloc}${with_purify}${with_valgrind}"
	case ${cf_doalloc} in
	(*yes*)
		;;
	(*)
		AC_DEFINE(DOALLOC,10000,[Define to size of malloc-array])
		;;
	esac
fi
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_WITH_PURIFY version: 2 updated: 2006/12/14 18:43:43
dnl --------------
AC_DEFUN([CF_WITH_PURIFY],[
CF_NO_LEAKS_OPTION(purify,
	[  --with-purify           test: use Purify],
	[USE_PURIFY],
	[LINK_PREFIX="$LINK_PREFIX purify"])
AC_SUBST(LINK_PREFIX)
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_WITH_SYSTYPE version: 1 updated: 2013/01/26 16:26:12
dnl ---------------
dnl For testing, override the derived host system-type which is used to decide
dnl things such as the linker commands used to build shared libraries.  This is
dnl normally chosen automatically based on the type of system which you are
dnl building on.  We use it for testing the configure script.
dnl
dnl This is different from the --host option: it is used only for testing parts
dnl of the configure script which would not be reachable with --host since that
dnl relies on the build environment being real, rather than mocked up.
AC_DEFUN([CF_WITH_SYSTYPE],[
CF_CHECK_CACHE([AC_CANONICAL_SYSTEM])
AC_ARG_WITH(system-type,
	[  --with-system-type=XXX  test: override derived host system-type],
[AC_MSG_WARN(overriding system type to $withval)
	cf_cv_system_name=$withval
	host_os=$withval
])
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_WITH_VALGRIND version: 1 updated: 2006/12/14 18:00:21
dnl ----------------
AC_DEFUN([CF_WITH_VALGRIND],[
CF_NO_LEAKS_OPTION(valgrind,
	[  --with-valgrind         test: use valgrind],
	[USE_VALGRIND])
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_WITH_WARNINGS version: 5 updated: 2004/07/23 14:40:34
dnl ----------------
dnl Combine the checks for gcc features into a configure-script option
dnl
dnl Parameters:
dnl	$1 - see CF_GCC_WARNINGS
AC_DEFUN([CF_WITH_WARNINGS],
[
if ( test "$GCC" = yes || test "$GXX" = yes )
then
AC_MSG_CHECKING(if you want to check for gcc warnings)
AC_ARG_WITH(warnings,
	[  --with-warnings         test: turn on gcc warnings],
	[cf_opt_with_warnings=$withval],
	[cf_opt_with_warnings=no])
AC_MSG_RESULT($cf_opt_with_warnings)
if test "$cf_opt_with_warnings" != no ; then
	CF_GCC_ATTRIBUTES
	CF_GCC_WARNINGS([$1])
fi
fi
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_XOPEN_SOURCE version: 68 updated: 2024/11/09 18:07:29
dnl ---------------
dnl Try to get _XOPEN_SOURCE defined properly that we can use POSIX functions,
dnl or adapt to the vendor's definitions to get equivalent functionality,
dnl without losing the common non-POSIX features.
dnl
dnl Parameters:
dnl	$1 is the nominal value for _XOPEN_SOURCE
dnl	$2 is the nominal value for _POSIX_C_SOURCE
dnl
dnl The default case prefers _XOPEN_SOURCE over _POSIX_C_SOURCE if the
dnl implementation predefines it, because X/Open and most implementations agree
dnl that the latter is a legacy or "aligned" value.
dnl
dnl Because _XOPEN_SOURCE is preferred, if defining _POSIX_C_SOURCE turns
dnl that off, then refrain from setting _POSIX_C_SOURCE explicitly.
dnl
dnl References:
dnl https://pubs.opengroup.org/onlinepubs/007904975/functions/xsh_chap02_02.html
dnl https://docs.oracle.com/cd/E19253-01/816-5175/standards-5/index.html
dnl https://www.gnu.org/software/libc/manual/html_node/Feature-Test-Macros.html
AC_DEFUN([CF_XOPEN_SOURCE],[
AC_REQUIRE([AC_CANONICAL_HOST])
AC_REQUIRE([CF_POSIX_VISIBLE])

if test "$cf_cv_posix_visible" = no; then

cf_XOPEN_SOURCE=ifelse([$1],,500,[$1])
cf_POSIX_C_SOURCE=ifelse([$2],,199506L,[$2])
cf_xopen_source=

case "$host_os" in
(aix[[4-7]]*)
	cf_xopen_source="-D_ALL_SOURCE"
	;;
(darwin[[0-8]].*)
	cf_xopen_source="-D_APPLE_C_SOURCE"
	;;
(darwin*)
	cf_xopen_source="-D_DARWIN_C_SOURCE"
	cf_XOPEN_SOURCE=
	;;
(freebsd*|dragonfly*|midnightbsd*)
	# 5.x headers associate
	#	_XOPEN_SOURCE=600 with _POSIX_C_SOURCE=200112L
	#	_XOPEN_SOURCE=500 with _POSIX_C_SOURCE=199506L
	cf_POSIX_C_SOURCE=200112L
	cf_XOPEN_SOURCE=600
	cf_xopen_source="-D_BSD_TYPES -D__BSD_VISIBLE -D_POSIX_C_SOURCE=$cf_POSIX_C_SOURCE -D_XOPEN_SOURCE=$cf_XOPEN_SOURCE"
	;;
(hpux11*)
	cf_xopen_source="-D_HPUX_SOURCE -D_XOPEN_SOURCE=500"
	;;
(hpux*)
	cf_xopen_source="-D_HPUX_SOURCE"
	;;
(irix[[56]].*)
	cf_xopen_source="-D_SGI_SOURCE"
	cf_XOPEN_SOURCE=
	;;
(linux*gnu|linux*gnuabi64|linux*gnuabin32|linux*gnueabi|linux*gnueabihf|linux*gnux32|uclinux*|gnu*|mint*|k*bsd*-gnu|cygwin|msys|mingw*|linux*uclibc)
	CF_GNU_SOURCE($cf_XOPEN_SOURCE)
	;;
linux*musl)
	cf_xopen_source="-D_BSD_SOURCE"
	;;
(minix*)
	cf_xopen_source="-D_NETBSD_SOURCE" # POSIX.1-2001 features are ifdef'd with this...
	;;
(mirbsd*)
	# setting _XOPEN_SOURCE or _POSIX_SOURCE breaks <sys/select.h> and other headers which use u_int / u_short types
	cf_XOPEN_SOURCE=
	CF_POSIX_C_SOURCE($cf_POSIX_C_SOURCE)
	;;
(netbsd*)
	cf_xopen_source="-D_NETBSD_SOURCE" # setting _XOPEN_SOURCE breaks IPv6 for lynx on NetBSD 1.6, breaks xterm, is not needed for ncursesw
	;;
(openbsd[[6-9]]*)
	# OpenBSD 6.x has broken locale support, both compile-time and runtime.
	# see https://www.mail-archive.com/bugs@openbsd.org/msg13200.html
	# Abusing the conformance level is a workaround.
	AC_MSG_WARN(this system does not provide usable locale support)
	cf_xopen_source="-D_BSD_SOURCE"
	cf_XOPEN_SOURCE=700
	;;
(openbsd[[4-5]]*)
	# setting _XOPEN_SOURCE lower than 500 breaks g++ compile with wchar.h, needed for ncursesw
	cf_xopen_source="-D_BSD_SOURCE"
	cf_XOPEN_SOURCE=600
	;;
(openbsd*)
	# setting _XOPEN_SOURCE breaks xterm on OpenBSD 2.8, is not needed for ncursesw
	;;
(osf[[45]]*)
	cf_xopen_source="-D_OSF_SOURCE"
	;;
(nto-qnx*)
	cf_xopen_source="-D_QNX_SOURCE"
	;;
(sco*)
	# setting _XOPEN_SOURCE breaks Lynx on SCO Unix / OpenServer
	;;
(solaris2.*)
	cf_xopen_source="-D__EXTENSIONS__"
	cf_cv_xopen_source=broken
	;;
(sysv4.2uw2.*) # Novell/SCO UnixWare 2.x (tested on 2.1.2)
	cf_XOPEN_SOURCE=
	cf_POSIX_C_SOURCE=
	;;
(*)
	CF_TRY_XOPEN_SOURCE
	cf_save_xopen_cppflags="$CPPFLAGS"
	CF_POSIX_C_SOURCE($cf_POSIX_C_SOURCE)
	# Some of these niche implementations use copy/paste, double-check...
	if test "$cf_cv_xopen_source" = no ; then
		CF_VERBOSE(checking if _POSIX_C_SOURCE interferes with _XOPEN_SOURCE)
		AC_TRY_COMPILE(CF__XOPEN_SOURCE_HEAD,CF__XOPEN_SOURCE_BODY,,[
			AC_MSG_WARN(_POSIX_C_SOURCE definition is not usable)
			CPPFLAGS="$cf_save_xopen_cppflags"])
	fi
	;;
esac

if test -n "$cf_xopen_source" ; then
	CF_APPEND_CFLAGS($cf_xopen_source,true)
fi

dnl In anything but the default case, we may have system-specific setting
dnl which is still not guaranteed to provide all of the entrypoints that
dnl _XOPEN_SOURCE would yield.
if test -n "$cf_XOPEN_SOURCE" && test -z "$cf_cv_xopen_source" ; then
	AC_MSG_CHECKING(if _XOPEN_SOURCE really is set)
	AC_TRY_COMPILE([#include <stdlib.h>],[
#ifndef _XOPEN_SOURCE
#error _XOPEN_SOURCE is not defined
#endif],
	[cf_XOPEN_SOURCE_set=yes],
	[cf_XOPEN_SOURCE_set=no])
	AC_MSG_RESULT($cf_XOPEN_SOURCE_set)
	if test "$cf_XOPEN_SOURCE_set" = yes
	then
		AC_TRY_COMPILE([#include <stdlib.h>],[
#if (_XOPEN_SOURCE - 0) < $cf_XOPEN_SOURCE
#error (_XOPEN_SOURCE - 0) < $cf_XOPEN_SOURCE
#endif],
		[cf_XOPEN_SOURCE_set_ok=yes],
		[cf_XOPEN_SOURCE_set_ok=no])
		if test "$cf_XOPEN_SOURCE_set_ok" = no
		then
			AC_MSG_WARN(_XOPEN_SOURCE is lower than requested)
		fi
	else
		CF_TRY_XOPEN_SOURCE
	fi
fi
fi # cf_cv_posix_visible
])
dnl ---------------------------------------------------------------------------
dnl CF__XOPEN_SOURCE_BODY version: 2 updated: 2023/02/18 17:41:25
dnl ---------------------
dnl body of test when test-compiling for _XOPEN_SOURCE check
define([CF__XOPEN_SOURCE_BODY],
[
#ifndef _XOPEN_SOURCE
#error _XOPEN_SOURCE is not defined
#endif
])
dnl ---------------------------------------------------------------------------
dnl CF__XOPEN_SOURCE_HEAD version: 2 updated: 2023/02/18 17:41:25
dnl ---------------------
dnl headers to include when test-compiling for _XOPEN_SOURCE check
define([CF__XOPEN_SOURCE_HEAD],
[
$ac_includes_default
])
