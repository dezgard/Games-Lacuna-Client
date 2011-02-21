#!/usr/bin/env perl

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Number::Format        qw( format_number );
use List::Util            qw( max );
use Getopt::Long          qw(GetOptions);
use Games::Lacuna::Client ();

my $planet_name;

GetOptions(
    'planet=s' => \$planet_name,
);

my $cfg_file = shift(@ARGV) || 'lacuna.yml';
unless ( $cfg_file and -e $cfg_file ) {
  $cfg_file = eval{
    require File::HomeDir;
    require File::Spec;
    my $dist = File::HomeDir->my_dist_config('Games-Lacuna-Client');
    File::Spec->catfile(
      $dist,
      'login.yml'
    ) if $dist;
  };
  unless ( $cfg_file and -e $cfg_file ) {
    die "Did not provide a config file";
  }
}

my $client = Games::Lacuna::Client->new(
	cfg_file => $cfg_file,
	# debug    => 1,
);

my @types = qw( food ore water energy waste );

# Load the planets
my $empire  = $client->empire->get_status->{empire};
my $planets = $empire->{planets};

#my @planets = ();
open my $csv, '>', 'buildings.csv';
print $csv qq^"Planet","Building","Level"\n^;
# Scan each planet
foreach my $planet_id ( sort keys %$planets ) {
    my $name = $planets->{$planet_id};

    next if defined $planet_name && $planet_name ne $name;

    # Load planet data
    my $planet    = $client->body( id => $planet_id );
    my $result    = $planet->get_buildings;
    my $buildings = $result->{buildings};
    
    my @build = ();
    
   #$build .= qq^"$name",^;
    
    for my $building_id ( sort keys %$buildings ) {
        #push @build, $buildings->{$building_id}
        #    if $buildings->{$building_id}{pending_build};
        #push @build, [@{$buildings->{$building_id}}{qw(name level)}];
        print $csv qq^"$name","$buildings->{$building_id}{name}","$buildings->{$building_id}{level}"\n^;
    }
    
    #push @planets, [$name, \@build];
    
    #next if !@build;
    #
    #print "$name\n";
    #print "=" x length $name;
    #print "\n";
    #
    #for my $building (@build) {
    #    printf "%s: %s\n",
    #        $building->{name},
    #        $building->{pending_build}{end};
    #}
    #
    #print "\n";
}


#use Data::Dumper;
#print Dumper(\@planets) . "\n";

