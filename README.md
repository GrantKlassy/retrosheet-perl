# retrosheet-perl

A retrosheet parser written in perl. Includes a perl module to parse files and an example script which uses the module.

## Usage

Clone the git repo into the directory of your project
```bash
git clone https://github.com/GrantKlassy/retrosheet-perl.git
```

Source the Retrosheet\_Perl.pm perl module
```perl
use lib './retrosheet-perl/lib';
use Retrosheet_Perl'
```

Use the various functions of Retrosheet\_Perl.pm
```perl
use Data::Dumper;

my $yearDir = abs_path('./retrosheet-perl/data/2017eve-linux');
my $parsed_year_href = Retrosheet_Perl::parse_year($yearDir);
print Dumper $parsed_year_href;
```
...
```
VARR1 = {
          '2017ATL.EVN' => {
                             'ATL201708260' => {
                                                 'version' => '2',
                                                 'start' => {
                                                              'freek001' => {
                                                                              'home' => '0',
                                                                              'startingPos' => '1',
                                                                              'name' => '"Kyle Freeland"',
                                                                              'battingPos' => '9'
                                                                            },
                                                              'lemad001' => {
                                                                              'battingPos' => '2',
                                                                              'name' => '"DJ LeMahieu"',
                                                                              'home' => '0',
                                                                              'startingPos' => '4'
                                                                            },
... <etc> ...
```
