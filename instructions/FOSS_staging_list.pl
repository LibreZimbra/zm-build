@ENTRIES = (
   {
      "dir"             => "zm-mailbox",
      "ant_targets"     => ["pkg-after-plough-through-tests"],
      "deploy_pkg_into" => "bundle",
      "stage_cmd"       => sub {
         SysExec("mkdir -p                                 $CFG{BUILD_DIR}/zm-mailbox/store-conf/");
         SysExec("rsync -az store-conf/conf                $CFG{BUILD_DIR}/zm-mailbox/store-conf/");
         SysExec("install -T -D store/build/dist/versions-init.sql $CFG{BUILD_DIR}/zm-mailbox/store/build/dist/versions-init.sql");
      },
   },
   {
      "dir"         => "zm-mailbox/store",
      "ant_targets" => ["publish-store-test"],
      "stage_cmd"   => undef,
   },
   {
      # This repo can be removed and made independent of zm-zextras
      # This cannot be done unless the packages from zm-timezones are pushed to public repo
      # This is already excluded in CircleCI builds
      "dir"             => "zm-timezones",
      "ant_targets"     => ["pkg"],
      "deploy_pkg_into" => "bundle",
   },
   {
      "dir"         => "junixsocket/junixsocket-native",
      "mvn_targets" => ["package"],
      "stage_cmd"   => sub {
         SysExec("mkdir -p $CFG{BUILD_DIR}/junixsocket/junixsocket-native/build");
         SysExec("cp -f target/nar/junixsocket-native-*/lib/*/jni/libjunixsocket-native-*.so $CFG{BUILD_DIR}/junixsocket/junixsocket-native/build/");
         SysExec("cp -f target/junixsocket-native-*.nar  $CFG{BUILD_DIR}/junixsocket/junixsocket-native/build/");
      },
   },
   {
      "dir"         => "zm-ldap-utilities",
      "package"     => "zimbra-ldap",
      "stage_cmd"   => undef,
   },
   {
      "dir"         => "zm-ssdb-ephemeral-store",
      "ant_targets" => ["publish-local"],
      "stage_cmd"   => sub {
         SysExec("mkdir -p $CFG{BUILD_DIR}/zm-ssdb-ephemeral-store/build/dist");
         SysExec("cp -f build/zm-ssdb-ephemeral-store*.jar $CFG{BUILD_DIR}/zm-ssdb-ephemeral-store/build/dist");
      },
   },
   {
      "dir"         => "zm-openid-consumer-store",
      "ant_targets" => ["dist-package"],
      "stage_cmd"   => sub {
         SysExec("mkdir -p $CFG{BUILD_DIR}/zm-openid-consumer-store/build/dist");
         SysExec("cp -f -r build/dist $CFG{BUILD_DIR}/zm-openid-consumer-store/build/");
      },
   },
   {
      "dir"         => "zm-licenses",
      "ant_targets" => undef,
      "stage_cmd"   => sub {
         SysExec("mkdir -p $CFG{BUILD_DIR}/zm-licenses");
         SysExec("(cd .. && rsync -az --relative zm-licenses/ $CFG{BUILD_DIR}/)");
      },
   },
   {
      "dir"         => "zm-nginx-lookup-store",
      "ant_targets" => ["publish-local"],
      "stage_cmd"   => sub {
         SysExec("mkdir -p $CFG{BUILD_DIR}/zm-nginx-lookup-store/build/dist");
         SysExec("cp -f -rp build/zm-nginx-lookup-store-*.jar $CFG{BUILD_DIR}/zm-nginx-lookup-store/build/dist");
      },
   },
   {
      "dir"         => "zm-versioncheck-admin-zimlet",
      "ant_targets" => ["package-zimlet"],
      "stage_cmd"   => sub {
         SysExec("mkdir -p $CFG{BUILD_DIR}/zm-versioncheck-admin-zimlet/build/zimlet");
         SysExec("cp -f build/zimlet/*.zip $CFG{BUILD_DIR}/zm-versioncheck-admin-zimlet/build/zimlet");
      },
   },
   {
      "dir"         => "zm-bulkprovision-admin-zimlet",
      "ant_targets" => ["package-zimlet"],
      "stage_cmd"   => sub {
         SysExec("mkdir -p $CFG{BUILD_DIR}/zm-bulkprovision-admin-zimlet/build/zimlet");
         SysExec("cp -f build/zimlet/*.zip $CFG{BUILD_DIR}/zm-bulkprovision-admin-zimlet/build/zimlet");
      },
   },
   {
      "dir"         => "zm-certificate-manager-admin-zimlet",
      "ant_targets" => ["package-zimlet"],
      "stage_cmd"   => sub {
         SysExec("mkdir -p $CFG{BUILD_DIR}/zm-certificate-manager-admin-zimlet/build/zimlet");
         SysExec("cp -f build/zimlet/*.zip $CFG{BUILD_DIR}/zm-certificate-manager-admin-zimlet/build/zimlet");
      },
   },
   {
      "dir"         => "zm-clientuploader-admin-zimlet",
      "ant_targets" => ["package-zimlet"],
      "stage_cmd"   => sub {
         SysExec("mkdir -p $CFG{BUILD_DIR}/zm-clientuploader-admin-zimlet/build/zimlet");
         SysExec("cp -f build/zimlet/*.zip $CFG{BUILD_DIR}/zm-clientuploader-admin-zimlet/build/zimlet");
      },
   },
   {
      "dir"         => "zm-proxy-config-admin-zimlet",
      "ant_targets" => ["package-zimlet"],
      "stage_cmd"   => sub {
         SysExec("mkdir -p $CFG{BUILD_DIR}/zm-proxy-config-admin-zimlet/build/zimlet");
         SysExec("cp -f build/zimlet/*.zip $CFG{BUILD_DIR}/zm-proxy-config-admin-zimlet/build/zimlet");
      },
   },
   {
      "dir"         => "zm-helptooltip-zimlet",
      "ant_targets" => ["package-zimlet"],
      "stage_cmd"   => sub {
         SysExec("mkdir -p $CFG{BUILD_DIR}/zm-helptooltip-zimlet/build/zimlet");
         SysExec("cp -f build/zimlet/*.zip $CFG{BUILD_DIR}/zm-helptooltip-zimlet/build/zimlet");
      },
   },
   {
      "dir"         => "zm-viewmail-admin-zimlet",
      "ant_targets" => ["package-zimlet"],
      "stage_cmd"   => sub {
         SysExec("mkdir -p $CFG{BUILD_DIR}/zm-viewmail-admin-zimlet/build/zimlet");
         SysExec("cp -f build/zimlet/*.zip $CFG{BUILD_DIR}/zm-viewmail-admin-zimlet/build/zimlet");
      },
   },
   {
      "dir"         => "zm-zimlets",
      "ant_targets" => [ "package-zimlets", "jar" ],
      "stage_cmd"   => sub {
         SysExec("mkdir -p $CFG{BUILD_DIR}/zm-zimlets/conf");
         SysExec("cp -f conf/zimbra.tld $CFG{BUILD_DIR}/zm-zimlets/conf");
         SysExec("cp -f conf/web.xml.production $CFG{BUILD_DIR}/zm-zimlets/conf");
         SysExec("mkdir -p $CFG{BUILD_DIR}/zm-zimlets/build/dist/zimlets");
         SysExec("cp -f build/dist/zimlets/*.zip $CFG{BUILD_DIR}/zm-zimlets/build/dist/zimlets");
         SysExec("mkdir -p $CFG{BUILD_DIR}/zm-zimlets/build/dist");
         SysExec("cp -f build/dist/lib/zimlettaglib.jar $CFG{BUILD_DIR}/zm-zimlets/build/dist/zimlettaglib.jar");
      },
   },
   {
      "dir"         => "zm-versioncheck-utilities",
      "ant_targets" => undef,
      "stage_cmd"   => sub {
         SysExec("(cd .. && rsync -az --relative zm-versioncheck-utilities/src/libexec/zmcheckversion $CFG{BUILD_DIR}/)");
      },
   },
   {
      "dir"         => "zm-downloads",
      "ant_targets" => undef,
      "stage_cmd"   => sub {
         SysExec("cp -f -r ../zm-downloads $CFG{BUILD_DIR}");
      },
   },
   {
      "dir"         => "zm-migration-tools",
      "ant_targets" => undef,
      "stage_cmd"   => sub {
         SysExec("cp -f -r ../zm-migration-tools $CFG{BUILD_DIR}");
      },
   },
   {
      "dir"         => "zm-bulkprovision-store",
      "ant_targets" => ["jar"],
      "stage_cmd"   => sub {
         SysExec("mkdir -p $CFG{BUILD_DIR}/zm-bulkprovision-store");
         SysExec("cp -f -r ../zm-bulkprovision-store/build $CFG{BUILD_DIR}/zm-bulkprovision-store");
      },
   },
   {
      "dir"         => "zm-certificate-manager-store",
      "ant_targets" => ["jar"],
      "stage_cmd"   => sub {
         SysExec("mkdir -p $CFG{BUILD_DIR}/zm-certificate-manager-store");
         SysExec("cp -f -r ../zm-certificate-manager-store/build $CFG{BUILD_DIR}/zm-certificate-manager-store");
      },
   },
   {
      "dir"         => "zm-clientuploader-store",
      "ant_targets" => ["jar"],
      "stage_cmd"   => sub {
         SysExec("mkdir -p $CFG{BUILD_DIR}/zm-clientuploader-store");
         SysExec("cp -f -r ../zm-clientuploader-store/build $CFG{BUILD_DIR}/zm-clientuploader-store");
      },
   },
   {
      "dir"         => "zm-versioncheck-store",
      "ant_targets" => ["jar"],
      "stage_cmd"   => sub {
         SysExec("mkdir -p $CFG{BUILD_DIR}/zm-versioncheck-store");
         SysExec("cp -f -r ../zm-versioncheck-store/build $CFG{BUILD_DIR}/zm-versioncheck-store");
      },
   },
   {
      "dir"         => "ant-1.7.0-ziputil-patched",
      "ant_targets" => ["jar"],
      "stage_cmd"   => undef,
   },
   {
      "dir"         => "ant-tar-patched",
      "ant_targets" => ["jar"],
      "stage_cmd"   => undef,
   },
   {
      "dir"         => "nekohtml-1.9.13",
      "ant_targets" => ["jar"],
      "stage_cmd"   => undef,
   },
   {
      "dir"         => "java-html-sanitizer-release-20190610.1",
      "ant_targets" => ["jar"],
      "stage_cmd"   => undef,
   },
   {
      "dir"         => "antisamy",
      "ant_targets" => ["jar"],
      "stage_cmd"   => undef,
   },
   {
      "dir"         => "ical4j-0.9.16-patched",
      "ant_targets" => [ "clean-compile", "package" ],
      "stage_cmd"   => undef,
   },
   {
      "dir"         => "zm-zcs-lib",
      "ant_targets" => ["dist", "pkg"],
      "stage_cmd"   => sub {
         SysExec("(cd .. && rsync -az --relative zm-zcs-lib $CFG{BUILD_DIR}/)");
      },
      "deploy_pkg_into" => "bundle",
   },
);
