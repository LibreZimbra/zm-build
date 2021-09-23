#
# spec file for zimbra.rpm
#
Summary: Zimbra LDAP
Name: zimbra-ldap
Version: @@VERSION@@
Release: 1%{?dist}
License: OpenLDAP
Group: Applications/Messaging
URL: http://www.zimbra.com
Vendor: Zimbra, Inc.
Packager: Zimbra, Inc.
BuildRoot: /opt/zimbra
AutoReqProv: no
Requires: zimbra-core
Requires: zimbra-ldap-base, zimbra-lmdb >= 2.4.59-1zimbra8.8b4.el8
Requires: zimbra-openldap-server >= 2.4.59-1zimbra8.8b4.el8
Requires: zimbra-openssl >= 1.1.1k-1zimbra8.7b4.el8, zimbra-openssl-libs >= 1.1.1k-1zimbra8.7b4.el8
Requires: zimbra-core-components >= 3.0.8-1zimbra8.8b1.el8

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
