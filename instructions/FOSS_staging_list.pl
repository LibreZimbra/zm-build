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
      "dir"         => "zm-licenses",
      "ant_targets" => undef,
      "stage_cmd"   => sub {
         SysExec("mkdir -p $CFG{BUILD_DIR}/zm-licenses");
         SysExec("(cd .. && rsync -az --relative zm-licenses/ $CFG{BUILD_DIR}/)");
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
      "dir"         => "zm-versioncheck-store",
      "ant_targets" => ["jar"],
      "stage_cmd"   => sub {
         SysExec("mkdir -p $CFG{BUILD_DIR}/zm-versioncheck-store");
         SysExec("cp -f -r ../zm-versioncheck-store/build $CFG{BUILD_DIR}/zm-versioncheck-store");
      },
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
);
