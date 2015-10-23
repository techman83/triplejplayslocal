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
Tweeting: icecube - It Was A Good Day [10:23]
```

It will tweet based on the current local time of the running profile.
Currently writes to stdout, but likely will set it to log to a file 
and daemonize rather than running in the foreground.

Author + License
================
Leon Wright < techman@cpan.org >
License: Perl_5

