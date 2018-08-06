# Retrosheet_Perl.pl
# gklassy, 2018
# vim: set ft=perl:
#
# To view the documentation for this module, run...
# "pod2html Retrosheet_Perl.pm | lynx -stdin -dump"

=pod

=head1 NAME

Retrosheet Perl

=head1 SYNOPSYS

	use lib ./lib;
	use Retrosheet_Perl;

=head1 DESCRIPTION

A perl module which parses csv files from retrosheet.org.

=cut

package Retrosheet_Perl;

use strict;
use warnings;
use Data::Dumper;
use File::Basename;

=head1 FUNCTIONS

=head2 parse_year($)

	parse_year($RETROSHEET_YEAR_DIR)

A function to parse an entire year of retrosheet data. Returns
a reference to a nested hash structure which contains all of
the data for the files in the given year directory. Year
directories should follow the format under "Regular Season
Event Files" on www.retrosheet.org/game.htm

=cut

sub parse_year($) {

	# Get the directory of the years files
	my $yearDir = shift;

	# The year hash that we'll return
	my %year;

	# Get a list of all the event files in our directory
	opendir(my $DIR, "$yearDir");
	my @eventFiles = grep(/EVN/, readdir($DIR));
	closedir($DIR);

	# For every event file...
	foreach my $eventFile (@eventFiles) {

		# Get the full path
		$eventFile = "${yearDir}/${eventFile}";

		# Call parse event on that file
		my $href = parse_event($eventFile);

		# Add the event href to our year hash
		my $baseFile = basename($eventFile);
		$year{$baseFile} = $href;
	}


	# Return the year hashref
	return \%year;
}

=head2 parse_event

	parse_event($RETROSHEET_EVENT_FILE)

A function to parse an event file. Returns a reference
to a nested hash structure which contains all of the data
for that event file. Event files should follow the format
specified at...

https://www.retrosheet.org/eventfile.htm
https://www.retrosheet.org/datause.txt

=cut

sub parse_event($) {

	# Get the event file name
	my $eventFile = shift;

	# The event hash we'll return
	my %event;

	# Open the file for reading
	open(my $FH, '<', $eventFile) or die "Could not open event file '$eventFile': $!";

	# The current ID of the game we're parsing
	my $currGameID = "test";

	# Note that the parsing in this section follows https://www.retrosheet.org/datause.txt
	# For every line in the event file...
	while (my $line = <$FH>) {
		chomp $line;

		# If the line is a game id, set the current game id
		if ($line =~ m/^id,.*$/) {
			$currGameID = parse_id($line);
		} elsif ($line =~ m/^version,.*$/) {
			$event{$currGameID}{'version'} = parse_version($line);
		} elsif ($line =~ m/^info,.*$/) {

			my $infohref = parse_info($line);

			# If there is already info, merge the kv pair into existing info hash
			if (exists $event{$currGameID}{'info'}) {
				$event{$currGameID}{'info'} = {%{$infohref}, %{$event{$currGameID}{'info'}}};
			} else {
				# If there isn't an info hash, create one using this kv pair
				$event{$currGameID}{'info'} = $infohref;
			}

		} elsif ($line =~ m/^start,.*$/) {

			my $starthref = parse_start($line);

			# If there is already a start hash, merge the kv pair into the existing one
			if (exists $event{$currGameID}{'start'}) {
				$event{$currGameID}{'start'} = {%{$starthref}, %{$event{$currGameID}{'start'}}};
			} else {
				# If there isn't one, create one
				$event{$currGameID}{'start'} = $starthref;
			}

		} elsif ($line =~ m/^play,.*$/) {

#			print "THIS IS A PLAY: $line\n";
			# TODO Parse play here

		} elsif ($line =~ m/^com,.*$/) {


#		print "THIS IS A COMMENTARY: $line\n";
			# TODO Parse com here

		} elsif ($line =~ m/^sub,.*$/) {

#			print "THIS IS A SUB: $line\n";
			# TODO Parse sub here

		} elsif ($line =~ m/^data,.*$/) {

			my $datahref = parse_data($line);

			# If there is already a start hash, merge the kv pair into the existing one
			if (exists $event{$currGameID}{'data'}) {
				$event{$currGameID}{'data'} = {%{$datahref}, %{$event{$currGameID}{'data'}}};
			} else {
				# If there isn't one, create one
				$event{$currGameID}{'data'} = $datahref;
			}

		} elsif ($line =~ m/^badj,.*$/) {

#			print "THIS IS A BATTING ADJUST: $line\n";
			# TODO Maybe parse this

		} elsif ($line =~ m/^padj,.*/) {

#			print "THIS IS A PITCHING ADJUSTMENT: $line\n";
			# TODO Maybe parse this

		} elsif ($line =~ m/^ladj,.*/) {

#			print "THIS IS A LINEUP ADJUSTMENT: $line\n";
			# TODO Maybe parse this

		} else {

			print STDERR "ERROR Line not supported: $line\n";
			# TODO Better ERROR

		}

	}

	# Close the file
	close $FH;

	# Return the event hashref
	return \%event;

}





