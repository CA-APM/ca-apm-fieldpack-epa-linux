###
# EPAgent Plugin Framework Main file
# @Author -
###
BEGIN {
        $libFolder = $0;
        $libFolder =~ s/[a-zA-Z0-9]+.pl$/\.\.\/lib\/perl\/Core\//g;
        push ( @INC,"$libFolder");
}

###
# Pragmas
###
use strict;
use FindBin;
use lib ("$FindBin::Bin", "$FindBin::Bin/../lib/perl");
use Wily::EPAgentFunctions;


###
# Pass Config File
###
use File::Basename;
my $dirName = dirname(__FILE__);

while ( "true" ) {
###
# Read the Config File
###
my @metricArray = Wily::EPAgentFunctions::readConfigXML( $dirName . "/EPAgentConfig.xml");

my @resultsArray = ();
my $count = 0;
my @result = ();

###
# Execute the CommandFile from config File
# Format the Metric Value Map
###
foreach my $configMetricMap ( @metricArray ) {



        #my $dataType = $$configMetricMap{'WilyDataType'};
        my $commandFile = $$configMetricMap{'CommandFile'};
        my $WilyResourceName = $$configMetricMap{'WilyResourceName'};

        if (  "$WilyResourceName" eq "Process"  ) {
                        if ( ref($$configMetricMap{'ProcessNames'}) ne "HASH") {
                        @result = Wily::EPAgentFunctions::getSimpleProcessMetrics ( $$configMetricMap{'ProcessNames'}, $commandFile);
                }
        } else {
                @result = Wily::EPAgentFunctions::executeCommandFile ( $commandFile);
        }



}

$resultsArray[$count++] = Wily::EPAgentFunctions::formatMetricValue( @result);

###
# Publish the Metrics to EPAgent
###
Wily::EPAgentFunctions::publishMetrics( \@resultsArray );

Wily::EPAgentFunctions::clearResultsSet();

my $sleepTime = $Wily::EPAgentFunctions::sleepTime;

sleep ($sleepTime);
}


