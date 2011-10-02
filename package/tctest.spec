Summary:  tctest - termcap library checker
%define AppProgram tctest
%define AppVersion 20111001
%define AppRelease 1
# $XTermId: tctest.spec,v 1.7 2011/10/01 14:14:32 tom Exp $
Name: %{AppProgram}
Version: %{AppVersion}
Release: %{AppRelease}
License: MIT
Group: Applications/Development
URL: ftp://invisible-island.net/%{AppProgram}
Source0: %{AppProgram}-%{AppVersion}.tgz
Packager: Thomas Dickey <dickey@invisible-island.net>

%description
The 'tctest' program makes several checks for syntax and other features of
a termcap library interface, e.g,. such as provided by ncurses.

%prep

%setup -q -n %{AppProgram}-%{AppVersion}

%build

INSTALL_PROGRAM='${INSTALL}' \
	./configure \
		--target %{_target_platform} \
		--prefix=%{_prefix} \
		--bindir=%{_bindir} \
		--libdir=%{_libdir} \
		--mandir=%{_mandir} \
		--with-ncurses

make

%install
[ "$RPM_BUILD_ROOT" != "/" ] && rm -rf $RPM_BUILD_ROOT

make install                    DESTDIR=$RPM_BUILD_ROOT

strip $RPM_BUILD_ROOT%{_bindir}/%{AppProgram}

%clean
[ "$RPM_BUILD_ROOT" != "/" ] && rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root)
%{_prefix}/bin/%{AppProgram}
%{_mandir}/man1/%{AppProgram}.*

%changelog
# each patch should add its ChangeLog entries here

* Sun Jul 24 2011 Thomas Dickey
- initial version
