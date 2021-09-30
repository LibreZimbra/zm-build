#
# spec file for zimbra.rpm
#
Summary: Zimbra Core
Name: zimbra-core
Version: @@VERSION@@
Release: 1%{?dist}
License: Various
Group: Applications/Messaging
URL: http://www.zimbra.com
Vendor: Zimbra, Inc.
Packager: Zimbra, Inc.
BuildRoot: /opt/zimbra
AutoReqProv: no
Requires: zimbra-core-components, zimbra-core-utils, zimbra-ldap-utilities, zimbra-core, zimbra-freshclam, zimbra-mta-conf, zimbra-jython@@MORE_DEPENDS@@

%description
Best email money can buy

%define __spec_install_pre /bin/true

%define __spec_install_post /usr/lib/rpm/brp-compress /usr/lib/rpm/brp-strip-comment-note %{nil}

%prep

%build

%install

%pre

%post

%preun

%postun

%files
