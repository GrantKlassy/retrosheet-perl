#!/usr/bin/perl

# This is an example script which uses Retrosheet_Perl.pm

use strict;
use warnings;
use Data::Dumper;	# Used for debugging
use Cwd 'abs_path';	# Used for relative -> absolute path

use lib '../lib';	# Source the Retrosheet_Perl.pm directory
use Retrosheet_Perl;

# The directory we'll parse the year for
my $yearDir = '../data/2017eve-linux/';
$yearDir = abs_path($yearDir);


my $yearhref = Retrosheet_Perl::parse_year($yearDir);
print Dumper $yearhref;
