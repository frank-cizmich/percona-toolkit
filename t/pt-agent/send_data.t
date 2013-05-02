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
use JSON;
use File::Temp qw(tempdir);

use Percona::Test;
use Percona::Test::Mock::UserAgent;
require "$trunk/bin/pt-agent";

Percona::Toolkit->import(qw(Dumper have_required_args));
Percona::WebAPI::Representation->import(qw(as_hashref));

my $sample = "t/pt-agent/samples";

# #############################################################################
# Create mock client and Agent
# #############################################################################

# These aren't the real tests yet: to run_agent(), first we need
# a client and Agent, so create mock ones.

my $json = JSON->new->canonical([1])->pretty;
$json->allow_blessed([]);
$json->convert_blessed([]);

my $ua = Percona::Test::Mock::UserAgent->new(
   encode => sub { my $c = shift; return $json->encode($c || {}) },
);

# Create cilent, get entry links
my $links = {
   agents          => '/agents',
   config          => '/agents/1/config',
   services        => '/agents/1/services',
   'query-history' => '/query-history',
};

$ua->{responses}->{get} = [
   {
      content => $links,
   },
];

my $client = eval {
   Percona::WebAPI::Client->new(
      api_key => '123',
      ua      => $ua,
   );
};
is(
   $EVAL_ERROR,
   '',
   'Create mock client'
) or die;

my $agent = Percona::WebAPI::Resource::Agent->new(
   uuid     => '123',
   hostname => 'prod1', 
);

is_deeply(
   as_hashref($agent),
   {
      uuid     => '123',
      hostname => 'prod1',
   },
   'Create mock Agent'
) or die;

# #############################################################################
# Test send_data
# #############################################################################

my $tmpdir = tempdir("/tmp/pt-agent.$PID.XXXXXX", CLEANUP => 1);
pt_agent::init_lib_dir(
   lib_dir => $tmpdir,
   quiet   => 1,
);
pt_agent::init_spool_dir(
   spool_dir => $tmpdir,
   service   => 'query-history',
   quiet     => 1,
); 

`cp $trunk/$sample/query-history/data001.json $tmpdir/query-history/1.data001.data`;
`cp $trunk/$sample/service001 $tmpdir/services/query-history`;

$ua->{responses}->{post} = [
   {
      content => $links,
   },
];

my $output = output(
   sub {
      pt_agent::send_data(
         api_key   => '123',
         service   => 'query-history',
         lib_dir   => $tmpdir,
         spool_dir => $tmpdir,
         # optional, for testing:
         client    => $client,
         agent     => $agent,
         json      => $json,
      ),
   },
);

is(
   scalar @{$client->ua->{content}->{post}},
   1,
   "Only sent 1 resource"
) or diag($output, Dumper($client->ua->{content}->{post}));

is_deeply(
   $ua->{requests},
   [
      'POST /query-history/data',
   ],
   "POST to Service.links.data"
);

ok(
   no_diff(
      $client->ua->{content}->{post}->[0] || '',
      "$sample/query-history/data001.send",
      cmd_output => 1,
   ),
   "Sent data file as multi-part resource (query-history/data001)"
) or diag(Dumper($client->ua->{content}->{post}));

ok(
   !-f "$tmpdir/query-history/1.data001.data",
   "Removed data file after sending successfully"
);

is(
   $ua->{request_objs}->[-1]->header('content-type'),
   'multipart/form-data; boundary=Ym91bmRhcnk',
   'Content-Type=multipart/form-data; boundary=Ym91bmRhcnk'
) or diag(Dumper($ua));

# #############################################################################
# Done.
# #############################################################################
done_testing;
