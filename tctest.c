/******************************************************************************
 * Copyright 2011 by Thomas E. Dickey                                         *
 * All Rights Reserved.                                                       *
 *                                                                            *
 * Permission to use, copy, modify, and distribute this software and its      *
 * documentation for any purpose and without fee is hereby granted, provided  *
 * that the above copyright notice appear in all copies and that both that    *
 * copyright notice and this permission notice appear in supporting           *
 * documentation, and that the name of the above listed copyright holder(s)   *
 * not be used in advertising or publicity pertaining to distribution of the  *
 * software without specific, written prior permission.                       *
 *                                                                            *
 * THE ABOVE LISTED COPYRIGHT HOLDER(S) DISCLAIM ALL WARRANTIES WITH REGARD   *
 * TO THIS SOFTWARE, INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND  *
 * FITNESS, IN NO EVENT SHALL THE ABOVE LISTED COPYRIGHT HOLDER(S) BE LIABLE  *
 * FOR ANY SPECIAL, INDIRECT OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES          *
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN      *
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR *
 * IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.                *
 ******************************************************************************/

/*
 * Author: Thomas E. Dickey
 *
 * $Id: tctest.c,v 1.51 2011/08/13 23:31:31 tom Exp $
 *
 * A simple test-program for the termcap interface.
 *
 * TODO: if using ncurses, attempt to link with libtic to allow reformatting
 * TODO: option -E for setting $TERMCAP based on file's contents
 * TODO: option -L for listing size with tc's included (store file in memory).
 * TODO: option -e for testing the $TERMCAP variable
 * TODO: option -o for testing tputs for each string capability
 */
#include <config.h>

#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>

#include <signal.h>
#include <setjmp.h>

#if defined(HAVE__NC_INFOTOCAP)
extern char *_nc_infotocap(const char *, const char *, int const);
#define USE_LIBTIC 1
#endif

#ifdef HAVE_USE_ENV
#include <curses.h>
#endif

#ifdef HAVE_TERMCAP_H
#include <termcap.h>
#endif

#ifndef NCURSES_CONST
#define NCURSES_CONST		/* nothing */
#endif

#ifndef HAVE_TERMCAP_H
/* only the newer implementations provide prototypes */
extern int tgetflag(NCURSES_CONST char *);
extern int tgetnum(NCURSES_CONST char *);
extern int tgetent(NCURSES_CONST char *, char *);
extern int tputs(NCURSES_CONST char *, int, int (*)(int));
extern char *tgetstr(NCURSES_CONST char *, char **);
#endif

static char *safe_tgetstr(NCURSES_CONST char *cap, char **);

extern void _nc_leaks_tic(void);
extern void _nc_freeall(void);

#define MAXBUF 4096

#define FCOLS 2
#define FNULL(type) "%s %-*s cancelled ", #type, FCOLS
#define FNAME(type) "%s %-*s = ", #type, FCOLS

#define DumpIt       (a_opt || !(l_opt || s_opt))
#define isCapName(c) (isgraph(c) && strchr("^=:\\", c) == 0)
#define UCH(c)       ((unsigned char)(c))

/* options */
static int a_opt = 0;
static int b_opt = 0;
static int e_opt = 0;
static char *f_opt = 0;
static int l_opt = 0;
static int r_opt = 0;
static int s_opt = 0;
static int v_opt = 0;
static int w_opt = 0;

/* "-s" report */
static unsigned largest_entry;
static unsigned total_entries;
static unsigned total_failure;
static unsigned total_warning;
static unsigned total_tgetent;
static unsigned total_wasted0;
static unsigned total_aliases;
static unsigned total_toobig0;
static unsigned total_toobig1;
static unsigned total_include0;
static unsigned total_include1;
static unsigned largest_include;
static unsigned unknown_include;

static FILE *output;
static FILE *report;

static void
failed(const char *msg)
{
    perror(msg);
    exit(EXIT_FAILURE);
}

#ifdef HAVE_UNSETENV
#define my_unsetenv(name) unsetenv(name)
#else
static void
my_unsetenv(const char *name)
{
    if (getenv(name) != 0 && *getenv(name) != '\0') {
	char *no_value = malloc(strlen(name) + 2);
	if (no_value != 0) {
	    sprintf(no_value, "%s=", name);
	    putenv(no_value);
	} else {
	    failed("unsetenv");
	}
    }
}
#endif

static const char *
find_termcap_file(void)
{
    const char *result;
    const char *env = getenv("TERMCAP");

    result = "/etc/termcap";
    if (env != 0 && *env == '/')
	result = env;
    return result;
}

static FILE *
open_termcap_file(void)
{
    const char *name = find_termcap_file();
    FILE *fp = fopen(name, "r");
    if (fp == 0)
	failed(name);
    return fp;
}

