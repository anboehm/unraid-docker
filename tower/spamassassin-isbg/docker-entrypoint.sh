#!/bin/bash
set -e

# check for Enviroment variables

if [[ -z "${IMAPSERVER}" || -z "${IMAPUSER}" || -z "${IMAPPASS}" || -z "${LEARNSPAMBOX}" || -z "${LEARNHAMBOX}" || -z "${IMAPINBOX}" || -z "${IMAPSPAMBOX}" ]]; then
  echo "Environment variables not set!"
  echo "IMAPSERVER: $IMAPSERVER"
  echo "IMAPUSER: $IMAPUSER"
  echo "IMAPPASS: $IMAPPASS"
  echo "LEARNSPAMBOX: $LEARNSPAMBOX"
  echo "LEARNHAMBOX: $LEARNHAMBOX"
  echo "IMAPINBOX: $IMAPINBOX"
  echo "IMAPSPAMBOX: $IMAPSPAMBOX"
  exit 1
fi



# Start the first process
if [ $( ps axf | grep -c -E "[r]syslog" ) -eq 0 ] ; then
  sudo service rsyslog start
fi

if [ $( ps axf | grep -c -E "[c]ron" ) -eq 0 ] ; then
  sudo service cron start
fi

if [ $( ps axf | grep -c -E "[u]nbound" ) -eq 0 ] ; then
  sudo service unbound start
fi

# Run on first start
if [ -f /tmp/INIT ] ; then
  sudo /etc/cron.daily/sa-update
  rm /tmp/INIT
fi

# Start spamassassin
if [ $( ps axf | grep -c -E "[s]pamd" ) -eq 0 ] ; then
  sudo service spamassassin start
fi


while true
do
  # Lerne Spam/Ham
  isbg \
    --teachonly \
    --imaphost="$IMAPSERVER" \
    --imapuser="$IMAPUSER" \
    --imappasswd="$IMAPPASS" \
    --learnspambox="$LEARNSPAMBOX" \
    --learnhambox="$LEARNHAMBOX" \
    --movehamto="$IMAPINBOX" \
    --noninteractive

#  echo "Starting scan on $(date)"
  isbg \
    --flag \
    --imaphost="$IMAPSERVER" \
    --imapuser="$IMAPUSER" \
    --imappasswd="$IMAPPASS" \
    --imapinbox="$IMAPINBOX" \
    --spaminbox="$IMAPSPAMBOX" \
    --noninteractive

#  echo "Sleep for 60 seconds"
  sleep 60

done | tee -a /var/lib/spamassassin/.spamassassin/spamd.log
