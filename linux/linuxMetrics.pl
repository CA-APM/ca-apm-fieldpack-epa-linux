
###
# User Defined File: Go Down to User Section to Add new Metrics
###

###
# Declare Package.
# The Package name is same as file name without ".pl"
###
package linuxMetrics;

use FindBin;
use lib ("$FindBin::Bin", "$FindBin::Bin/../lib/perl");
use Wily::EPAgentFunctions;

###
# Get user Metrics is a mandatory inteface that user can modify to add more custom metrics
# It uses addToResultsSet sub to publish metrics to Wily
###
sub getUserMetrics {

        getMemoryMetrics();
        getDiskMetricsUbuntu();
        #getMyNewMetrics();
        getProcessMetrics();
        getNetworksDeltaMetrics();

}

###
# AddToResultsSet: uses library function addToResultsSet to publish metrics to Wily
###
sub addToResultsSet {
        Wily::EPAgentFunctions::addToResultsSet (@_[0], @_[1],@_[2]);
}

sub getNetworksDeltaMetrics {
	#my $networkTxBytes = `cat /proc/net/dev|grep eth0`;
	my $networkTxBytes = `cat /proc/net/dev|grep eth0|awk '{print \$9}'`;
	my $path = "Networks|eth0:Bytes Transmitted";

	my $prevValue = Wily::EPAgentFunctions::getPrevValue ($path);
	my $delta;
	
	if (defined($prevValue) ) {
		$delta = $networkTxBytes - $prevValue	;
		if ( $delta < 0 ) {
			$delta = $networkTxBytes;
		}
        	addToResultsSet("PerIntervalCounter", $path, $delta );
	} 

        Wily::EPAgentFunctions::storeCurrentValue ($path, $networkTxBytes);

	
}

###
# getProcessMetrics is sub that user can modify to publish process related metrics
# this is more adv way of publishing process metrics. Use xml file to publish simple process
# related metrics
###
sub getProcessMetrics {

        my $processNames = "Enterprise";
        my $processCmd = 'ps auxx |grep -v grep | grep -e ' ;

        my @processNameArray = split (/,/,$processNames);
        $processNames =~ s/,/ -e /g;
        $processCmd = $processCmd . " " . $processNames;

        #print "processCmd $processCmd\n";
        my @processResults = `$processCmd`;

        my %processInfo = ();
        my %nameValuePair = ();

        foreach my $line (@processResults) {

                my @fields = split (/\s+/,$line);
                foreach my $processName (@processNameArray) {
                        $processName =~ s/\s+//;
                        if ( $line =~ m/$processName/){
                                addToResultsSet ("LongCounter", "AdvProcess|".$processName.":CPU % Used", $fields[2] );
                                addToResultsSet ("LongCounter", "AdvProcess|".$processName.":Memory % Used", $fields[3] );
                                addToResultsSet ("LongCounter", "AdvProcess|".$processName.":Availability","1" );

                                $nameValuePair{"Process|".$processName.":Availability"} = 1;

                        } else {
                                if ( !exists $nameValuePair{"Process|".$processName.":Availability"} ) {
                                        $nameValuePair{"Process|".$processName.":Availability"} = 0;
                                }
                        }
                }
        }

        while ( (my $key, my $value )= each( %nameValuePair)) {
                if ( $value == 0 ) {
                        addToResultsSet("LongCounter", $key, "0" );
                }
        }
}


####
# Example add Metrics
####

sub getMyNewMetrics {
        addToResultsSet ("LongCounter", "NewMetricPath|MetricPath:NewMetric","20");
}


###
# GetMemoryMetrics: get memory metrics
###
sub getMemoryMetrics {

        %result = ();

        my $memCommand = 'free -m';
        my @memResults = `$memCommand`;
        my @memKeys = ('Totals', 'Used');

        $memValues = @memResults[1];
        chomp($memValues);

        my @memValuesSplit = split (/\s+/, $memValues);

        addToResultsSet ("LongCounter", 'Memory:Totals', $memValuesSplit[1] );
        addToResultsSet ("LongCounter", 'Memory:Used', $memValuesSplit[2] );

}

###
# GetDiskMetrics: get Disk metrics
###
sub getDiskMetrics {

        %result = ();

        my $diskCommand = 'df -km / /boot';
        my @diskResults = `$diskCommand`;
        my @diskkeys = ('Total', 'Used');

        $diskValues = @diskResults[2];
        chomp($diskValues);

        my @diskValuesSplit = split (/\s+/, $diskValues);

        addToResultsSet ("LongCounter", 'Disk|/dev/VolGrp:Totals (MB)', $diskValuesSplit[1] );
        addToResultsSet ("LongCounter", 'Disk|/dev/VolGrp:Used (MB)', $diskValuesSplit[2] );

        $diskValues = @diskResults[3];
        chomp($diskValues);

        @diskValuesSplit = split (/\s+/, $diskValues);

        addToResultsSet ("LongCounter", 'Disk|/sda1:Totals (MB)', $diskValuesSplit[1] );
        addToResultsSet ("LongCounter", 'Disk|/sda1:Used (MB)', $diskValuesSplit[2] );

}


###
# GetDiskMetrics: get Disk metrics
###
sub getDiskMetricsUbuntu {

        %result = ();

        my $diskCommand = 'df -km / /dev';
        my @diskResults = `$diskCommand`;
        my @diskkeys = ('Total', 'Used');

        $diskValues = @diskResults[1];
        chomp($diskValues);

        my @diskValuesSplit = split (/\s+/, $diskValues);

        addToResultsSet ("LongCounter", 'Disk|/dev/vda1:Totals (MB)', $diskValuesSplit[1] );
        addToResultsSet ("LongCounter", 'Disk|/dev/vda1:Used (MB)', $diskValuesSplit[2] );

        $diskValues = @diskResults[2];
        chomp($diskValues);

        @diskValuesSplit = split (/\s+/, $diskValues);

        addToResultsSet ("LongCounter", 'Disk|/udev:Totals (MB)', $diskValuesSplit[1] );
        addToResultsSet ("LongCounter", 'Disk|/udev:Used (MB)', $diskValuesSplit[2] );

}



1;