static void
set_termcap_file(const char *fname)
{
    const char *format = "TERMCAP=%s";
    const char *prefix = "";
    char *value;
    char buffer[MAXBUF];

    /* the $TERMCAP variable must be an absolute pathname */
    if (*fname != '/') {
	if (getcwd(buffer, sizeof(buffer) - 2) == 0) {
	    failed("getcwd");
	}
	strcat(buffer, "/");
	prefix = buffer;
    }
    value = malloc(strlen(format) + strlen(prefix) + strlen(fname));
    sprintf(value, format, prefix);
    strcat(value, fname);
    putenv(value);
}

static void
free_list(char **list)
{
    if (list != 0) {
	int n;
	for (n = 0; list[n] != 0; ++n) {
	    free(list[n]);
	}
	free(list);
    }
}

static char **
make_list(char **list)
{
    char **result = 0;
    if (list != 0) {
	size_t n;
	for (n = 0; list[n] != 0; ++n) {
	    ;
	}
	if (n) {
	    ++n;
	    result = calloc(n, sizeof(char *));
	    if (result != 0) {
		for (n = 0; list[n] != 0; ++n) {
		    result[n] = list[n];
		}
	    }
	}
    }
    return result;
}

static void
show_list(char **list)
{
    if (list != 0) {
	int n;
	for (n = 0; list[n] != 0; ++n) {
	    const char *next = list[n + 1] ? "\\" : "";
	    fprintf(output, "%s%s\n", list[n], next);
	}
    }
}

static int
same_list(char **a, char **b)
{
    int result = 1;
    int n;

    if (a == 0 || b == 0) {
	result = 0;
    } else {
	for (n = 0; a[n] != 0 && b[n] != 0; ++n) {
	    if (strcmp(a[n], b[n])) {
		result = 0;
		break;
	    }
	}
	if ((a[n] != 0) ^ (b[n] != 0)) {
	    result = 0;
	}
    }
    return result;
}

static unsigned
count_aliases(char *buffer)
{
    unsigned result = 0;
    char *p, *q;

    for (p = q = buffer; *p != '\0' && *p != ':'; ++p) {
	if (*p == '|') {
	    if ((p - q) > 1)
		++result;
	    q = p;
	}
    }
    if (p != buffer && *p == ':')
	--result;

    return result;
}

static unsigned
count_includes(const char *buffer)
{
    unsigned result = 0;
    const char *p = strchr(buffer, ':');
    int ch;

    if (p != 0) {
	while ((ch = *p++) != '\0' && (*p != '\0')) {
	    if (ch == '\\') {
		++p;
	    } else if (ch == ':') {
		if (!strncmp(p, "tc=", (size_t) 3)) {
		    ++result;
		}
	    }
	}
    }
    return result;
}

static unsigned
count_wasted0(char *buffer)
{
    char *p;
    unsigned wasted = 0;

    /*
     * The termcap library may strip out newlines, but leave
     * unnecessary tabs and an extra colon.
     */
    for (p = buffer; *p; ++p) {
	if (*p == '\\') {
	    if ((*++p) == '\0')
		break;
	} else if (*p == ':') {
	    if (isspace(UCH(p[1]))) {
		while (isspace(UCH(p[1]))) {
		    ++wasted;
		    ++p;
		}
		if (p[1] == ':') {
		    ++wasted;
		    ++p;
		}
	    }
	}
    }
    return wasted;
}

static void
count_tgetent(char *buffer)
{
    char area[MAXBUF], *areap = area;
    char *str;
    unsigned wasted;
    unsigned length;

    total_entries++;

    if (buffer != 0 && *buffer != '\0') {
	/* check for NetBSD extension */
	if ((str = safe_tgetstr("ZZ", &areap)) != 0) {
	    char *ptr;
	    char ch;
	    if (sscanf(str, "%p%c", &ptr, &ch) == 1) {
		buffer = ptr;
	    }
	}
	wasted = count_wasted0(buffer);
	length = (unsigned) strlen(buffer);

	if (largest_entry < length)
	    largest_entry = length;

	total_tgetent += (unsigned) strlen(buffer);
	total_wasted0 += wasted;
	total_aliases += count_aliases(buffer);
	total_toobig0 += (unsigned) (length > 1023);
	total_toobig1 += (unsigned) ((length - wasted) > 1023);
	unknown_include += count_includes(buffer);
    }
}

/*
 * This table is adapted from ncurses, using MKparametrized.sh:
 * A value of -1 in the table means suppress both pad and % translations.
 * A value of 0 (no entry in the table) means do pad but not % translations.
 * A value of 1 in the table means do both pad and % translations.
 */
