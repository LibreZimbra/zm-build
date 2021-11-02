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
Requires: zimbra-core
Requires: zimbra-store-components
Requires: zimbra-jetty-distribution >= 9.4.18.v20190429-2
Requires: zimbra-webclient-portal-example
Requires: zimbra-help
Requires: zimbra-jetty-conf
Requires: zimbra-taglib
Requires: zimbra-gql
Requires: zimbra-clam-scanner-store
Requires: zimbra-oauth-social
Requires: zimbra-zimlets
Requires: zimbra-bulkprovision-admin-zimlet
Requires: zimbra-certificate-manager-admin-zimlet
Requires: zimbra-helptooltip-zimlet
Requires: zimbra-clientuploader-admin-zimlet
Requires: zimbra-versioncheck-admin-zimlet
Requires: zimbra-proxy-config-admin-zimlet
Requires: zimbra-helptooltip-zimlet
Requires: zimbra-nginx-lookup-store
Requires: zimbra-openid-consumer-store
Requires: zimbra-clientuploader-store
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
