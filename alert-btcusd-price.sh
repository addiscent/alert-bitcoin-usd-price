#!/bin/bash
# This program compares the price of Bitstamp "btcusd" against an alarm value.
# If the Bitstamp "btcusd" price is lower than the alarm value, the bid price
# and set price are displayed to STDOUT, an alert notification is sent to
# the GUI, and an email notification is sent.
#
# The source of the price data is https://www.bitstamp.net
#
# This script has been tested only on Ubuntu 14.10 DESKTOP version.
#
# rex addiscentis  2016/12/10
# Apache 2.0 License
# https://github.com/addiscent


# must specify an alarm "set" price on command line
if [ $# -lt 1 ]; then
  echo "Usage   :  alert-btcusd-price.sh  price  [emailaddress]"
  echo "Example :  alert-btcusd-price.sh  789    example@example.com"
  echo "Alarm \"set\" value required, exiting, nothing done"
  exit 1
fi

#set -x

# fetch the json block containing current bitstamp btcusd prices and
# extract "bid" price
bid=$(curl https://www.bitstamp.net/api/v2/ticker/btcusd/ | awk -F ': "' '{print $5}' | cut -c1-6)

# for debug trace or whatever
echo "BID price is    : \$$bid"
echo "Alarm SET price is : \$$1"

# https://www.bitstamp.net service could have been unavailable during fetch.
# Detect and exit if suspect
if [ "$bid" \< "1" ] ; then
  if [ $# = 2 ] ; then
  mail -s 'Bitcoin Price Alert (Quasimodo)' "$2" << EOF
From Bitcoin Price Monitor - Notification :

   Suspect data received from :
     https://www.bitstamp.net/api/v2/ticker/btcusd/
   Service may be unavailable.
   Bitcoin BID price : \$$bid
EOF
  fi
  echo "Suspect data received, service may be unavailable, exiting"
  exit 0
fi

# test for price alarm trigger and do notification if necessary
# use calculator (bc) for floating point compare test.
true="1"

if [ $(echo "$bid < $1" | bc) == $true ] ; then
  DISPLAY=:0 notify-send "Bitcoin Price Notification" "Bitcoin BID price \$$bid\nis below SET Alarm \$$1" 
  if [ $# = 2 ] ; then
    mail -s 'Bitcoin Price Alert (Quasimodo)' "$2" << EOF
From Bitcoin Price Monitor - Notification :

   Bitcoin BID price \$$bid,
   is below alert SET price \$$1
EOF
  fi
fi

#set +x

exit 0