static int
uses_params(const char *capname)
{
#define DATA(name, value) { name, value }
    static const struct {
	const char *name;
	short value;
    } table[] = {
	DATA("#1", 1),
	    DATA("#2", 1),
	    DATA("#3", 1),
	    DATA("#4", 1),
	    DATA("AB", 1),
	    DATA("AF", 1),
	    DATA("AL", 1),
	    DATA("CM", 1),
	    DATA("CW", 1),
	    DATA("DC", 1),
	    DATA("DI", 1),
	    DATA("DL", 1),
	    DATA("DO", 1),
	    DATA("G1", -1),
	    DATA("G2", -1),
	    DATA("G3", -1),
	    DATA("G4", -1),
	    DATA("GC", -1),
	    DATA("GD", -1),
	    DATA("GH", -1),
	    DATA("GL", -1),
	    DATA("GR", -1),
	    DATA("GU", -1),
	    DATA("GV", -1),
	    DATA("Gm", 1),
	    DATA("IC", 1),
	    DATA("Ic", 1),
	    DATA("Ip", 1),
	    DATA("LE", 1),
	    DATA("ML", 1),
	    DATA("MT", 1),
	    DATA("QD", 1),
	    DATA("RI", 1),
	    DATA("S1", 1),
	    DATA("SC", 1),
	    DATA("SF", 1),
	    DATA("SR", 1),
	    DATA("Sb", 1),
	    DATA("Sf", 1),
	    DATA("UP", 1),
	    DATA("WG", 1),
	    DATA("Xy", 1),
	    DATA("YZ", 1),
	    DATA("Yw", 1),
	    DATA("Yz", 1),
	    DATA("ZA", 1),
	    DATA("ZB", 1),
	    DATA("ZC", 1),
	    DATA("ZD", 1),
	    DATA("ZE", 1),
	    DATA("Zc", 1),
	    DATA("Zj", 1),
	    DATA("Zl", 1),
	    DATA("Zm", 1),
	    DATA("Zn", 1),
	    DATA("Zp", 1),
	    DATA("Zr", 1),
	    DATA("Zt", 1),
	    DATA("Zy", 1),
	    DATA("ac", -1),
	    DATA("ch", 1),
	    DATA("cm", 1),
	    DATA("cs", 1),
	    DATA("cv", 1),
	    DATA("ec", 1),
	    DATA("pO", 1),
	    DATA("pk", 1),
	    DATA("pl", 1),
	    DATA("pn", 1),
	    DATA("pn", 1),
	    DATA("px", 1),
	    DATA("rp", 1),
	    DATA("sA", 1),
	    DATA("sL", 1),
	    DATA("sa", 1),
	    DATA("sp", 1),
	    DATA("ts", 1),
	    DATA("u0", 1),
	    DATA("u1", 1),
	    DATA("u2", 1),
	    DATA("u3", 1),
	    DATA("u4", 1),
	    DATA("u5", 1),
	    DATA("u6", 1),
	    DATA("u7", 1),
	    DATA("u8", 1),
	    DATA("u9", 1),
	    DATA("wi", 1),
	    DATA("xl", 1),
    };
#undef DATA
    size_t n;
    int result = 0;
    /* FIXME bsearch */
    for (n = 0; n < sizeof(table) / sizeof(table[0]); ++n) {
	if (!strcmp(capname, table[n].name)) {
	    result = table[n].value;
	    break;
	}
    }

    return result;
}

static void
check_tgoto(const char *capname, const char *buffer)
{
    if (buffer != 0 && *buffer != '\0') {
	const char *p;
	int done = 0;
	for (p = buffer; !done && (*p != '\0'); ++p) {
	    if (*p == '\\') {
		if (*++p == '\0') {
		    break;
		}
	    } else if (*p == '%') {
		const char *mark = p;
		if (*++p == '\0' || *p == ':') {
		    ++total_warning;
		    if (w_opt)
			fprintf(report, "%s - trailing %%\n", capname);
		    break;
		} else {
		    int need = 0;
		    switch (*p) {
		    case 'd':
		    case '2':
		    case '3':
		    case '.':
		    case 'i':
		    case '%':
		    case 'B':
		    case 'D':
		    case 'r':
			need = 0;
		    case '+':
			need = 1;
			break;
		    case '>':
			need = 2;
			break;
		    default:
			++total_warning;
			if (w_opt)
			    fprintf(report, "%s - unrecognized escape %s\n",
				    capname, mark);
			done = 1;
			break;
		    }
		}
	    }
	}
    }
}

static jmp_buf my_jumper;

static void
catcher(int code)
{
    longjmp(my_jumper, code);
}

static void
setcatch(void (*function) (int))
{
    signal(SIGSEGV, function);
    signal(SIGSYS, function);
}

/*
 * If a termcap is too large, some implementations (particularly Solaris)
 * will dump core rather than return an error.
 */
