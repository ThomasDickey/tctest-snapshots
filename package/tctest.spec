Summary:  Termcap library checker
%define AppProgram tctest
%define AppVersion 20240429
%define AppRelease 1
# $XTermId: tctest.spec,v 1.16 2024/04/29 19:10:44 tom Exp $
Name: %{AppProgram}
Version: %{AppVersion}
Release: %{AppRelease}
License: MIT
Group: Applications/Development
Packager: Thomas Dickey <dickey@invisible-island.net>
URL: https://invisible-island.net/%{AppProgram}
Source0: https://invisible-island.net/archives/%{AppProgram}-%{AppVersion}.tgz

%description
The 'tctest' program makes several checks for syntax and other features of
a termcap library interface, e.g,. such as provided by ncurses.

%prep

%setup -q -n %{AppProgram}-%{AppVersion}

%build

INSTALL_PROGRAM='${INSTALL}' \
%configure \
	--target %{_target_platform} \
	--prefix=%{_prefix} \
	--bindir=%{_bindir} \
	--libdir=%{_libdir} \
	--mandir=%{_mandir} \
	--with-ncurses

make

%install
[ "$RPM_BUILD_ROOT" != "/" ] && rm -rf $RPM_BUILD_ROOT

make install DESTDIR=$RPM_BUILD_ROOT

%files
%defattr(-,root,root)
%{_prefix}/bin/%{AppProgram}
%{_mandir}/man1/%{AppProgram}.*

%changelog
# each patch should add its ChangeLog entries here

* Mon Apr 29 2024 Thomas Dickey
- linted

* Sun Jul 24 2011 Thomas Dickey
- initial version