=head2 parse_id

	parse_id($ID_LINE)

A function to parse an id line. Returns the id.

=cut

sub parse_id($) {
	my $line = shift;
	my $id = (split(/,/, $line))[1];
	return $id;
}





=head2 parse_version

	parse_version($VERSION_LINE)

A function to parse a version line. Returns the version.

=cut

sub parse_version($) {
	my $line = shift;
	my $version = (split(/,/, $line))[1];
	return $version;
}





=head2 parse_info

	parse_info($INFO_LINE)

A function to parse a version line. Returns a href with one kv pair.

=cut

sub parse_info($) {
	my $line = shift;
	my %info;

	my @split = split(/,/, $line);
	$info{$split[1]} = $split[2];
	return \%info;
}





=head2 parse_start

	parse_start($START_LINE)

A function to parse a start line. Returns an href.

=cut

sub parse_start($) {
	my $line = shift;
	my %start;

	my @split = split(/,/, $line);
	my $playerID = $split[1];
	my $playerName = $split[2];
	my $home = $split[3];
	my $battingPos = $split[4];
	my $startingPos = $split[5];

	# TODO Think about whether we should remove the quotes around the player name

	# Because the player ID is unique to every player, use that as our key
	$start{$playerID} = {
				'name'		=> "$playerName",
				'home'		=> "$home",
				'battingPos'	=> "$battingPos",
				'startingPos'	=> "$startingPos",
			};
	return \%start;
}





=head2 parse_play

	parse_play($PLAY_LINE)

A function to parse a play line. Returns an href.

=cut

sub parse_play($) {

	my $line = shift;
	return "TODO";
}





=head2 parse_com

	parse_com($COM_LINE)

A function to parse a commentary line. Returns the commentary.

=cut

sub parse_com($) {

	my $line = shift;
	return "TODO";
}





=head2 parse_sub

	parse_sub($SUB_LINE)

A function to parse a substitution line. Returns TODO

=cut

sub parse_sub($) {

	my $line = shift;
	return "TODO";
}





=head2 parse_data

	parse_data($DATA_LINE)

A function to parse a data line. Returns TODO

=cut

sub parse_data($) {
	my $line = shift;
	my %data;

	# NOTE: Currently the only data type is earned runs (er)
	# Lets assume that the type will always be "er", use the
	# pitchers ID as the key, and squawk if the type isn't "er"
	my @split = split(/,/, $line);
	my $dataType = $split[1];
	my $pitcherID = $split[2];
	my $earnedRuns = $split[3];

	if ($dataType ne 'er') {
		print STDERR "WARNING: Data type '$dataType' unknown\n";
		%data = undef;
	} else {
		$data{$pitcherID} = {
					'dataType'	=> "$dataType",
					'earnedRuns'	=> "$earnedRuns",
				};
	}

	return \%data;
}





1;

__END__
