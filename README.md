# alert-bitcoin-usd-price
This Bash script sends notification if the price of Bitcoin falls below a user specified set price.  When run periodically as a _cron_ job, it may serve as a "buy" alert.

This program fetches the current _BID_ price of Bitstamp "btcusd" from a ticker and compares it against an alarm _SET_ value.  If the _BID_ Bitstamp "btcusd" price is lower than the alarm _SET_ value, notification is performed as follows:

  1. Bitcoin _BID_ price and alert _SET_ value are output to _STDOUT_
  2. An alert notification is sent to the _GUI_
  3. Email notification is sent if enabled

The source of Bitcoin price data is _https://www.bitstamp.net_.

### Installation
After cloning this project or downloading/unzipping the project zip file, copy _alert-btcusd-price.sh_ into a directory in which the user has permissions, and ensure the file permission is set as _executable_.

### Basic Command Line Syntax
The alarm price _SET_ point in this example below is specified as _789_.  Change this value to set the price at which notification is performed.  If email notification is desired, set the user's email address in place of the email address in the example below.  If no email notification is desired, remove the email address "example@example.com".  If "example@example.com" is not removed from the example below, the host will waste CPU and IO cycles pointlessly attempting to send unnecessary email, and email notifications of delivery failures may arrive in the host admin's mailbox.

        alert-btcusd-price.sh 789 example@example.com

### Used As A Buy Alert
If the user wishes to have the price checked regularly by cron, add the line of code shown below to the user's crontab .  The example line below causes the script to be executed once per minute.  Modify the example below accordingly if the script should be run less frequently.  The example code shown below assumes the user has alert-btcusd-price.sh stored in a directory named "bin", in the "user" home directory. If stored in some other path, adjust this example accordingly.  

        * * * * * /home/user/bin/alert-btcusd-price.sh 789 example@example.com >/dev/null 2>&1

#### Important
In order for email notifications to work correctly, the admin must ensure the _mail_ utility is installed and configured properly.

