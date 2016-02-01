###
# EPAgent Plugin Framework Functions file
# @Author - Srikant @snoorani@empowered.ca
###

#BEGIN {
    #push ( @INC,"../Core/");
    #push ( @INC,"../Core/XML/");
    #push ( @INC,"../Core/XML/Parser/");
#}

package Wily::EPAgentFunctions;

use strict;


###
# Modules
###
use XML::Simple;
#use XML::Parser;
#use XML::Parser::Expat;
use Data::Dumper;


###
# Variable that has all the metricPath, value pair
# for the framework
###
our @resultsSet = ();

sub MetricData {
        my $class;

        bless {
            "dataType"    => shift,
            "metricName"    => shift,
            "value"    => shift

        }, $class;
}

###
# Global Map to hold prev metric value - used in Delta calc
###
our %pathToPrevValueMap = ();

###
# Sleep Time Variable
###

our $sleepTime = 10;

###
# Read config xml file
# Return array of Hashes containing
# <Metric> tags
###
sub readConfigXML {

        my @metricArray = ();

        # read XML file as an array
        my $xml = new XML::Simple (ForceArray=>1);
        my $data = $xml->XMLin(@_[0]);

	$sleepTime = $data->{OS}[0]{SleepTimeInSec};
	
        #For each metric in metrics
        foreach my $metric  (@{$data->{OS}[0]{"Metrics"}[0]{"Metric"}}) {

                my %metricMap = ();

                #For each element in metric
                while ( (my $key, my $value )= each( %$metric)) {

                         $metricMap{$key} = @$value[0];
                }

                push @metricArray, \%metricMap;
        }

        return @metricArray;
}


###
# Publish metrics to std Out
###
sub publishMetrics {
        #array of arracy
        my $resultsArrayOfArray = @_[0];

        foreach my $resultsArray1 (@$resultsArrayOfArray ) {

                foreach my $result (@$resultsArray1 ) {
                       print $result, "\n";
                }
        }
}

###
# addToResultsSet: Utility to add to RS
###
sub addToResultsSet{
        my $dataType = @_[0];
        my $metricName = @_[1];
        my $metricValue = @_[2];

        my $metricData = MetricData(@_[0], @_[1], @_[2]);
        push(@resultsSet, $metricData);


}


###
# Executes User commands from User Specified File
###
sub executeCommandFile {

        my $fileName = @_[0];

        #print "$filename srikant\n";
        require $fileName;

        $fileName =~ s/\.pl//;
        $fileName =~ s/^(.*)\///;

        $fileName->getUserMetrics();

        return @resultsSet;
}

sub getSimpleProcessMetrics {

        my @processNameArray = split (/,/,@_[0]);
        #my $processCmd = 'ps auxx |grep -v grep | grep -e ' ;

                my $processCmd = 'ps auxx |grep -v grep | grep ' ;

        my $fileName = @_[1];

        require $fileName;

        $fileName =~ s/\.pl//;
        $fileName =~ s/^(.*)\///;

        #$processCmd = $processCmd . " " . $processNames;

        foreach my $processName ( @processNameArray ) {
                $processName =~ s/^\s+//g;
                $processName =~ s/\s+$//g;
                $processCmd = $processCmd . " -e \"" . $processName . "\"";
        }

        my @processResults = `$processCmd`;

        #print "$processCmd";

        my %processInfo = ();
        my %nameValuePair = ();

        foreach my $processName (@processNameArray) {
                $processName =~ s/^\s+//g;
                                $processName =~ s/\s+$//g;
                                $nameValuePair{"Process|".$processName.":Availability"} = 0;

                                foreach my $line (@processResults) {
                                        my @fields = split (/\s+/,$line);

                        if ( $line =~ m/$processName/){
                                addToResultsSet ("LongCounter", "Process|".$processName.":CPU % Used", $fields[2] );
                                addToResultsSet ("LongCounter", "Process|".$processName.":Memory % Used", $fields[3] );
                                addToResultsSet ("LongCounter", "Process|".$processName.":Availability","1" );

                                $nameValuePair{"Process|".$processName.":Availability"} = 1;

                        }
                }
        }

        while ( (my $key, my $value )= each( %nameValuePair)) {
                if ( $value == 0 ) {
                        addToResultsSet("LongCounter", $key, "0" );
                }
        }

        return @resultsSet;
}


###
# Validate Metric String to Conform to Wily Stnd
###
sub validateMetricString {

        return @_[0];
}

###
# Validate Metric Value to Conform to Wily Stnd
###
sub validateValue {

        #return @_[1];

        #check for non int
        #check for decimal
        if ( @_[0] eq "LongCounter" ) {
                return int(@_[1] + .5 * (@_[1] <=> 0));
        } elsif ( @_[0] eq "PerIntervalCounter" ) {
		return @_[1]
                }


}

###
# Format based on DataType
###
sub formatMetricValue {
        my @resultArray = ();

        my $count = 0;
        foreach my $item ( @_ ){
                my $metricType = $$item{'dataType'};
                my $validatedMetric = validateMetricString($$item{'metricName'});
                my $validatedValue = validateValue($metricType, $$item{'value'}, );

                $resultArray[$count++] = "<metric type=\"$metricType\" name=\"$validatedMetric\" value=\"$validatedValue\" />"
        }

        return \@resultArray;
}

sub clearResultsSet {
        @resultsSet = ();
}

sub storeCurrentValue {
	$pathToPrevValueMap{@_[0]} = @_[1];
}

sub getPrevValue {
	return $pathToPrevValueMap{@_[0]};
}

1;


