triplej Plays Local
===================
A simple Triple J plays Time Shifter

Installation
============
I personally recommend using cpanminus + local::lib.

Grab cpanm + local::lib
```bash
$ sudo apt-get install cpanminus liblocal-lib-perl
```

Configure local::lib if you haven't already done so:

```bash
$ perl -Mlocal::lib >> ~/.bashrc
$ eval $(perl -Mlocal::lib)
```

Install from git, you can then use:
```bash
$ dzil authordeps | cpanm
$ dzil listdeps   | cpanm
$ dzil install
```

or cpanm (if I've released a package on Git):
```bash
cpanm TriplejPlaysLocal-0.01.tar.gz
```
Setup
=====
You will need to register for an app token here:
https://apps.twitter.com/

~/.triplejplays
```
consumer_key=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
consumer_secret=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
access_token=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
access_token_secret=xxxxxxxxxxxxxxxxxxxxxxxxxx
```

Usage
=====

Once installed and with the config file created, just launch it.
```
$ triplejplays 
$ tail ~/triplejplays.log -f
2015/10/25 10:56:33 INFO Tweeting: madeon - Imperium [10:56] 
2015/10/25 11:03:04 INFO Adding Tweet: (658114817564278784) .@vallisalps - Young [13:55] 
2015/10/25 11:03:04 INFO Adding Tweet: (658114323198418944) .@TheHardAches - Loser [13:53] 
```

It will tweet based on the current local time of the running profile. 
Does not account for live national broadcasts.

Author + License
================
Leon Wright < techman@cpan.org >
License: Perl_5
