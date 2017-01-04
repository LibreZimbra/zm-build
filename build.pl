#!/usr/bin/perl

use strict;

use File::Basename;
use Data::Dumper;
use Cwd;

my $GLOBAL_PATH_TO_SCRIPT;
my $GLOBAL_PATH_TO_SCRIPT_DIR;
my $GLOBAL_PATH_TO_TOP;
my $GLOBAL_PATH_TO_BUILDS;

my $GLOBAL_BUILD_NO;
my $GLOBAL_BUILD_TS;
my $GLOBAL_BUILD_DIR;
my $GLOBAL_BUILD_OS;
my $GLOBAL_BUILD_RELEASE;
my $GLOBAL_BUILD_RELEASE_NO;
my $GLOBAL_BUILD_RELEASE_NO_SHORT;
my $GLOBAL_BUILD_RELEASE_CANDIDATE;
my $GLOBAL_BUILD_TYPE;
my $GLOBAL_BUILD_ARCH;
my $GLOBAL_THIRDPARTY_SERVER;


BEGIN
{
   $GLOBAL_PATH_TO_SCRIPT     = Cwd::abs_path(__FILE__);
   $GLOBAL_PATH_TO_SCRIPT_DIR = dirname($GLOBAL_PATH_TO_SCRIPT);
   $GLOBAL_PATH_TO_TOP        = dirname($GLOBAL_PATH_TO_SCRIPT_DIR);
}

chdir($GLOBAL_PATH_TO_TOP);

##############################################################################################

main();

##############################################################################################

sub main()
{
   InitGlobalBuildVars();
   Prepare();
   Checkout("public_repos.pl");
   Checkout("private_repos.pl") if ( $GLOBAL_BUILD_TYPE eq "NETWORK" );
   Build();
}

sub InitGlobalBuildVars()
{
   if ( -f "/tmp/last.build_no_ts" && $ENV{ENV_RESUME_FLAG} )
   {
      my $x = LoadProperties("/tmp/last.build_no_ts");

      $GLOBAL_BUILD_NO = $x->{BUILD_NO};
      $GLOBAL_BUILD_TS = $x->{BUILD_TS};
   }

   $GLOBAL_BUILD_NO ||= GetNewBuildNo();
   $GLOBAL_BUILD_TS ||= GetNewBuildTs();

   my $build_cfg = LoadProperties("$GLOBAL_PATH_TO_SCRIPT_DIR/build.config");

   $GLOBAL_PATH_TO_BUILDS          = $build_cfg->{PATH_TO_BUILDS}          || "$GLOBAL_PATH_TO_TOP/BUILDS";
   $GLOBAL_BUILD_RELEASE           = $build_cfg->{BUILD_RELEASE}           || die "not specified BUILD_RELEASE";
   $GLOBAL_BUILD_RELEASE_NO        = $build_cfg->{BUILD_RELEASE_NO}        || die "not specified BUILD_RELEASE_NO";
   $GLOBAL_BUILD_RELEASE_CANDIDATE = $build_cfg->{BUILD_RELEASE_CANDIDATE} || die "not specified BUILD_RELEASE_CANDIDATE";
   $GLOBAL_BUILD_TYPE              = $build_cfg->{BUILD_TYPE}              || die "not specified BUILD_TYPE";
   $GLOBAL_THIRDPARTY_SERVER       = $build_cfg->{THIRDPARTY_SERVER}       || die "not specified THIRDPARTY_SERVER";
   $GLOBAL_BUILD_OS                = GetBuildOS();
   $GLOBAL_BUILD_ARCH              = GetBuildArch();

   s/[.]//g for ( $GLOBAL_BUILD_RELEASE_NO_SHORT = $GLOBAL_BUILD_RELEASE_NO );

   $GLOBAL_BUILD_DIR = "$GLOBAL_PATH_TO_BUILDS/$GLOBAL_BUILD_OS/$GLOBAL_BUILD_RELEASE-$GLOBAL_BUILD_RELEASE_NO_SHORT/${GLOBAL_BUILD_TS}_$GLOBAL_BUILD_TYPE";

   my $cc    = DetectPrerequisite("cc");
   my $cpp   = DetectPrerequisite("c++");
   my $java  = DetectPrerequisite( "java", "$ENV{JAVA_HOME}/bin" );
   my $javac = DetectPrerequisite( "javac", "$ENV{JAVA_HOME}/bin" );
   my $mvn   = DetectPrerequisite("mvn");
   my $ant   = DetectPrerequisite("ant");
   my $ruby  = DetectPrerequisite("ruby");

   $ENV{JAVA_HOME} ||= dirname( dirname( Cwd::realpath($javac) ) );
   $ENV{PATH} = "$ENV{JAVA_HOME}/bin:$ENV{PATH}";

   print "=========================================================================================================\n";
   print "BUILD OS                      : $GLOBAL_BUILD_OS\n";
   print "BUILD ARCH                    : $GLOBAL_BUILD_ARCH\n";
   print "BUILD NO                      : $GLOBAL_BUILD_NO\n";
   print "BUILD TS                      : $GLOBAL_BUILD_TS\n";
   print "BUILD TYPE                    : $GLOBAL_BUILD_TYPE\n";
   print "BUILD RELEASE                 : $GLOBAL_BUILD_RELEASE\n";
   print "BUILD RELEASE NO              : $GLOBAL_BUILD_RELEASE_NO\n";
   print "BUILD RELEASE CANDIDATE       : $GLOBAL_BUILD_RELEASE_CANDIDATE\n";
   print "=========================================================================================================\n";

   foreach my $x (`grep -o '\\<[E][N][V]_[A-Z_]*\\>' $GLOBAL_PATH_TO_SCRIPT | sort | uniq`)
   {
      chomp($x);
      printf( "%-30s: %s\n", $x, defined $ENV{$x} ? $ENV{$x} : "(undef)" );
   }

   print "=========================================================================================================\n";
   print "USING javac                   : $javac (JAVA_HOME=$ENV{JAVA_HOME})\n";
   print "USING java                    : $java\n";
   print "USING maven                   : $mvn\n";
   print "USING ant                     : $ant\n";
   print "USING cc                      : $cc\n";
   print "USING c++                     : $cpp\n";
   print "USING ruby                    : $ruby\n";
   print "=========================================================================================================\n";
   print "PATH TO BUILDS                : $GLOBAL_PATH_TO_BUILDS\n";
   print "BUILD DIR                     : $GLOBAL_BUILD_DIR\n";
   print "=========================================================================================================\n";
   print "Press enter to proceed";
   my $x;
   read STDIN, $x, 1;
}

