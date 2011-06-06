package RekeyingTest;
use defaults;
use Test::Most;
use Data::Clone;

my $orig = [
            {
              bar => 22,
              baz => 'hello',
              foo => 1
            },
            {
              bar => 24,
              baz => 'hello',
              foo => 1
            },
            {
              bar => 12,
              baz => 'hello',
              foo => 2
            },
            {
              bar => 22,
              baz => 'goodbye',
              foo => 2
            }
];

my $in = clone($orig);

use_ok("Data::Rekey");
can_ok("Data::Rekey", "key");

ok my $out = Data::Rekey::key($in, "foo"), "rekey by foo";
is_deeply $out, 
    {
        1 => [
                {
                bar => 22,
                baz => 'hello'
                },
                {
                bar => 24,
                baz => 'hello'
                }
            ],
        2 => [
                {
                bar => 12,
                baz => 'hello'
                },
                {
                bar => 22,
                baz => 'goodbye'
                }
            ],
    },
    "single level rekeying works as expected"
;

is_deeply $in, $orig, "input is not trampled on";


ok my $out2 = Data::Rekey::key($in, "baz", "foo"), "rekey by baz,foo";
use DDS; diag(Dump($out2));
is_deeply $out2,
    {
        hello => {
            1 => [
                { bar => 22 },
                { bar => 24 },
            ],
            2 => [
                { bar => 12 },
            ],
        },
        goodbye => {
            2 => [
                { bar => 22 },
            ],
        },
    },
    "bi-level rekeying works as expected"
;
is_deeply $in, $orig, "input is not trampled on";


ok my $out3 = Data::Rekey::key($in, "baz", "foo", "bar"), "rekey by baz,foo,bar";
use DDS; diag(Dump($out3));
is_deeply $out3,
    {
        hello => {
            1 => {
                22 => [ {}, ],
                24 => [ {}, ],
            },
            2 => {
                12 => [ {}, ],
            },
        },
        goodbye => {
            2 => {
                22 => [ {}, ],
            },
        },
    },
    "multi-level rekeying works as expected"
;
is_deeply $in, $orig, "input is not trampled on";
done_testing;