static int
safe_tgetent(char *buffer, char *name)
{
    int result;
    int code;

    setcatch(catcher);
    if (setjmp(my_jumper) != 0) {
	result = 0;
	total_failure++;
    } else {
	buffer[0] = '\0';
	code = tgetent(buffer, name);
#ifdef BROKEN_TGETENT_STATUS
	result = (code == 0);
#else
	result = (code > 0);
#endif
    }
    setcatch(SIG_DFL);
    return result;
}

static int
call_tgetent(char *buffer, char *name)
{
    int result;

    if (v_opt)
	fprintf(report, "loading %s\n", name);

    result = safe_tgetent(buffer, name);

    if (result && s_opt) {
	count_tgetent(buffer);
    }

    if (v_opt)
	fprintf(report, "...%s %s\n", result ? "loaded" : "failed", name);
    return result;
}

/*
 * If a termcap is too large, some implementations (particularly Solaris)
 * will dump core rather than return an error.
 */
static char *
safe_tgetstr(NCURSES_CONST char *cap, char **areap)
{
    char *result;

    setcatch(catcher);
    if (setjmp(my_jumper) != 0) {
	result = 0;
	total_failure++;
    } else {
	result = tgetstr(cap, areap);
    }
    setcatch(SIG_DFL);
    return result;
}

static char *
dumpit(const char *cap, char **areap)
{
    NCURSES_CONST char *capname = (NCURSES_CONST char *) cap;
    char *result = 0;
    char buffer[MAXBUF], *append = 0;
    char *str;
    int num;

    if ((str = safe_tgetstr(capname, areap)) != 0) {
	int params = uses_params(capname);
	char *cpy = 0;
#ifdef USE_LIBTIC
	char mybuf[MAXBUF];
	char *p, *q;
	/* _nc_infotocap() expects backslashes to be escaped */
	for (p = mybuf, q = str; *q != 0; ++q) {
	    int ch = *q;
	    if (ch == '\\')
		*p++ = '\\';
	    *p++ = *q;
	}
	*p = 0;
	cpy = _nc_infotocap(0, mybuf, params);
	if (cpy != 0) {
	    if (v_opt > 3) {
		fprintf(report, "string %s\n", capname);
		fprintf(report, "< %s\n", str);
		fprintf(report, "> %s\n", cpy);
	    }
	    str = cpy;
	} else if (params) {
	    if (w_opt) {
		++total_warning;
		fprintf(report, "cannot translate %s=%s\n", capname, mybuf);
	    }
	    params = 0;
	}
#endif
	if (str == (char *) -1) {
	    sprintf(buffer, "\t:%s@:", capname);
	} else {
	    if (params > 0)
		check_tgoto(capname, str);
	    sprintf(buffer, "\t:%s=", capname);
	    append = buffer + strlen(buffer);
	    while (*str != 0) {
		int ch = (unsigned char) (*str++);
		switch (ch) {
		case '\033':
		    strcpy(append, "\\E");
		    break;
		case '\b':
		    strcpy(append, "\\b");
		    break;
		case '\f':
		    strcpy(append, "\\f");
		    break;
		case '\n':
		    strcpy(append, "\\n");
		    break;
		case '\r':
		    strcpy(append, "\\r");
		    break;
		case '\t':
		    strcpy(append, "\\t");
		    break;
		case '^':
		    if (cpy == 0) {
			strcpy(append, "\\^");
		    } else {
			strcpy(append, "^");
			if (w_opt) {
			    ++total_warning;
			    if (!isalpha(UCH(*str))) {
				if (*str == '@') {
				    fprintf(report, "unexpected escape ^@\n");
				} else if (!strchr("[\\]^_", *str)) {
				    fprintf(report,
					    "unexpected escape ^%c\n", *str);
				}
			    }
			}
			if (*str > 32 && *str < 127) {
			    sprintf(append + 1, "%c", *str++);
			}
		    }
		    break;
		case ':':
		    strcpy(append, "\\072");
		    break;
		case '\\':
		    if (cpy == 0 || !*str) {
			strcpy(append, "\\\\");
		    } else {
			/* documentation incorrectly asserts these escapes are
			 * needed, and the majority of original examples do
			 * not use the octal values.
			 */
			if (!strncmp(str, "136", (size_t) 3)) {
			    strcpy(append, "\\^");
			    str += 3;
			} else if (!strncmp(str, "134", (size_t) 3)) {
			    strcpy(append, "\\\\");
			    str += 3;
			} else {
			    sprintf(append, "\\%c", *str++);
			}
		    }
		    break;
		default:
		    if (isgraph(UCH(ch)))
			sprintf(append, "%c", ch);
		    else if (ch < 32)
			sprintf(append, "^%c", ch + '@');
		    else
			sprintf(append, "\\%03o", ch);
		    break;
		}
		append += strlen(append);
	    }
	}
	strcpy(append, ":");
	result = strdup(buffer);
    } else if ((num = tgetnum(capname)) >= 0) {
	sprintf(buffer, "\t:%s#%d:", capname, num);
	result = strdup(buffer);
    } else if (tgetflag(capname) > 0) {
	sprintf(buffer, "\t:%s:", cap);
	result = strdup(buffer);
    }
    return result;
}