sub Prepare()
{
   system( "rm", "-rf", "$ENV{HOME}/.zcs-deps" )   if ( $ENV{ENV_CACHE_CLEAR_FLAG} );
   system( "rm", "-rf", "$ENV{HOME}/.ivy2/cache" ) if ( $ENV{ENV_CACHE_CLEAR_FLAG} );

   open( FD, ">", "/tmp/last.build_no_ts" );
   print FD "BUILD_NO=$GLOBAL_BUILD_NO\n";
   print FD "BUILD_TS=$GLOBAL_BUILD_TS\n";
   close(FD);

   System( "mkdir", "-p", "$GLOBAL_BUILD_DIR" );
   System( "mkdir", "-p", "$GLOBAL_BUILD_DIR/logs" );
   System( "mkdir", "-p", "$ENV{HOME}/.zcs-deps" );
   System( "mkdir", "-p", "$ENV{HOME}/.ivy2/cache" );

   my @TP_JARS = (
      "http://$GLOBAL_THIRDPARTY_SERVER/ZimbraThirdParty/third-party-jars/ant-1.7.0-ziputil-patched.jar",
      "http://$GLOBAL_THIRDPARTY_SERVER/ZimbraThirdParty/third-party-jars/ant-contrib-1.0b1.jar",
      "http://$GLOBAL_THIRDPARTY_SERVER/ZimbraThirdParty/third-party-jars/ews_2010-1.0.jar",
      "http://$GLOBAL_THIRDPARTY_SERVER/ZimbraThirdParty/third-party-jars/jruby-complete-1.6.3.jar",
      "http://$GLOBAL_THIRDPARTY_SERVER/ZimbraThirdParty/third-party-jars/plugin.jar",
      "http://$GLOBAL_THIRDPARTY_SERVER/ZimbraThirdParty/third-party-jars/servlet-api-3.1.jar",
      "http://$GLOBAL_THIRDPARTY_SERVER/ZimbraThirdParty/third-party-jars/unboundid-ldapsdk-2.3.5-se.jar",
      "http://$GLOBAL_THIRDPARTY_SERVER/ZimbraThirdParty/third-party-jars/zimbrastore-test-1.0.jar",
   );

   for my $j_url (@TP_JARS)
   {
      if ( my $f = "$ENV{HOME}/.zcs-deps/" . basename($j_url) )
      {
         if ( !-f $f )
         {
            System("wget '$j_url' -O '$f.tmp'");
            System("mv '$f.tmp' '$f'");
         }
      }
   }
}

