#!/bin/bash
# This program compares the price of Bitstamp "btcusd" against an alert
# condition-price.  An example condition-price is '<789.00' or '>1100.00'.
# If the Bitstamp "btcusd" price satisfies the alert condition, the BTC price
# and trigger condition-price are displayed to STDOUT, an alert notification is
# sent to the GUI (Desktop), email notification is sent, and if an environment
# variable is defined, a notification message is sent to that AWS SNS Topic.
#
# The source of the price data is https://www.bitstamp.net
#
# This script has been tested only on Ubuntu 14.10 DESKTOP version.
#
# rex addiscentis 2017/01/23
# Apache 2.0 License
# https://github.com/addiscent

# in case of multiple hosts sending notifications,
# set sending host name here
btcusd_price_hostname="Esmerelda"

############  constants  ############

TRUE="1"
OKAY="0"

ERR_USAGE="1"
ERR_SUSPECT_PRICE="2"

NUM_ARGS="$#"
COMPARE_PRICE="$1"
NOTIFY_EMAIL_ADDRESS="$2"

############  function return value variables  ############
validate_usage=""
notify_suspect_btc_price=""


######################## Begin Function Definitions  #########################

# script invocation must specify a condition-price on command line.
# return val of func is in script variable of same name as func
function validate_usage () {
  if [ $NUM_ARGS \< 1 ]; then
    echo "Usage   :  alert-btcusd-price.sh  condition-price  [emailaddress]"
    echo "Example 1 :  alert-btcusd-price.sh  '<789.00'  example@example.com"
    echo "Example 2 :  alert-btcusd-price.sh  '>1100.00'  example@example.com"
    echo "AWS SNS Topic environment variable example : BTCUSD_PRICE_ALERT_AWS_SNS_TOPIC="
    echo "    arn:aws:sns:us-west-2:NNNNNNNNNNNN:bitcoin-usd-price-alert"
    echo "Alarm \"set\" condition-price required.  Exiting, nothing done"
    validate_usage="$ERR_USAGE"
    return
  fi
  validate_usage="$OKAY"
}


# https://www.bitstamp.net service could have been unavailable during fetch.
# Detect if suspect.
# return val of func is in script variable of same name as func
function notify_suspect_btc_price () {
#  btc_price=0 # for testing only
  if [ "$btc_price" \< "1" ] ; then
    if [ "$NOTIFY_EMAIL_ADDRESS." != "." ] ; then
  mail -s "Bitcoin Price Alert ($btcusd_price_hostname)" "$NOTIFY_EMAIL_ADDRESS" << EOF
From Bitcoin Price Monitor - Notification :

   Suspect data received from :
     https://www.bitstamp.net/api/v2/ticker/btcusd/
   Service may be unavailable.
   Bitcoin BTC price : \$$btc_price
EOF
    fi
    notify_suspect_btc_price="$ERR_SUSPECT_PRICE"
    return
  fi
  notify_suspect_btc_price="$OKAY"
}


# test for condition-price alert trigger and do notification if necessary.
# use calculator (bc) for floating point compare test.
function notify_btc_price () {
  if [ $(echo "$btc_price$COMPARE_PRICE" | bc) == $TRUE ] ; then
    # notify on GUI desktop
    DISPLAY=:0 notify-send "Bitcoin Price Notification" "Bitcoin BTC price \$$btc_price\ntriggers condition-price alert '$COMPARE_PRICE'"
    # if an email address is provided on cmd line, send notification via email
    if [ "$NOTIFY_EMAIL_ADDRESS." != "." ] ; then
    mail -s "'Bitcoin Price Alert ($btcusd_price_hostname)" "$NOTIFY_EMAIL_ADDRESS" << EOF
From Bitcoin Price Monitor - Notification :

   Bitcoin BTC price \$$btc_price,
   triggers condition-price alert "$COMPARE_PRICE"
EOF
    fi
    # if an AWS SNS topic is defined in a parent ENV variable,
    # send a notification to it
    if [ "$BTCUSD_PRICE_ALERT_AWS_SNS_TOPIC." != "." ] ; then
      aws sns publish --topic-arn "$BTCUSD_PRICE_ALERT_AWS_SNS_TOPIC" --message "Bitcoin BTC price \$$btc_price triggers condition-price alert '$COMPARE_PRICE'" --output json
    fi
  fi
}

######################### End Function Definitions  ##########################


################################ Begin MAIN  #################################

#set -x

# must specify an alert "set" condition-price on command line.
# return val of func is in script variable of same name as func
validate_usage 
if [ "$validate_usage" == "$ERR_USAGE"  ]; then exit $ERR_USAGE ; fi

# fetch the json block containing current bitstamp btcusd prices and
# extract "bid" price
btc_price=$(curl https://www.bitstamp.net/api/v2/ticker/btcusd/ | awk -F ': "' '{print $5}' | cut -c1-6)

# for debug trace or whatever
echo "BTC price : \$$btc_price"
echo "Alert condition-price trigger : $1"

# https://www.bitstamp.net service could have been unavailable during fetch.
# Detect and exit if suspect.
# return val of func is in script variable of same name as func
notify_suspect_btc_price
if [ "$notify_suspect_btc_price" == "$ERR_SUSPECT_PRICE"  ]; then exit $ERR_SUSPECT_PRICE ; fi

# test for condition-price alert trigger and do notification if necessary
notify_btc_price

#set +x

exit 0

################################# End MAIN  ##################################

