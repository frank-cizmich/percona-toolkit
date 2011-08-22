#!/usr/bin/env perl

# This script is used by Daemon.t because that test script
# cannot daemonize itself.

BEGIN {
   die "The PERCONA_TOOLKIT_BRANCH environment variable is not set.\n"
      unless $ENV{PERCONA_TOOLKIT_BRANCH} && -d $ENV{PERCONA_TOOLKIT_BRANCH};
   unshift @INC, "$ENV{PERCONA_TOOLKIT_BRANCH}/lib";
};

use strict;
use warnings FATAL => 'all';

use English qw(-no_match_vars);
use constant MKDEBUG => $ENV{MKDEBUG};

use Daemon;
use OptionParser;
use PerconaTest;

my $o = new OptionParser(file => "$trunk/t/lib/samples/daemonizes.pl");
$o->get_specs();
$o->get_opts();

if ( scalar @ARGV < 1 ) {
   $o->save_error('No SLEEP_TIME specified');
}

$o->usage_or_errors();

my $daemon;
if ( $o->get('daemonize') ) {
   $daemon = new Daemon(o=>$o);
   $daemon->daemonize();

   print "STDOUT\n";
   print STDERR "STDERR\n";

   sleep $ARGV[0];
}

exit;

# ############################################################################
# Documentation.
# ############################################################################

=pod

=head1 SYNOPSIS

Usage: daemonizes.pl SLEEP_TIME [ARGS]

daemonizes.pl daemonizes, prints to STDOUT and STDERR, sleeps and exits.

=head1 OPTIONS

This tool accepts additional command-line arguments.  Refer to the
L<"SYNOPSIS"> and usage information for details.

=over

=item --daemonize

Fork to background and detach (POSIX only).  This probably doesn't work on
Microsoft Windows.

=item --help

Show help and exit.

=item --log

type: string

Print all output to this file when daemonized.

=item --pid

type: string 

Create the given PID file when daemonized.

=back