sub Checkout($)
{
   my $repo_file = shift;

   if ( !-d "zimbra-package-stub" )
   {
      System( "git", "clone", "https://github.com/Zimbra/zimbra-package-stub.git" );
   }

   if ( !-d "junixsocket" )
   {
      System( "git", "clone", "-b", "junixsocket-parent-2.0.4", "https://github.com/kohlschutter/junixsocket.git" );
   }

   if ( -f "$GLOBAL_PATH_TO_TOP/zm-build/$repo_file" )
   {
      my @REPOS = ();
      eval `cat $GLOBAL_PATH_TO_TOP/zm-build/$repo_file`;
      die "FAILURE in $repo_file, (info=$!, err=$@)\n" if ($@);
      for my $repo_details (@REPOS)
      {
         Clone($repo_details);
      }
   }
}

sub Build()
{
   my @GLOBAL_BUILDS;
   eval `cat $GLOBAL_PATH_TO_TOP/zm-build/global_builds.pl`;
   die "FAILURE in global_builds.pl, (info=$!, err=$@)\n" if ($@);

   my $cnt = 0;
   for my $build_info (@GLOBAL_BUILDS)
   {
      ++$cnt;
      if ( my $dir = $build_info->{dir} )
      {
         print "=========================================================================================================\n";
         print "\e[1;34m" . "BUILDING: $build_info->{dir} ($cnt of " . scalar(@GLOBAL_BUILDS) . ")\e[0m\n";
         print "\n";

         unlink glob "$dir/.built.*"
           if ( $ENV{ENV_FORCE_REBUILD} && grep { $build_info->{dir} =~ /$_/ } split( ",", $ENV{ENV_FORCE_REBUILD} ) );

         if ( $ENV{ENV_RESUME_FLAG} && -f "$dir/.built.$GLOBAL_BUILD_TS" )
         {
            print "\e[1;33m" . "WARNING: SKIPPING - to force a rebuild - either delete $dir/.built.$GLOBAL_BUILD_TS or include in ENV_FORCE_REBUILD" . "\e[0m\n";
            print "=========================================================================================================\n";
            print "\n";
         }
         else
         {
            unlink glob "$dir/.built.*";

            Run(
               cd   => $dir,
               call => sub {

                  my $abs_dir = Cwd::abs_path();

                  if ( my $ant_targets = $build_info->{ant_targets} )
                  {
                     eval { System( "ant", "clean" ) if ( !$ENV{ENV_SKIP_CLEAN_FLAG} ); };

                     System( "ant", @$ant_targets );
                  }

                  if ( my $mvn_targets = $build_info->{mvn_targets} )
                  {
                     eval { System( "mvn", "clean" ) if ( !$ENV{ENV_SKIP_CLEAN_FLAG} ); };

                     System( "mvn", @$mvn_targets );
                  }

                  if ( my $stage_cmd = $build_info->{stage_cmd} )
                  {
                     &$stage_cmd
                  }
               },
            );

            if ( !exists $build_info->{partial} )
            {
               print "Creating $dir/.built.$GLOBAL_BUILD_TS\n";
               open( FD, "> $dir/.built.$GLOBAL_BUILD_TS" );
               close(FD);
            }

            print "\n";
            print "=========================================================================================================\n";
            print "\n";
         }
      }
   }

   Run(
      cd   => "zm-build",
      call => sub {
         System("(cd .. && rsync -az --delete zm-build $GLOBAL_BUILD_DIR/)");
         System("mkdir -p $GLOBAL_BUILD_DIR/zm-build/$GLOBAL_BUILD_ARCH");

         my @ALL_PACKAGES = ();
         push( @ALL_PACKAGES, @{ GetPackageList("public_packages.pl") } );
         push( @ALL_PACKAGES, @{ GetPackageList("private_packages.pl") } ) if ( $GLOBAL_BUILD_TYPE eq "NETWORK" );
         push( @ALL_PACKAGES, "zcs-bundle" );

         for my $package_script (@ALL_PACKAGES)
         {
            if ( !defined $ENV{ENV_PACKAGE_INCLUDE} || grep { $package_script =~ /$_/ } split( ",", $ENV{ENV_PACKAGE_INCLUDE} ) )
            {
               System(
                  "  release='$GLOBAL_BUILD_RELEASE_NO.$GLOBAL_BUILD_RELEASE_CANDIDATE' \\
                     branch='$GLOBAL_BUILD_RELEASE-$GLOBAL_BUILD_RELEASE_NO_SHORT' \\
                     buildNo='$GLOBAL_BUILD_NO' \\
                     os='$GLOBAL_BUILD_OS' \\
                     buildType='$GLOBAL_BUILD_TYPE' \\
                     repoDir='$GLOBAL_BUILD_DIR' \\
                     arch='$GLOBAL_BUILD_ARCH' \\
                     buildTimeStamp='$GLOBAL_BUILD_TS' \\
                     buildLogFile='$GLOBAL_BUILD_DIR/logs/build.log' \\
                     zimbraThirdPartyServer='$GLOBAL_THIRDPARTY_SERVER' \\
                        bash $GLOBAL_PATH_TO_TOP/zm-build/scripts/packages/$package_script.sh
                  "
               );
            }
         }
      },
   );

   print "\n";
   print "=========================================================================================================\n";
   print "\n";
}


