#!/usr/bin/env perl

use 5.018;
use strict;
use warnings;

use Net::Twitter::Lite::WithAPIv1_1;
use Scalar::Util qw(blessed);
use List::MoreUtils qw(first_index);
use POSIX qw(strftime);
use Config::Tiny;
use EV;
use AnyEvent;
use Data::Dumper;

my $config = Config::Tiny->read( $ENV{HOME}."/.triplejplayswa" );

my $nt = Net::Twitter::Lite::WithAPIv1_1->new(
    consumer_key        => $config->{_}{consumer_key},
    consumer_secret     => $config->{_}{consumer_secret},
    access_token        => $config->{_}{access_token},
    access_token_secret => $config->{_}{access_token_secret},
    ssl                 => 1,
);

my @tweets;
my $since_id = undef;

my $get_tweets = AE::timer 0, 60, sub {
	say "Getting Tweets";
	my $id = undef;
	# Use try::tiny here
	eval {
	    my $timeline = { screen_name => 'triplejplays', count => 50 };
	    $timeline->{since_id} = $since_id if $since_id;
	    my $statuses = $nt->user_timeline($timeline);
	    for my $status ( @$statuses ) {
		if (! $id ) {
			say "Setting since_id to: $status->{id}";
			$id = $status->{id};
			$since_id = $id;
		}
		$status->{text} =~ m{^(?<artist>.+)\s-\s(?<track>.+).\[(?<time>.+)\]$}x;
		my $tweet = {
			id     => $status->{id},
			artist => $+{artist},
			track  => $+{track},
			time   => $+{time},
		};
		say Dumper($tweet);
		push(@tweets,$tweet);
	    }
	};
	# improve error handling, dying is not an option
	if ( my $err = $@ ) {
	    die $@ unless blessed $err && $err->isa('Net::Twitter::Lite::Error');
	 
	    warn "HTTP Response Code: ", $err->code, "\n",
	         "HTTP Message......: ", $err->message, "\n",
	         "Twitter error.....: ", $err->error, "\n";
	}
};

my $read_tweets = AE::timer 30, 60, sub {
	say "Checking Tweets";
	my $time = strftime("%H:%M", localtime(time));
	my $tweet_idx = first_index { $_->{time} eq $time } @tweets;
	say $tweet_idx;
	if ($tweet_idx != -1) {
		# Do some better logging
		my $amount = @tweets;
		say $amount;
		my $status = $tweets[$tweet_idx];
		say Dumper($status);
                
                # Lets comply with the twitter rules!
                my $artist;
                if ( $status->{artist} =~ m/@(?<screen_name>.+)/ ) {
                  # It'd be great to grab full name from Twitter
                  #$artist = $nt->lookup_users({ screen_name => $+{screen_name} });
                  $artist = $+{screen_name};
                } else {
                  $artist = $status->{artist};
                }

                # Use better encoding/decoding
                $artist =~ s/&amp;/&/;
                 
		$nt->update("$artist - $status->{track} [$status->{time}]");
		splice @tweets, $tweet_idx, 1;
		$amount = @tweets;
		say $amount;
	};
	say "$time";
};

# Write a loop to run periodically to clean out old tweets.

EV::loop;
