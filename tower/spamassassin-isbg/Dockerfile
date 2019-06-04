FROM ubuntu:latest
MAINTAINER Andreas Böhm <andreas@boehm-sef.de>

ENV DEBIAN_FRONTEND=noninteractive TZ=Europe/Berlin
ENV SPAMD_UID=999 SPAMD_GID=999
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# installation
RUN apt-get -qq update && apt-get -y install sudo spamassassin pyzor imapfilter python3-pip unbound rsyslog wget tzdata &&\
    apt-get autoremove --purge &&\
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /root/.cache/pip &&\
    pip3 --no-cache-dir install isbg

# change uuid / gid
RUN usermod -o -u ${SPAMD_UID} debian-spamd && groupmod -o -g ${SPAMD_GID} debian-spamd

# copying custom system files
COPY unbound-ipv4only.conf /etc/unbound/unbound.conf.d/unbound-ipv4only.conf
COPY spamd_sudoers /etc/sudoers.d/spamd_sudoers
COPY cron_sa-update /etc/cron.daily/sa-update

# modifying spamd configuration
COPY default_spamassassin /etc/default/spamassassin
COPY local.cf /etc/spamassassin/local.cf

COPY docker-entrypoint.sh docker-entrypoint.sh
RUN touch /tmp/INIT &&\
    chown debian-spamd:debian-spamd /docker-entrypoint.sh /tmp/INIT &&\
    chmod 500 /docker-entrypoint.sh /etc/cron.daily/sa-update


# SWITCH USER
USER debian-spamd:debian-spamd

VOLUME /var/lib/spamassassin/

ENTRYPOINT ["/docker-entrypoint.sh"]
