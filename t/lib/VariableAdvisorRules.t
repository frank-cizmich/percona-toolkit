#!/usr/bin/perl

BEGIN {
   die "The PERCONA_TOOLKIT_BRANCH environment variable is not set.\n"
      unless $ENV{PERCONA_TOOLKIT_BRANCH} && -d $ENV{PERCONA_TOOLKIT_BRANCH};
   unshift @INC, "$ENV{PERCONA_TOOLKIT_BRANCH}/lib";
};

use strict;
use warnings FATAL => 'all';
use English qw(-no_match_vars);
use Test::More tests => 83;

use PodParser;
use AdvisorRules;
use VariableAdvisorRules;
use Advisor;
use PerconaTest;

my $p   = new PodParser();
my $var = new VariableAdvisorRules(PodParser => $p);

isa_ok($var, 'VariableAdvisorRules');

my @rules = $var->get_rules();
ok(
   scalar @rules,
   'Returns array of rules'
);

my $rules_ok = 1;
foreach my $rule ( @rules ) {
   if (    !$rule->{id}
        || !$rule->{code}
        || (ref $rule->{code} ne 'CODE') )
   {
      $rules_ok = 0;
      last;
   }
}
ok(
   $rules_ok,
   'All rules are proper'
);


# #############################################################################
# Test the rules.
# #############################################################################
my @cases = (
   {  name   => "auto inc 1",
      vars   => [qw(auto_increment_increment 1 auto_increment_offset 1)],
      advice => [],
   },
   {  name   => "auto inc 2",
      vars   => [qw(auto_increment_increment 2 auto_increment_offset 1)],
      advice => [qw(auto_increment)],
   },
   {  name   => "auto inc 3",
      vars   => [qw(auto_increment_increment 1 auto_increment_offset 3)],
      advice => [qw(auto_increment)],
   },
   {  name   => "concurrent insert",
      vars   => [qw(concurrent_insert 2)],
      advice => [qw(concurrent_insert)],
   },
   {  name   => "concurrent insert",
      vars   => [qw(concurrent_insert NEVER)],
      advice => [qw()],
   },
   {  name   => "concurrent insert",
      vars   => [qw(concurrent_insert AUTO)],
      advice => [qw()],
   },
   {  name   => "concurrent insert",
      vars   => [qw(concurrent_insert ALWAYS)],
      advice => [qw(concurrent_insert)],
   },
   {  name   => "connect timeout",
      vars   => [qw(connect_timeout 11)],
      advice => [qw(connect_timeout)],
   },
   {  name   => "debug",
      vars   => [qw(debug ON)],
      advice => [qw(debug)],
   },
   {  name   => "delay_key_write",
      vars   => [qw(delay_key_write ON)],
      advice => [qw(delay_key_write)],
   },
   {  name   => "flush",
      vars   => [qw(flush ON)],
      advice => [qw(flush)],
   },
   {  name   => "flush time",
      vars   => [qw(flush_time 1)],
      advice => [qw(flush_time)],
   },
   {  name   => "have bdb",
      vars   => [qw(have_bdb YES)],
      advice => [qw(have_bdb)],
   },
   {  name   => "init connect",
      vars   => [qw(init_connect foo)],
      advice => [qw(init_connect)],
   },
   {  name   => "init_file",
      vars   => [qw(init_file bar)],
      advice => [qw(init_file)],
   },
   {  name   => "init slave",
      vars   => [qw(init_slave 12346)],
      advice => [qw(init_slave)],
   },
   {  name   => "innodb_additional_mem_pool_size",
      vars   => [qw(innodb_additional_mem_pool_size 21000000)],
      advice => [qw(innodb_additional_mem_pool_size)],
   },
   {  name   => "innodb_buffer_pool_size",
      vars   => [qw(innodb_buffer_pool_size 10485760)],
      advice => [qw(innodb_buffer_pool_size)],
   },
   {  name   => "innodb checksums",
      vars   => [qw(innodb_checksums OFF)],
      advice => [qw(innodb_checksums)],
   },
   {  name   => "innodb_doublewrite",
      vars   => [qw(innodb_doublewrite OFF)],
      advice => [qw(innodb_doublewrite)],
   },
   {  name   => "innodb_fast_shutdown",
      vars   => [qw(innodb_fast_shutdown 0)],
      advice => [qw(innodb_fast_shutdown)],
   },
   {  name   => "innodb_flush_log_at_trx_commit-1",
      vars   => [qw(innodb_flush_log_at_trx_commit 2)],
      advice => [qw(innodb_flush_log_at_trx_commit-1)],
   },
   {  name   => "innodb_flush_log_at_trx_commit-2",
      vars   => [qw(innodb_flush_log_at_trx_commit 0)],
      advice => [qw(innodb_flush_log_at_trx_commit-1 innodb_flush_log_at_trx_commit-2)],
   },
   {  name   => "innodb_force_recovery",
      vars   => [qw(innodb_force_recovery 1)],
      advice => [qw(innodb_force_recovery)],
   },
   {  name   => "innodb_lock_wait_timeout",
      vars   => [qw(innodb_lock_wait_timeout 51)],
      advice => [qw(innodb_lock_wait_timeout)],
   },
   {  name   => "innodb_log_buffer_size",
      vars   => [qw(innodb_log_buffer_size 17000000)],
      advice => [qw(innodb_log_buffer_size)],
   },
   {  name   => "innodb_log_file_size",
      vars   => [qw(innodb_log_file_size 5242880)],
      advice => [qw(innodb_log_file_size)],
   },
   {  name   => "innodb_max_dirty_pages_pct",
      vars   => [qw(innodb_max_dirty_pages_pct 89)],
      advice => [qw(innodb_max_dirty_pages_pct)],
   },
   {  name   => "key_buffer_size",
      vars   => [qw(key_buffer_size 8388608)],
      advice => [qw(key_buffer_size)],
   },
   {  name   => "large_pages",
      vars   => [qw(large_pages ON)],
      advice => [qw(large_pages)],
   },
   {  name   => "locked in memory",
      vars   => [qw(locked_in_memory ON)],
      advice => [qw(locked_in_memory)],
   },
   {  name   => "log_warnings-1",
      vars   => [qw(log_warnings 0)],
      advice => [qw(log_warnings-1)],
   },
   {  name   => "log_warnings-2",
      vars   => [qw(log_warnings 1)],
      advice => [qw(log_warnings-2)],
   },
   {  name   => "low_priority_updates",
      vars   => [qw(low_priority_updates ON)],
      advice => [qw(low_priority_updates)],
   },
   {  name   => "max_binlog_size",
      vars   => [qw(max_binlog_size 999999999)],
      advice => [qw(max_binlog_size)],
   },
   {  name   => "max_connect_errors",
      vars   => [qw(max_connect_errors 10)],
      advice => [qw(max_connect_errors)],
   },
   {  name   => "max_connections",
      vars   => [qw(max_connections 1001)],
      advice => [qw(max_connections)],
   },
   {  name   => "myisam_repair_threads",
      vars   => [qw(myisam_repair_threads 2)],
      advice => [qw(myisam_repair_threads)],
   },
   {  name   => "old passwords",
      vars   => [qw(old_passwords ON)],
      advice => [qw(old_passwords)],
   },
   {  name   => "optimizer_prune_level",
      vars   => [qw(optimizer_prune_level 0)],
      advice => [qw(optimizer_prune_level)],
   },
   {  name   => "port",
      vars   => [qw(port 12345)],
      advice => [qw(port)],
   },
   {  name   => "query_cache_size-1",
      vars   => [qw(query_cache_size 134217729)],
      advice => [qw(query_cache_size-1)],
   },
   {  name   => "query_cache_size-2",
      vars   => [qw(query_cache_size 536870913)],
      advice => [qw(query_cache_size-1 query_cache_size-2)],
   },
   {  name   => "read_buffer_size-1",
      vars   => [qw(read_buffer_size 130000)],
      advice => [qw(read_buffer_size-1)],
   },
   {  name   => "read_buffer_size-2",
      vars   => [qw(read_buffer_size 8500000)],
      advice => [qw(read_buffer_size-1 read_buffer_size-2)],
   },
   {  name   => "read_rnd_buffer_size-1",
      vars   => [qw(read_rnd_buffer_size 262000)],
      advice => [qw(read_rnd_buffer_size-1)],
   },
   {  name   => "read_rnd_buffer_size-2",
      vars   => [qw(read_rnd_buffer_size 7000000)],
      advice => [qw(read_rnd_buffer_size-1 read_rnd_buffer_size-2)],
   },
   {  name   => "relay_log_space_limit",
      vars   => [qw(relay_log_space_limit 1)],
      advice => [qw(relay_log_space_limit)],
   },
   {  name   => "slave net timeout",
      vars   => [qw(slave_net_timeout 61)],
      advice => [qw(slave_net_timeout)],
   },
   {  name   => "slave skip errors",
      vars   => [qw(slave_skip_errors 1024)],
      advice => [qw(slave_skip_errors)],
   },
   {  name   => "slave skip errors",
      vars   => [qw(slave_skip_errors OFF)],
      advice => [],
   },
   {  name   => "sort_buffer_size-1",
      vars   => [qw(sort_buffer_size 2097140)],
      advice => [qw(sort_buffer_size-1)],
   },
   {  name   => "sort_buffer_size-2",
      vars   => [qw(sort_buffer_size 5000000)],
      advice => [qw(sort_buffer_size-1 sort_buffer_size-2)],
   },
   {  name   => "sql notes",
      vars   => [qw(sql_notes OFF)],
      advice => [qw(sql_notes)],
   },
   {  name   => "sync_frm",
      vars   => [qw(sync_frm OFF)],
      advice => [qw(sync_frm)],
   },
   {  name   => "tx_isolation-1",
      vars   => [qw(tx_isolation foo)],
      advice => [qw(tx_isolation-1 tx_isolation-2)],
   },


   {  name   => "expire_log_days",
      vars   => [qw(expire_log_days 0 log_bin ON)],
      advice => [qw(expire_log_days)],
   },
   {  name   => "innodb_file_io_threads",
      vars   => [qw(innodb_file_io_threads 16)],
      advice => [qw(innodb_file_io_threads)],
   },
   {  name   => "innodb_data_file_path",
      vars   => [qw(innodb_data_file_path ibdata1:10M:autoextend)],
      advice => [qw(innodb_data_file_path)],
   },
   {  name   => "innodb_flush_method",
      vars   => [qw(innodb_flush_method O_DSYNC)],
      advice => [qw(innodb_flush_method)],
   },
   {  name   => "innodb_locks_unsafe_for_binlog",
      vars   => [qw(innodb_locks_unsafe_for_binlog ON log_bin ON)],
      advice => [qw(innodb_locks_unsafe_for_binlog)],
   },
   {  name   => "innodb_support_xa",
      vars   => [qw(innodb_support_xa OFF log_bin ON)],
      advice => [qw(innodb_support_xa)],
   },
   {  name   => "log_bin ON",
      vars   => [qw(log_bin ON)],
      advice => [qw()],
   },
   {  name   => "log_bin OFF",
      vars   => [qw(log_bin OFF)],
      advice => [qw(log_bin)],
   },
   {  name   => "log_output",
      vars   => ['log_output', 'FILE,TABLE'],
      advice => [qw(log_output)],
   },
   {  name   => "max_relay_log_size",
      vars   => [qw(max_relay_log_size 500000000)],
      advice => [qw(max_relay_log_size)],
   },
   {  name   => "myisam_recover_options OFF",
      vars   => [qw(myisam_recover_options OFF)],
      advice => [qw(myisam_recover_options)],
   },
   {  name   => "myisam_recover_options DEFAULT",
      vars   => [qw(myisam_recover_options DEFAULT)],
      advice => [qw(myisam_recover_options)],
   },
   {  name   => "storage_engine MyISAM",
      vars   => [qw(storage_engine MyISAM)],
      advice => [qw()],
   },
   {  name   => "storage_engine",
      vars   => ['storage_engine', 'foo,bar'],
      advice => [qw(storage_engine)],
   },
   {  name   => "sync_binlog 0",
      vars   => [qw(sync_binlog 0 log_bin ON)],
      advice => [qw(sync_binlog)],
   },
   {  name   => "sync_binlog 2",
      vars   => [qw(sync_binlog 2 log_bin ON)],
      advice => [qw(sync_binlog)],
   },
   {  name   => "tmp_table_size",
      vars   => [qw(tmp_table_size 1024 max_heap_table_size 512)],
      advice => [qw(tmp_table_size)],
   },
   {  name          => "end-of-life mysql version",
      mysql_version => '005000087',
      advice        => ['end-of-life mysql version'],
   },
   {  name          => "old mysql version 3.22.00",
      mysql_version => '00302200',
      advice        => ['old mysql version', 'end-of-life mysql version'],
   },
   {  name          => "old mysql version 4.1.1",
      mysql_version => '004001001',
      advice        => ['old mysql version', 'end-of-life mysql version'],
   },
   {  name          => "old mysql version 5.0.36",
      mysql_version => '005000036',
      advice        => ['old mysql version', 'end-of-life mysql version'],
   },
   {  name          => "old mysql version 5.1.29",
      mysql_version => '005001029',
      advice        => ['old mysql version'],
   },
   {  name          => "old mysql version 5.5.0",
      mysql_version => '005005000',
      advice        => [],
   },
);


my $adv = new Advisor(match_type => "bool");
$adv->load_rules($var);

foreach my $test ( @cases ) {
   my %vars = $test->{vars} ? @{$test->{vars}} : ();

   my ($ids) = $adv->run_rules(
      variables => \%vars,
      %$test,
   );
   is_deeply(
      $ids,
      $test->{advice},
      $test->{name},
   );

   # To help me debug.
   die if $test->{stop};
}

# #############################################################################
# Done.
# #############################################################################
my $output = '';
{
   local *STDERR;
   open STDERR, '>', \$output;
   $p->_d('Complete test coverage');
}
like(
   $output,
   qr/Complete test coverage/,
   '_d() works'
);
exit;
