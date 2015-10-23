#!/usr/bin/perl -w

use strict;
use v5.010;
use Test::More;
use Test::Warnings;

use_ok('App::TriplejPlaysLocal::Song');

subtest 'No @mention' => sub {
  my $song = App::TriplejPlaysLocal::Song->new(
    id      => '1234',
    tweet   => 'Artist - Track [00:00]',
  );

  is($song->artist, "Artist", "Artist Parsed Correctly");
  is($song->track, "Track", "Track Parsed Correctly");
  is($song->time, "00:00", "Time Parsed Correctly");
  is($song->build_tweet, "Artist - Track [00:00]", "Tweet Built Correctly");
};

subtest '@mention artist' => sub {
  my $mentions = App::TriplejPlaysLocal::Song->new(
    id      => '1234',
    tweet   => '.@Artist - Track [00:00]',
  );
  
  is($mentions->artist, "Artist", "Artist Parsed Correctly");
  is($mentions->track, "Track", "Track Parsed Correctly");
  is($mentions->time, "00:00", "Time Parsed Correctly");
  is($mentions->build_tweet, "Artist - Track [00:00]", "Tweet Built Correctly");
};

subtest '@mention multiple' => sub {
  my $mentions = App::TriplejPlaysLocal::Song->new(
    id      => '1234',
    tweet   => '.@Artist (feat @_artist2) - Track @ awesome (also @artist3 &amp; @artist4) [00:00]',
  );
  
  is($mentions->artist, "Artist (feat _artist2)", "Artist Parsed Correctly");
  is($mentions->track, "Track @ awesome (also artist3 & artist4)", "Track Parsed Correctly");
  is($mentions->time, "00:00", "Time Parsed Correctly");
  is($mentions->build_tweet, "Artist (feat _artist2) - Track @ awesome (also artist3 & artist4) [00:00]", "Tweet Built Correctly");
};

done_testing();