#define PCT(num,den) ((100.0 * (double)(num)) / (double)(den))

static void
report_one_size(char *buffer, int count, char *area, int length)
{
    if (v_opt > 1) {
	/*
	 * A terminfo library will not update the buffer, which would then
	 * be empty.
	 */
	if (*buffer != '\0') {
	    unsigned wasted = count_wasted0(buffer);
	    unsigned buflen = (unsigned) strlen(buffer);

	    fprintf(report, "\t%4d bytes total (%.1f%%)\n",
		    buflen, PCT(buflen, 1023));
	    if (wasted) {
		fprintf(report, "\t%4d wasted space (%.1f%%)\n",
			wasted, PCT(wasted, buflen));
	    }
	}
	fprintf(report, "\t%4d capabilities\n", count);
	if (length) {
	    int numstrings = 1;
	    int n;
	    int wasted = 0;

	    /*
	     * termcap could, but does not, optimize wasted nulls for empty
	     * strings.  The tgetstr buffer is less of a problem than the
	     * tgetent buffer.
	     */
	    for (n = 0; n < length; ++n) {
		if (area[n] == '\0') {
		    ++numstrings;
		    if (area[n + 1] == '\0') {
			++wasted;
		    }
		}
	    }
	    fprintf(report, "\t%4d strings\n", numstrings);
	    fprintf(report, "\t%4d bytes of strings\n", length);
	    if (wasted) {
		fprintf(report, "\t%4d wasted nulls\n", wasted);
	    }
	}
	if ((v_opt > 2) && (*buffer != '\0')) {
	    fprintf(report, "TERMCAP=%s\n", buffer);
	}
    }
}

static char **
brute_force(char *name)
{
    char buffer[MAXBUF];
    char *vector[MAXBUF];
    char area[MAXBUF], *ap = area;
    int count = 0;

    area[0] = '\0';
    if (call_tgetent(buffer, name)) {
	char cap[3];
	int c1, c2;

	cap[2] = 0;
	for (c1 = 0; c1 < 256; ++c1) {
	    cap[0] = (char) c1;
	    if (isCapName(c1)) {
		for (c2 = 0; c2 < 256; ++c2) {
		    cap[1] = (char) c2;
		    if (isCapName(c2)) {
			char *value = dumpit(cap, &ap);
			if (value != 0) {
			    vector[count++] = value;
			}
		    }
		}
	    }
	}
    }
    vector[count] = 0;
    report_one_size(buffer, count, area, (int) (ap - area));
    return make_list(vector);
}

/*
 * There are no standard termcap names.  The closest to a standard is the
 * documentation for termcap names in the tables used to document terminfo
 * capabilities, noting that many of those names are invented, having no
 * historical use.  Notwithstanding that, termcap users have invented a history
 * which makes these (in particular the set using ncurses' additions) as
 * "standard".
 */
