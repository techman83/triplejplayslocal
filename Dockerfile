FROM perl:5 as build
ADD . /tmp/triplejplays
WORKDIR /tmp/triplejplays
RUN cpanm Dist::Zilla --notest && \
    dzil authordeps | cpanm --notest && \
    dzil listdeps   | cpanm --notest
RUN dzil test
RUN dzil build

FROM perl:5 as production
COPY --from=build /tmp/triplejplays/TriplejPlaysLocal-0.04.tar.gz /tmp/
RUN cpanm --notest /tmp/TriplejPlaysLocal-0.04.tar.gz
RUN useradd -ms /bin/bash triplej
WORKDIR /home/triplej
USER triplej
ENTRYPOINT ["triplejplays"]

FROM production
