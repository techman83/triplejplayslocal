package App::TriplejPlaysLocal::Logger;

use Log::Log4perl;
use Method::Signatures;
use Moo::Role;

# ABSTRACT: Logging for App::TriplejPlays

# VERSION: Generated by DZP::OurPkg:Version

=head1 SYNOPSIS

Provides a central logging service for App::TriplejPlaysLocal

=head1 DESCRIPTION

  with('App::TriplejPlaysLocal::Logger');

Can be consumed by any App::TriplejPlaysLocal  package.

Inspiratation/Credit here -> http://stackoverflow.com/questions/3018528/making-self-logging-modules-with-loglog4perl

=cut

our $DEBUG = $ENV{TRIPLEJ_DEBUG} || 0;

my @methods = qw(
  log trace debug info warn error fatal
  is_trace is_debug is_info is_warn is_error is_fatal
  logexit logwarn error_warn logdie error_die
  logcarp logcluck logcroak logconfess
);

has _logger => (
  is        => 'ro',
  isa       => sub { 'Log::Log4perl::Logger' },
  lazy      => 1,
  builder   => 1,
  handles   => \@methods,
);

has _log_level  => ( is => 'ro', lazy => 1, builder => 1 );
has log_config  => ( is => 'ro', lazy => 1, builder => 1 );

method _build_log_config() {
  my $log_level = $self->_log_level;
  return qq(
    log4perl.rootLogger              = $log_level
    log4perl.appender.SCREEN         = Log::Log4perl::Appender::Screen
    log4perl.appender.SCREEN.stderr  = 0
    log4perl.appender.SCREEN.layout  = Log::Log4perl::Layout::PatternLayout
    log4perl.appender.SCREEN.layout.ConversionPattern = %m %n
  );
}

method _build__log_level {
  if ( ! $DEBUG ) {
    return "INFO, SCREEN";
  } else {
    return "DEBUG, SCREEN";
  }
}

around $_ => sub {
  my $orig = shift;
  my $this = shift;

  # one level for this method itself
  # two levels for Class:;MOP::Method::Wrapped (the "around" wrapper)
  # one level for Moose::Meta::Method::Delegation (the "handles" wrapper)
  local $Log::Log4perl::caller_depth;
  $Log::Log4perl::caller_depth += 4;

  my $return = $this->$orig(@_);

  $Log::Log4perl::caller_depth -= 4;
  return $return;

} foreach @methods;

method _build__logger() {
  my $this = shift;

  my $loggerName = ref($this);
  $self->log_config;
  Log::Log4perl->init_once(\$self->log_config);
  return Log::Log4perl->get_logger($loggerName)
}

1;
