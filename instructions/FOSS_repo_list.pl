@ENTRIES = (
   { name => "ant-1.7.0-ziputil-patched",            },
   { name => "ant-tar-patched",                      },
   { name => "junixsocket",                         tag    => "junixsocket-parent-2.0.4", remote => "gh-ks",},
   { name => "nekohtml-1.9.13",                      },
   { name => "java-html-sanitizer-release-20190610.1",remote => "zm-ow",},
   { name => "antisamy", remote => "zm-ow",          },
   { name => "zm-clientuploader-store",              },
   { name => "zm-downloads",                         },
   { name => "zm-ldap-utilities",                    },
   { name => "zm-licenses",                          },
   { name => "zm-mailbox",                           },
   { name => "zm-migration-tools",                   },
   { name => "zm-pkg-tool",                          },
   { name => "zm-ssdb-ephemeral-store",              },
      # zm-timezones repo can be removed and made independent of zm-zextras
      # zm-timezones cannot be done unless the packages from it are pushed to public repo
      # zm-timezones is already excluded in CircleCI builds via --exclude-git-repo=...
   { name => "zm-timezones",                         },
   { name => "zm-versioncheck-store",                },
   { name => "zm-versioncheck-utilities",            },
   { name => "zm-zcs",                               },
   { name => "zm-zcs-lib",                           },
);