static char **
conventional(char *name)
{
    static const char *tbl[] =
    {
	"!1", "!2", "!3", "#1", "#2", "#3", "#4", "%0", "%1", "%2", "%3",
	"%4", "%5", "%6", "%7", "%8", "%9", "%a", "%b", "%c", "%d", "%e",
	"%f", "%g", "%h", "%i", "%j", "&0", "&1", "&2", "&3", "&4", "&5",
	"&6", "&7", "&8", "&9", "*0", "*1", "*2", "*3", "*4", "*5", "*6",
	"*7", "*8", "*9", "5i", "@0", "@1", "@2", "@3", "@4", "@5", "@6",
	"@7", "@8", "@9", "AB", "AF", "AL", "BT", "CC", "CM", "CW", "Co",
	"DC", "DI", "DK", "DL", "DO", "EP", "F1", "F2", "F3", "F4", "F5",
	"F6", "F7", "F8", "F9", "FA", "FB", "FC", "FD", "FE", "FF", "FG",
	"FH", "FI", "FJ", "FK", "FL", "FM", "FN", "FO", "FP", "FQ", "FR",
	"FS", "FT", "FU", "FV", "FW", "FX", "FY", "FZ", "Fa", "Fb", "Fc",
	"Fd", "Fe", "Ff", "Fg", "Fh", "Fi", "Fj", "Fk", "Fl", "Fm", "Fn",
	"Fo", "Fp", "Fq", "Fr", "Gm", "HC", "HD", "HU", "IC", "Ic", "Ip",
	"K1", "K2", "K3", "K4", "K5", "Km", "LC", "LE", "LF", "LO", "Lf",
	"MC", "ML", "ML", "MR", "MT", "MW", "Mi", "NC", "ND", "NL", "NP",
	"NR", "Nl", "OP", "PA", "PU", "QD", "RA", "RC", "RF", "RI", "RQ",
	"RX", "S1", "S2", "S3", "S4", "S5", "S6", "S7", "S8", "SA", "SC",
	"SF", "SR", "SX", "Sb", "Sf", "TO", "UC", "UP", "WA", "WG", "XF",
	"XN", "Xh", "Xl", "Xo", "Xr", "Xt", "Xv", "Xy", "YA", "YB", "YC",
	"YD", "YE", "YF", "YG", "YZ", "Ya", "Yb", "Yc", "Yd", "Ye", "Yf",
	"Yg", "Yh", "Yi", "Yj", "Yk", "Yl", "Ym", "Yn", "Yo", "Yp", "Yv",
	"Yw", "Yx", "Yy", "Yz", "ZA", "ZB", "ZC", "ZD", "ZE", "ZF", "ZG",
	"ZH", "ZI", "ZJ", "ZK", "ZL", "ZM", "ZN", "ZO", "ZP", "ZQ", "ZR",
	"ZS", "ZT", "ZU", "ZV", "ZW", "ZX", "ZY", "ZZ", "Za", "Zb", "Zc",
	"Zd", "Ze", "Zf", "Zg", "Zh", "Zi", "Zj", "Zk", "Zl", "Zm", "Zn",
	"Zo", "Zp", "Zq", "Zr", "Zs", "Zt", "Zu", "Zv", "Zw", "Zx", "Zy",
	"Zz", "ac", "ae", "al", "am", "as", "bc", "bl", "bs", "bt", "bw",
	"cb", "cc", "cd", "ce", "ch", "ci", "cl", "cm", "co", "cr", "cs",
	"ct", "cv", "dB", "dC", "dF", "dN", "dT", "dV", "da", "db", "dc",
	"dl", "dm", "do", "ds", "dv", "eA", "ec", "ed", "ei", "eo", "es",
	"ff", "fh", "fs", "gn", "hc", "hd", "hl", "ho", "hs", "hu", "hz",
	"i1", "i2", "i3", "iP", "ic", "if", "im", "in", "ip", "is", "it",
	"k0", "k1", "k2", "k3", "k4", "k5", "k6", "k7", "k8", "k9", "k;",
	"kA", "kB", "kC", "kD", "kE", "kF", "kH", "kI", "kL", "kM", "kN",
	"kP", "kR", "kS", "kT", "ka", "kb", "kd", "ke", "kh", "kl", "km",
	"kn", "ko", "kr", "ks", "kt", "ku", "l0", "l1", "l2", "l3", "l4",
	"l5", "l6", "l7", "l8", "l9", "la", "le", "lh", "li", "ll", "lm",
	"lw", "ma", "mb", "md", "me", "mh", "mi", "mk", "ml", "mm", "mo",
	"mp", "mr", "ms", "mu", "nc", "nd", "nl", "ns", "nw", "nx", "oc",
	"op", "os", "pO", "pa", "pb", "pc", "pf", "pk", "pl", "pn", "po",
	"ps", "pt", "px", "r1", "r2", "r3", "rP", "rc", "rf", "rp", "rs",
	"s0", "s1", "s2", "s3", "sa", "sc", "se", "sf", "sg", "so", "sp",
	"sr", "st", "ta", "tc", "te", "ti", "ts", "u0", "u1", "u2", "u3",
	"u4", "u5", "u6", "u7", "u8", "u9", "uc", "ue", "ug", "ul", "up",
	"us", "ut", "vb", "ve", "vi", "vs", "vt", "wi", "ws", "xb", "xl",
	"xn", "xo", "xr", "xs", "xt", "xx",
    };
    char buffer[MAXBUF];
    char area[MAXBUF], *ap = area;
    char *vector[MAXBUF];
    int count = 0;

    area[0] = '\0';
    if (call_tgetent(buffer, name)) {
	size_t n;
	for (n = 0; n < sizeof(tbl) / sizeof(tbl[0]); ++n) {
	    char *value = dumpit(tbl[n], &ap);
	    if (value != 0) {
		vector[count++] = value;
	    }
	}
    }
    vector[count] = 0;
    report_one_size(buffer, count, area, (int) (ap - area));
    return make_list(vector);
}

static char **
dump_by_name(char *name)
{
    char **result = 0;

    if (b_opt > 0) {
	result = brute_force(name);
    } else if (b_opt == 0) {
	result = conventional(name);
    } else {
	char buffer[MAXBUF];
	(void) call_tgetent(buffer, name);
    }

    return result;
}

