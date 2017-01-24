# alert-bitcoin-usd-price
This program compares the price of Bitstamp "btcusd" to a condition-price value specified by the user.  An example condition-price is '<789.00' or '>1100.00'.  If the Bitstamp "btcusd" price satisfies the alert condition, (less than or greater than the specified value), several notification actions may be performed.  When run periodically as a _cron_ job, this program may serve as a "buy" or a "sell" alert.

The program fetches the current _BID_ price of Bitstamp "btcusd" from a ticker and applies a condition-price value to the BTC price.  If the Bitstamp "btcusd" satisfies the condition-price specified, user notification is performed as follows:

  1. Bitcoin BTC price and condition-price alert value are output to _STDOUT_
  2. An alert notification is sent to the _GUI_ (Desktop)
  3. Email notification is sent if enabled
  4. If enabled, a notification message is sent to an AWS SNS Topic via the AWS CLI
  
Item (4) above is especially useful when an _AWS SNS SMS (Text Message) Subscriber_ is subscribed to an _AWS SNS Topic_.  This allows the user to receive text messsage notifications to their cell phone.

The source of Bitcoin price data is _https://www.bitstamp.net_.

### Installation
After cloning this project or downloading/unzipping the project zip file, copy _alert-btcusd-price.sh_ into a directory in which the user has permissions, and ensure the file permission is set as _executable_.

### Basic Command Line Syntax
The condition-price in this example below is specified as _'<789.00'_.  Thise means send a notification when the BTC price falls below $789.99.  Change this value to set the price at which notification is performed.  If email notification is desired, set the user's email address in place of the email address in the example below.  If no email notification is desired, remove the email address "example@example.com".  If "example@example.com" is not removed from the example below, the host will waste CPU and IO cycles pointlessly attempting to send unnecessary email, and email notifications of delivery failures may arrive in the host admin's mailbox.

        alert-btcusd-price.sh '<789.99' example@example.com

Alternately, the program may be used to notify the user if the BTC price rises above a specified value.  The condition-price in this example below is specified as _'>1234.99'_.  Thise means send a notification when the BTC price rises above $1200.  Change this value to set the price at which notification is performed.

        alert-btcusd-price.sh '>1234.99' example@example.com

Optionally, numerals after the decimal may be omitted, e.g., values of '<789' or '>1234' are accepted.

Note that the single quotes surrounding the condtion-price argument are required.  If the single quotes are omitted the program may behave in and undesireable manner.
        
### Used As A Buy Or Sell Alert
If the user wishes to have the price checked regularly by cron, add the line of code shown below to the user's crontab .  The example line below causes the script to be executed once per 10 minutes.  Modify the example below accordingly if the script should be run more or less often.  The example code shown below assumes the user has alert-btcusd-price.sh stored in a directory named "bin", in the "user" home directory. If stored in some other path, adjust this example accordingly.  

        */10 * * * * /home/user/bin/alert-btcusd-price.sh '<789.99' example@example.com >/dev/null 2>&1

If the user wishes to have a notification message sent to an AWS SNS Topic, the following environment variable must be defined *in the crontab file*, as given in this example :

        BTCUSD_PRICE_ALERT_AWS_SNS_TOPIC="arn:aws:sns:us-west-2:NNNNNNNNNNNN:bitcoin-usd-price-alert"


#### Important
In order for email notifications to work correctly, the admin must ensure the _mail_ utility is installed and configured properly.

In order for _AWS SNS_ notifications to work correctly, the admin must ensure that the _AWS CLI_ is installed and configured properly.  Also, the admin must ensure that an _SNS Topic_ and _SNS Subscription_ have been created and joined properly, in the _AWS SNS Console_.
