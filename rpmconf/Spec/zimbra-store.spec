#
# spec file for zimbra.rpm
#
Summary: Zimbra Mail
Name: zimbra-store
Version: @@VERSION@@
Release: 1%{?dist}
License: ZPL and other
Group: Applications/Messaging
URL: http://www.zimbra.com
Vendor: Zimbra, Inc.
Packager: Zimbra, Inc.
BuildRoot: /opt/zimbra
AutoReqProv: no
requires: zimbra-core, zimbra-store-components, zimbra-jetty-distribution >= 9.4.18.v20190429-2, zimbra-webclient-portal-example, zimbra-help, zimbra-jetty-conf, zimbra-taglib, zimbra-admin-help-common@@MORE_DEPENDS@@

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