sub GetPackageList($)
{
   my $package_list_file = shift;

   my @PACKAGES = ();

   if ( -f "$GLOBAL_PATH_TO_TOP/zm-build/$package_list_file" )
   {
      eval `cat $GLOBAL_PATH_TO_TOP/zm-build/$package_list_file`;
      die "FAILURE in $package_list_file, (info=$!, err=$@)\n" if ($@);
   }

   return \@PACKAGES;
}


sub GetNewBuildNo()
{
   my $line = 1000;

   if ( -f "/tmp/build_counter.txt" )
   {
      open( FD1, "<", "/tmp/build_counter.txt" );
      $line = <FD1>;
      close(FD1);

      $line += 2;
   }

   open( FD2, ">", "/tmp/build_counter.txt" );
   printf( FD2 "%s\n", $line );
   close(FD2);

   return $line;
}

sub GetNewBuildTs()
{
   chomp( my $x = `date +'%Y%m%d%H%M%S'` );

   return $x;
}

sub GetBuildOS()
{
   chomp( my $r = `$GLOBAL_PATH_TO_TOP/zm-build/rpmconf/Build/get_plat_tag.sh` );

   return $r
     if ($r);

   die "Unknown OS";
}

sub GetBuildArch()    # FIXME - use standard mechanism
{
   chomp( my $PROCESSOR_ARCH = `uname -m | grep -o 64` );

   my $b_os = GetBuildOS();

   return "amd" . $PROCESSOR_ARCH
     if ( $b_os =~ /UBUNTU/ );

   return "x86_" . $PROCESSOR_ARCH
     if ( $b_os =~ /RHEL/ || $b_os =~ /CENTOS/ );

   die "Unknown Arch"
}


##############################################################################################

sub Clone($)
{
   my $repo_details = shift;

   my $repo_name   = $repo_details->{name};
   my $repo_user   = $repo_details->{user};
   my $repo_branch = $repo_details->{branch};

   if ( !-d $repo_name )
   {
      System( "git", "clone", "-b", $repo_branch, "ssh://git\@stash.corp.synacor.com:7999/$repo_user/$repo_name.git" );
   }
   else
   {
      if ( !defined $ENV{ENV_GIT_UPDATE_INCLUDE} || grep { $repo_name =~ /$_/ } split( ",", $ENV{ENV_GIT_UPDATE_INCLUDE} ) )
      {
         print "#: Updating $repo_name...\n";

         chomp( my $z = `cd $repo_name && git pull origin` );

         print $z . "\n";

         if ( $z !~ /Already up-to-date/ )
         {
            System( "find", $repo_name, "-name", ".built.*", "-exec", "rm", "-f", "{}", ";" );
         }
      }
   }
}

sub System(@)
{
   print "#: @_            #(pwd=" . Cwd::getcwd() . ")\n";

   my $x = system @_;

   die "FAILURE in system, (info=$!, cmd='@_', ret=$x)\n"
     if ( $x != 0 );
}


sub LoadProperties($)
{
   my $f = shift;

   my $x = SlurpFile($f);

   my %h = map { split( /\s*=\s*/, $_, 2 ) } @$x;

   return \%h;
}


sub SlurpFile($)
{
   my $f = shift;

   open( FD, "<", "$f" ) || die "FAILURE in open, (info=$!, file='$f')\n";

   chomp( my @x = <FD> );
   close(FD);

   return \@x;
}


sub DetectPrerequisite($;$)
{
   my $util_name       = shift;
   my $additional_path = shift;

   chomp( my $detected_util = `PATH="$additional_path:\$PATH" \which "$util_name" 2>/dev/null | sed -e 's,//*,/,g'` );

   return $detected_util
     if ($detected_util);

   die "FAILURE: prerequisite $util_name missing in PATH\n";
}


sub Run(%)
{
   my %args  = (@_);
   my $chdir = $args{cd};
   my $call  = $args{call};

   my $child_pid = fork();

   die "FAILURE while forking, (info=$!)\n"
     if ( !defined $child_pid );

   if ( $child_pid != 0 )    # parent
   {
      while ( waitpid( $child_pid, 0 ) == -1 ) { }
      my $x = $?;

      die "FAILURE in run, (info=$!, ret=$x)\n"
        if ( $x != 0 );
   }
   else
   {
      chdir($chdir)
        if ($chdir);

      my $ret = &$call;
      exit($ret);
   }
}
