FROM perl:5 as build
ADD . /tmp/triplejplays
WORKDIR /tmp/triplejplays
RUN cpanm Dist::Zilla
RUN dzil authordeps | cpanm
RUN dzil listdeps   | cpanm
RUN dzil test
RUN dzil build

FROM perl:5 as production
ENV TZ=Australia/Perth
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
COPY --from=build /tmp/triplejplays/TriplejPlaysLocal-0.04.tar.gz /tmp/
RUN cpanm --notest /tmp/TriplejPlaysLocal-0.04.tar.gz
RUN useradd -ms /bin/bash triplej
WORKDIR /home/triplej
USER triplej
ENTRYPOINT ["triplejplays"]

FROM production