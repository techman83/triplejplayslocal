package App::TriplejPlaysLocal::Song;

use v5.010;
use autodie;
use Carp qw(croak);
use Method::Signatures;
use Moo;
use namespace::clean;

# ABSTRACT: Song Object

# VERSION: Generated by DZP::OurPkg:Version

=head1 SYNOPSIS

    use App::TriplejPlaysLocal::Song;

    my $song = App::TriplejPlaysLocal::Song->new(
      id      => '1234',
      tweet   => 'Artist - Song [time]',
    );

=head1 DESCRIPTION

A Tweet.

=cut

has 'id'      => ( is => 'ro', required => 1 );
has 'tweet'   => ( is => 'ro', required => 1 );
has 'artist'  => ( is => 'rw', lazy => 1, builder => 1 );
has 'track'   => ( is => 'rw', lazy => 1, builder => 1 );
has 'time'    => ( is => 'rw', lazy => 1, builder => 1 );

method _build_time {
  $self->tweet =~ m{\[(?<time>\d+:\d+)\]$}x;
  return $+{'time'};
}

method _build_track {
  $self->tweet =~ m{\s-\s(?<track>.+).\[}x;
  return $+{track};
}

method _build_artist {
  $self->tweet =~ m{^(?<artist>.+)\s-}x;
  my $artist = $+{artist};
  if ( $artist =~ m/@(?<screen_name>.+)/ ) {
    # It'd be great to grab full name from Twitter
    #$artist = $nt->lookup_users({ screen_name => $+{screen_name} });
    return $+{screen_name};
  } else {
    return $artist;
  }
}

method build_tweet {
  return $self->artist." - ".$self->track." [".$self->time."]";
}

1;
