#
# spec file for zimbra.rpm
#
Summary: Zimbra QA Tests
Name: zimbra-qatest
Version: @@VERSION@@
Release: 1%{?dist}
License: ZPL
Group: Applications/Messaging
URL: http://www.zimbra.com
Vendor: Zimbra, Inc.
Packager: Zimbra, Inc.
BuildRoot: /opt/zimbra
AutoReqProv: no
requires: zimbra-core

%description
Best email money can buy

%define __spec_install_pre /bin/true

%prep

%build

%install

%pre

%post

%preun

%postun

%files
