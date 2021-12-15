@ENTRIES = (
   { name => "ant-tar-patched",                      },
   { name => "zm-pkg-tool",                          },
      # zm-timezones repo can be removed and made independent of zm-zextras
      # zm-timezones cannot be done unless the packages from it are pushed to public repo
      # zm-timezones is already excluded in CircleCI builds via --exclude-git-repo=...
   { name => "zm-versioncheck-utilities",            },
   { name => "zm-zcs",                               },
);
