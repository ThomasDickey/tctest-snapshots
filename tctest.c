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
 * $Id: tctest.c,v 1.28 2011/07/30 20:28:10 tom Exp $
 *
 * A simple demo of the termcap interface.
 *
 * TODO: if using ncurses, attempt to link with libtic to allow reformatting
 * TODO: option -E for setting $TERMCAP based on file's contents
 * TODO: option -L for listing size with tc's included (store file in memory).
 * TODO: option -e for testing the $TERMCAP variable
 * TODO: option -i for testing internal features such as escaping
 * TODO: option -o for testing tputs for each string capability
 * TODO: option -s for testing growth of tgetstr buffer
 */
#include <config.h>

#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>

#include <signal.h>
#include <setjmp.h>

#if defined(USE_TERMINFO) && defined(HAVE__NC_INFOTOCAP)
extern char *_nc_infotocap(const char *, const char *, int const);
#define USE_LIBTIC 1
#endif

#ifdef HAVE_USE_ENV
#include <curses.h>
#endif

#ifdef HAVE_TERMCAP_H
#include <termcap.h>
#endif

#ifndef HAVE_TERMCAP_H
/* only the newer implementations provide prototypes */
extern int tgetflag(char *);
extern int tgetnum(char *);
extern int tgetent(char *, char *);
extern int tputs(char *, int, int (*)(int));
extern char *tgetstr(char *, char **);
#endif

extern void _nc_leaks_tic(void);
extern void _nc_freeall(void);

#ifndef NCURSES_CONST
#define NCURSES_CONST		/* nothing */
#endif

#define FCOLS 2
#define FNULL(type) "%s %-*s cancelled ", #type, FCOLS
#define FNAME(type) "%s %-*s = ", #type, FCOLS

#define isCapName(c) (isgraph(c) && strchr("^=:\\", c) == 0)

static int a_opt = 0;
static int b_opt = 0;
static int e_opt = 0;
static char *f_opt = 0;
static int l_opt = 0;
static int v_opt = 0;

static FILE *output;

