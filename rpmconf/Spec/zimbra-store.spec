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
requires: zimbra-core, zimbra-store-components, zimbra-jetty-distribution >= 9.4.18.v20190429-2, zimbra-webclient-portal-example, zimbra-help, zimbra-jetty-conf, zimbra-taglib, zimbra-gql, zimbra-clam-scanner-store, zimbra-oauth-social, zimbra-zimlets, zimbra-bulkprovision-admin-zimlet, zimbra-certificate-manager-admin-zimlet, zimbra-helptooltip-zimlet, zimbra-clientuploader-admin-zimlet, zimbra-versioncheck-admin-zimlet, zimbra-proxy-config-admin-zimlet, zimbra-helptooltip-zimlet, zimbra-nginx-lookup-store
Requires: zimbra-openid-consumer-store
Requires: zimbra-viewmail-admin-zimleton@@MORE_DEPENDS@@

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
