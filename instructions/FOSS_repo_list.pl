@ENTRIES = (
   { name => "ant-tar-patched",                      },
   { name => "nekohtml-1.9.13",                      },
   { name => "java-html-sanitizer-release-20190610.1",remote => "zm-ow",},
   { name => "antisamy", remote => "zm-ow",          },
   { name => "zm-mailbox",                           },
   { name => "zm-pkg-tool",                          },
      # zm-timezones repo can be removed and made independent of zm-zextras
      # zm-timezones cannot be done unless the packages from it are pushed to public repo
      # zm-timezones is already excluded in CircleCI builds via --exclude-git-repo=...
   { name => "zm-timezones",                         },
   { name => "zm-versioncheck-utilities",            },
   { name => "zm-zcs",                               },
);