static void
failed(const char *msg)
{
    perror(msg);
    exit(EXIT_FAILURE);
}

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
    char buffer[1024];

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
	++n;
	result = calloc(n, sizeof(char *));
	if (result != 0) {
	    for (n = 0; list[n] != 0; ++n) {
		result[n] = list[n];
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

    for (n = 0; a[n] != 0 && b[n] != 0; ++n) {
	if (strcmp(a[n], b[n])) {
	    result = 0;
	    break;
	}
    }
    if ((a[n] != 0) ^ (b[n] != 0)) {
	result = 0;
    }
    return result;
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
loadit(char *buffer, char *name)
{
    int result;

    if (v_opt)
	fprintf(stderr, "loading %s\n", name);
    setcatch(catcher);
    if (setjmp(my_jumper) != 0) {
	if (v_opt)
	    fprintf(stderr, "...failed %s\n", name);
	result = 0;
    } else {
	result = 0;
	buffer[0] = '\0';
	if (tgetent(buffer, name) >= 0) {
	    result = 1;
	}
	if (v_opt)
	    fprintf(stderr, "...loaded %s\n", name);
    }
    setcatch(SIG_DFL);
    return result;
}

static char *
dumpit(const char *cap, char **areap)
{
    char *capname = (NCURSES_CONST char *) cap;
    char *result = 0;
    char buffer[1024], *append = 0;
    char *str;
    int num;

    if ((str = tgetstr(capname, areap)) != 0) {
	char *cpy = 0;
#ifdef USE_LIBTIC
	char mybuf[4096];
	char *p, *q;
	/* _nc_infotocap() expects backslashes to be escaped */
	for (p = mybuf, q = str; *q != 0; ++q) {
	    int ch = *q;
	    if (ch == '\\')
		*p++ = '\\';
	    *p++ = *q;
	}
	*p = 0;
	cpy = _nc_infotocap(0, mybuf, 1);
	if (cpy != 0) {
	    if (v_opt > 3) {
		fprintf(stderr, "string %s\n", capname);
		fprintf(stderr, "< %s\n", str);
		fprintf(stderr, "> %s\n", cpy);
	    }
	    str = cpy;
	}
#endif
	if (str == (char *) -1) {
	    sprintf(buffer, "\t:%s@:", capname);
	} else {
	    sprintf(buffer, "\t:%s=", capname);
	    append = buffer + strlen(buffer);
	    while (*str != 0) {
		int ch = (unsigned char) (*str++);
		switch (ch) {
		case '\177':
		    strcpy(append, "^?");
		    break;
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
		case ' ':
		    strcpy(append, "\\s");
		    break;
		case '\t':
		    strcpy(append, "\\t");
		    break;
		case '^':
		    if (cpy == 0) {
			strcpy(append, "\\^");
		    } else {
			strcpy(append, "^");
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
			if (!strncmp(str, "136", 3)) {
			    strcpy(append, "\\^");
			    str += 3;
			} else if (!strncmp(str, "134", 3)) {
			    strcpy(append, "\\\\");
			    str += 3;
			} else {
			    sprintf(append, "\\%c", *str++);
			}
		    }
		    break;
		default:
		    if (isgraph(ch))
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
	    char *p;
	    int wasted = 0;
	    int buflen = (int) strlen(buffer);
	    /*
	     * The termcap library may strip out newlines, but leave
	     * unnecessary tabs and an extra colon.
	     */
	    for (p = buffer; *p; ++p) {
		if (*p == '\\') {
		    if ((*++p) == '\0')
			break;
		} else if (*p == ':') {
		    if (isspace(p[1])) {
			while (isspace(p[1])) {
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
	    fprintf(stderr, "\t%4d bytes total (%.1f%%)\n",
		    buflen, PCT(buflen, 1023));
	    if (wasted) {
		fprintf(stderr, "\t%4d wasted space (%.1f%%)\n",
			wasted, PCT(wasted, buflen));
	    }
	}
	fprintf(stderr, "\t%4d capabilities\n", count);
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
	    fprintf(stderr, "\t%4d strings\n", numstrings);
	    fprintf(stderr, "\t%4d bytes of strings\n", length);
	    if (wasted) {
		fprintf(stderr, "\t%4d wasted nulls\n", wasted);
	    }
	}
	if ((v_opt > 2) && (*buffer != '\0')) {
	    fprintf(stderr, "TERMCAP=%s\n", buffer);
	}
    }
}

static char **
brute_force(char *name)
{
    char buffer[4096];
    char *vector[1024];
    char area[4096], *ap = area;
    int count = 0;

    area[0] = '\0';
    if (loadit(buffer, name)) {
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
    report_one_size(buffer, count, area, ap - area);
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
    char buffer[4096];
    char area[4096], *ap = area;
    char *vector[1024];
    int count = 0;

    area[0] = '\0';
    if (loadit(buffer, name)) {
	size_t n;
	for (n = 0; n < sizeof(tbl) / sizeof(tbl[0]); ++n) {
	    char *value = dumpit(tbl[n], &ap);
	    if (value != 0) {
		vector[count++] = value;
	    }
	}
    }
    vector[count] = 0;
    report_one_size(buffer, count, area, ap - area);
    return make_list(vector);
}

static char **
dump_by_name(char *name)
{
    char **result = 0;

    if (b_opt) {
	result = brute_force(name);
    } else {
	result = conventional(name);
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

    if (*in_file) {
	fprintf(output, "# vile:tcmode\n");
	*in_file = 0;
    }
    if (list) {
	if (*in_data) {
	    fprintf(output, "%s:\\\n", name);
	    free_list(*last);
	    show_list(list);
	    *last = list;
	} else {
	    fprintf(output, "# alias %s\n", name);
	    if (!same_list(list, *last)) {
		fprintf(output, "# (alias differs)\n");
	    }
	    free_list(list);
	}
    } else {
	fprintf(output, "# %s %s\n", *in_data ? "name" : "alias", name);
    }
    *in_data = 0;
}

static void
dump_all(int contents)
{
    char buffer[1024];
    FILE *fp = open_termcap_file();
    char **last = 0;
    int in_file = 1;

    while (fgets(buffer, sizeof(buffer), fp) != 0) {
	int in_data = 1;
	char *next = buffer;
	char *later = 0;
	char *value;

	if (*buffer == '#' || isspace(*buffer))
	    continue;
	while ((value = strtok(next, "|")) != 0 && strchr(value, ':') == 0) {
	    if (contents) {
		if ((value == buffer) && (strlen(value) == 2)) {
		    later = value;
		} else {
		    dump_entry(value, &in_file, &in_data, &last);
		}
	    } else {
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
	"  -e        use $TERMCAP variable if it exists",
	"  -f NAME   use this termcap file",
	"  -l        list names and aliases in termcap file",
	"  -o NAME   write to this termcap-like file",
	"  -v        verbose (prints names to stderr to track tgetent calls),",
	"            repeat to get statistics and buffer content",
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
    while ((ch = getopt(argc, argv, "abef:lo:vV")) != -1) {
	switch (ch) {
	case 'a':
	    a_opt = 1;
	    break;
	case 'b':
	    b_opt = 1;
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
	case 'o':
	    output = fopen(optarg, "w");
	    if (output == 0)
		failed(optarg);
	    break;
	case 'v':
	    v_opt++;
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
     * Unless we are asking for the $TERMCAP variable, suppress it.
     */
    if (!e_opt) {
	unsetenv("TERMCAP");
    }

    if (f_opt) {
	set_termcap_file(f_opt);
    }

    if (a_opt || l_opt) {
	if (optind < argc) {
	    fprintf(stderr, "The -l option conflicts with explicit names\n");
	    usage();
	}
	dump_all(a_opt);
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