static void
dump_one(char *name)
{
    char **result = dump_by_name(name);
    if (result) {
	printf("Terminal type %s\n", name);
	show_list(result);
	free_list(result);
    }
}

static void
dump_entry(char *name, int *in_file, int *in_data, char ***last)
{
    char **list = dump_by_name(name);

    if (DumpIt || l_opt) {
	fflush(report);
    }

    if (*in_file) {
	if (DumpIt)
	    fprintf(output, "# vile:tcmode\n");
	*in_file = 0;
    }
    if (list) {
	if (*in_data) {
	    free_list(*last);
	    if (DumpIt) {
		fprintf(output, "%s:\\\n", name);
		show_list(list);
	    } else if (l_opt) {
		fprintf(output, "# %s\n", name);
	    }
	    *last = list;
	} else {
	    if (DumpIt) {
		fprintf(output, "# alias %s\n", name);
		if (list == 0) {
		    fprintf(output, "# (alias unknown)\n");
		} else if (!same_list(list, *last)) {
		    fprintf(output, "# (alias differs)\n");
		}
	    } else if (l_opt) {
		fprintf(output, "# alias %s\n", name);
	    }
	    free_list(list);
	}
    } else if (DumpIt || l_opt) {
	fprintf(output, "# %s %s (unknown)\n", *in_data ? "name" : "alias", name);
    }
    *in_data = 0;
}

/* the BSD termcaps contain a couple of instances where there is a dangling
 * escape before the next entry.  Detect that case (ncurses does).
 */
static int
is_beginning(char *buffer)
{
    int result = 0;
    if (isCapName(UCH(*buffer))) {
	int marker = 0;
	int ch;

	while ((ch = *buffer++) != '\0') {
	    if (isCapName(ch)) {
		++result;
	    } else if (ch == '|') {
		++result;
		marker = 1;
	    } else if (ch == ':') {
		if (result < 2)
		    result = 0;
		break;
	    } else if (!marker) {
		break;
	    }
	}
    }
    return result;
}

static int
get_entry(FILE *fp, char *buffer, size_t length)
{
    static char current[MAXBUF];
    int result = 0;
    int escaped = 0;
    int reused = (*current != '\0');

    *buffer = '\0';

    if (!feof(fp)) {
	size_t have;
	size_t skip = 0;

	while (reused || (fgets(current, (int) sizeof(current), fp) != 0)) {
	    reused = 0;
	    if (*current == '#') {
		*current = '\0';
		continue;
	    }
	    have = strlen(current);
	    if (escaped) {
		for (skip = 0;
		     (current[skip] == '\t') || (current[skip] == ' ');
		     ++skip) {
		    ;
		}
	    }

	    if (have > 0) {
		if (current[have - 1] == '\n') {
		    current[--have] = '\0';
		}
	    }

	    if (escaped && !reused && is_beginning(current)) {
		/* will reuse 'current' on the next call */
		break;
	    }

	    if (have > 1
		&& current[have - 1] == '\\') {
		current[--have] = '\0';
		escaped = 1;
	    } else if (have == 0) {
		continue;
	    } else {
		escaped = 0;
	    }

	    if (strlen(buffer) + strlen(current + skip) + 2 < length)
		strcat(buffer, current + skip);
	    result++;
	    *current = '\0';

	    if (!escaped)
		break;
	}
    } else if (*current) {
	strcpy(buffer, current);
	*current = '\0';
    }

    return result;
}

static void
dump_all(int contents)
{
    char buffer[MAXBUF];
    FILE *fp = open_termcap_file();
    char **last = 0;
    int in_file = 1;

    while (get_entry(fp, buffer, sizeof(buffer)) != 0) {
	int in_data = 1;
	char *next = buffer;
	char *later = 0;
	char *value;

	if (s_opt) {
	    unsigned count = count_includes(buffer);
	    if (count) {
		total_include0++;
		if (count > 1) {
		    total_include1++;
		    if (count > largest_include) {
			largest_include = count;
		    }
		}
	    }
	}
	while ((value = strtok(next, "|")) != 0 && strchr(value, ':') == 0) {
	    if (contents) {
		if ((value == buffer) && (strlen(value) == 2)) {
		    later = value;
		} else {
		    dump_entry(value, &in_file, &in_data, &last);
		}
	    } else if (DumpIt || l_opt) {
		fflush(report);
		fprintf(output, "# %s %s\n", next ? "name" : "alias", value);
	    }
	    next = 0;
	}
	if (contents && later) {
	    dump_entry(later, &in_file, &in_data, &last);
	}
    }
    free_list(last);
    fclose(fp);
}

