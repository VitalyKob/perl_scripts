# perl_scripts
 #!/usr/bin/perl
###############################################################################
#
# gethostinfo.pl  Retrieves all relevant information about the host, hardware
#                 OS, network, etc... for inventory/documentation purposes.
#                 The actual information is gather by module scripts.
#
#
# Change Log:     See CHANGELOG file.
# Usage:          See usage() function definition below.
#
###############################################################################
use strict;
use warnings;
use English;
##### Perl Modules
use File::Basename;
use Cwd 'abs_path';
use Sys::Hostname;
use Net::Domain qw(hostdomain domainname hostfqdn);;
use Getopt::Long;
use File::Temp;
use Data::Dumper;
 ##### Globals
our $ScriptName = basename(__FILE__);
our $ScriptDir = abs_path(dirname(__FILE__));
our $Hostname = hostname();
our $HostnameShort = `hostname -s`; chomp $HostnameShort;$HostnameShort =~ s/^\s+(\S+)\s+$/$1/;
our $Domain = hostdomain;
our $FQDN = hostfqdn;
#our $IP = `hostname -i`; chomp $IP; ## not consistent (see Ubuntu)
our $Site='N/A';
if($Domain =~ /(mo\.ca\.am\.ericsson\.se|lmc\.ericsson\.se)/)
{
   $Site = 'camo';
}
if($Domain =~ /camt\.gic\.ericsson\.se/)
{
   $Site = 'camt';
}
our $Who = getpwuid($UID);
our $Title;
our $ModulesDirectory="$ScriptDir/modules.d";
 ##### Main
 ## Get time
our $Now = time();
my($Seconds,$Minutes,$Hour,$Day,$Month,$Year,undef)=localtime($Now);
$Year += 1900; $Month = sprintf("%02d",$Month+1);
$Day = sprintf("%02d",$Day); $Hour = sprintf("%02d",$Hour);
$Minutes=sprintf("%02d",$Minutes);$Seconds = sprintf("%02d",$Seconds);
our $NowTS = "${Year}${Month}${Day}_${Hour}${Minutes}${Seconds}";
our $NowNice = "${Year}-${Month}-${Day} ${Hour}h${Minutes}m${Seconds}s";
 ### Command line options
our ($Help,$CleanOut,$Debug);
 $Help = 0;
$CleanOut = 0;
$Debug = 0;
 # NOTE: parameters including ":" instead of "=" are optional. '+' increments
GetOptions(
   "h|help+"         => \$Help,
   "c|clean-output+" => \$CleanOut,
   "d|debug+"        => \$Debug
);

### Print Usage Help
usage() if ($Help);
our %Colors;
if($CleanOut)
