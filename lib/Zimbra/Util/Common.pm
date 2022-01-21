#!/usr/bin/perl
# SPDX-License-Identifier: GPL-2.0-only

package Zimbra::Util::Common; 
use strict;


# Zimbra Specfic library locations
use lib "/opt/zimbra/common/lib/perl5";
use lib "/opt/zimbra/common/lib/perl5/Zimbra/SOAP";
use lib "/opt/zimbra/common/lib/perl5/Zimbra/Mon";
use lib "/opt/zimbra/common/lib/perl5/Zimbra/DB";
foreach my $arch (qw(i386 x86_64 i486 i586 i686 darwin)) {
  foreach my $type (qw(linux-thread-multi linux-gnu-thread-multi linux thread-multi thread-multi-2level)) {
    my $dir = "/opt/zimbra/common/lib/perl5/${arch}-${type}";
    unshift(@INC, "$dir") 
      if (-d "$dir");
  }
}

1