static void
usage(void)
{
    static const char *tbl[] =
    {
	"Usage: tctest",
	"",
	"Options:",
	"  -a        show capabilities for all names in termcap file",
	"  -b        use brute-force to find all capabilities",
	"  -c        use conventional capabilities (default)",
	"  -e        use $TERMCAP variable if it exists",
	"  -f NAME   use this termcap file",
	"  -l        list names and aliases in termcap file",
	"  -n        do not lookup capabilities, only call tgetent",
	"  -o NAME   write to this termcap-like file",
	"  -r COUNT  repeat the tgetent, etc., process this many times",
	"  -s        report summary statistics for each input file",
	"  -v        verbose (prints names to stderr to track tgetent calls),",
	"            repeat to get statistics and buffer content",
	"  -w        show warnings",
	"  -V        print the program version and exit"
    };
    size_t n;
    for (n = 0; n < sizeof(tbl) / sizeof(tbl[0]); ++n) {
	fprintf(stderr, "%s\n", tbl[n]);
    }
    exit(EXIT_FAILURE);
}

int
main(int argc, char *argv[])
{
    int ch;
    int n;
    char *name;

    output = stdout;
    report = stderr;
    while ((ch = getopt(argc, argv, "abcef:lno:r:svwV")) != -1) {
	switch (ch) {
	case 'a':
	    a_opt = 1;
	    break;
	case 'b':
	    b_opt = 1;
	    break;
	case 'c':
	    b_opt = 0;
	    break;
	case 'e':
	    e_opt = 1;
	    break;
	case 'f':
	    f_opt = optarg;
	    break;
	case 'l':
	    l_opt = 1;
	    break;
	case 'n':
	    b_opt = -1;
	    break;
	case 'o':
	    output = fopen(optarg, "w");
	    if (output == 0)
		failed(optarg);
	    report = stdout;
	    break;
	case 'r':
	    r_opt = atoi(optarg);
	    break;
	case 's':
	    s_opt = 1;
	    break;
	case 'v':
	    v_opt++;
	    break;
	case 'w':
	    w_opt++;
	    break;
	case 'V':
	    printf("tctest - %d\n", VERSION);
	    exit(EXIT_SUCCESS);
	default:
	    usage();
	}
    }

    /*
     * If we are really linked to the (n)curses library, ask it to leave
     * the lines/columns values alone.
     */
#ifdef HAVE_USE_ENV
    use_env(0);
#endif
#ifdef HAVE_LIBNCURSES
    use_extended_names(1);
#endif

    /*
     * (n)curses may use $CC to modify data; suppress that.
     */
    my_unsetenv("CC");

    /*
     * Unless we are asking for the $TERMCAP variable, suppress it.
     */
    if (!e_opt) {
	my_unsetenv("TERMCAP");
    }

    if (r_opt <= 0)
	r_opt = 1;

    for (n = 0; n < r_opt; ++n) {
	if (f_opt) {
	    set_termcap_file(f_opt);
	}

	if (a_opt || l_opt || s_opt) {
	    if (optind < argc) {
		fprintf(stderr,
			"The -a,-l,-s options conflict with explicit names\n");
		usage();
	    }
	    dump_all(a_opt || s_opt);
	} else if (optind < argc) {
	    for (n = optind; n < argc; ++n) {
		dump_one(argv[n]);
	    }
	} else if ((name = getenv("TERM")) != 0) {
	    dump_one(name);
	} else {
	    static char dumb[] = "dumb";
	    dump_one(dumb);
	}
    }

    if (s_opt) {
	fflush(output);
	fprintf(report, "FILE %s\n", find_termcap_file());
	fprintf(report, "%6u calls to tgetent\n", total_entries);
	if (total_entries) {
	    fprintf(report, "%6u total names+aliases\n", total_aliases);
	    fprintf(report, "%6u total size\n", total_tgetent);
	    fprintf(report, "%6u total waste\n", total_wasted0);
	    fprintf(report, "%6u largest size\n", largest_entry);
	    fprintf(report, "%6u total too large\n", total_toobig0);
	    fprintf(report, "%6u total too large w/o waste\n", total_toobig1);
	    fprintf(report, "%6u total using tc=\n", total_include0);
	    fprintf(report, "%6u total using multiple tc='s\n", total_include1);
	    fprintf(report, "%6u maximum number of tc='s\n", largest_include);
	    fprintf(report, "%6u number of unresolved tc='s\n", unknown_include);
	    fprintf(report, "%6u library failures\n", total_failure);
	    fprintf(report, "%6u tctest warnings\n", total_warning);
	}
	fflush(report);
    }

    if (output != stdout)
	fclose(output);

#ifdef NO_LEAKS
#ifdef HAVE__NC_LEAKS_TIC
    _nc_leaks_tic();
#endif
#ifdef HAVE__NC_FREEALL
    _nc_freeall();
#endif
#endif /* NO_LEAKS */

    exit(EXIT_SUCCESS);
}
