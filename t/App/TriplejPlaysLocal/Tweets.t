#!/usr/bin/perl -w

use strict;
use v5.010;
use Test::More;
use Test::Warnings;
use Test::MockTime 'set_relative_time';
use App::TriplejPlaysLocal::Song;

use_ok('App::TriplejPlaysLocal::Tweets');

my $tweets = App::TriplejPlaysLocal::Tweets->new();

$tweets->push_val(App::TriplejPlaysLocal::Song->new(
    id      => '1234',
    tweet   => 'Artist - Track [00:00]',
  )
);

set_relative_time(3600);

$tweets->push_val(App::TriplejPlaysLocal::Song->new(
    id      => '1235',
    tweet   => 'Artist - Track [00:00]',
  )
);

set_relative_time(7100);

$tweets->push_val(App::TriplejPlaysLocal::Song->new(
    id      => '1236',
    tweet   => 'Artist - Track [00:00]',
  )
);

set_relative_time(25200);

my @expired = $tweets->expired_tweets;
my $count = @expired;

is($count, 1, "1 expired tweet found");
is(@{$tweets->songs}[$expired[0]]->id, "1234", "Expired tweet found");
$tweets->delete_tweet($expired[0]);
is($tweets->expired_tweets, undef, "No expired tweets");
my $active = @{$tweets->songs};
is($active, 2, "2 active tweets");

done_testing();
