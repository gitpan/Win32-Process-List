# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test;
BEGIN { plan tests => 1 };
use Win32::Process::List;
ok(1); # If we made it this far, we're ok.

#########################

# Insert your test code below, the Test module is use()ed here so read
# its man page ( perldoc Test ) for help writing this test script.

my $P = Win32::Process::List->new();
if($P->IsError == 1)
{
	print "an Error occured: " . $P->GetErrorText . "\n";
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