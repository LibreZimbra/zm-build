@ENTRIES = (
   {
      "dir"         => "zm-versioncheck-utilities",
      "ant_targets" => undef,
      "stage_cmd"   => sub {
         SysExec("(cd .. && rsync -az --relative zm-versioncheck-utilities/src/libexec/zmcheckversion $CFG{BUILD_DIR}/)");
      },
   },
   {
      "dir"         => "ant-tar-patched",
      "ant_targets" => ["jar"],
      "stage_cmd"   => undef,
   },
);
