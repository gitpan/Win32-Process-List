#!c:/perl/bin/perl -w
use Win32::Process::List;
use strict;

my $P = Win32::Process::List->new();
if($P->IsError == 1)
{
	print "an error occured: " . $P->GetErrorText . "\n";
}

my %list = $P->GetProcesses();
my $anz = scalar keys %list;
print "Anzal im Array= $anz\n";
my $count = 0;
foreach my $key (keys %list) {
	my $pid = $list{$key};
	print sprintf("%15s has PID %5i", $key, $pid) . "\n";
	$count++;
}
print "Number of processes: $count\n";
my $process = "explorer";
my @hPIDS = $P->GetProcessPid($process);
if($hPIDS[0] != -1) {
	foreach ( 0 .. $#hPIDS ) {
		print "$process has PID " . $hPIDS[$_] . "\n";
	}
}