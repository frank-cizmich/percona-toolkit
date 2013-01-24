#!/usr/bin/env perl

BEGIN {
   die "The PERCONA_TOOLKIT_BRANCH environment variable is not set.\n"
      unless $ENV{PERCONA_TOOLKIT_BRANCH} && -d $ENV{PERCONA_TOOLKIT_BRANCH};
   unshift @INC, "$ENV{PERCONA_TOOLKIT_BRANCH}/lib";
};

use strict;
use warnings FATAL => 'all';
use English qw(-no_match_vars);
use Test::More;

use PerconaTest;
require "$trunk/bin/pt-query-digest";

no warnings 'once';
local $JSONReportFormatter::sorted_json = 1;
local $JSONReportFormatter::pretty_json = 1;

my @args    = qw(--output json);
my $sample  = "$trunk/t/lib/samples";
my $results = "t/pt-query-digest/samples";

ok(
   no_diff(
      sub { pt_query_digest::main(@args, "$sample/slowlogs/empty") },
      "$results/empty_report.txt",
   ),
   'json output for empty log'
);

ok(
   no_diff(
      sub { pt_query_digest::main(@args, "$sample/slowlogs/slow002.txt") },
      "$results/output_json_slow002.txt"
   ),
   'json output for slow002'
);

# --type tcpdump

ok(
   no_diff(
      sub { pt_query_digest::main(qw(--type tcpdump --limit 10 --watch-server 127.0.0.1:12345),
                                  @args, "$sample/tcpdump/tcpdump021.txt") },
      "$results/output_json_tcpdump021.txt",
   ),
   'json output for for tcpdump021',
);

# #############################################################################
# Done.
# #############################################################################
done_testing;
