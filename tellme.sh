#!/bin/bash
TELLME_HOME=/home/stu/projects/github/stupenrose/tellmewhen
APPLAUSE=$TELLME_HOME/applause.wav
ALERT=$TELLME_HOME/alert.wav
PROBLEM_ALERT=$TELLME_HOME/angry.wav
. ~/.tellmewhen # <- for secrets like the TWILIO_PHONE_NUMBER TWILIO_ACCOUNT_ID & TWILIO_TOKEN & your PHONE_NUMBER
##############################################

function sms {
	TO=$1
	MESSAGE=$2
	ENCODED=$(echo -n ${*:2:100} | perl -pe's/([^-_.~A-Za-z0-9])/sprintf("%%%02X", ord($MESSAGE))/seg');
        ACCOUNT="$TWILIO_ACCOUNT_ID"
        TOKEN="$TWILIO_TOKEN"
    curl -u $ACCOUNT:$TOKEN --data "From=+$TWILIO_PHONE_NUMBER&To=+$TO&Body=$MESSAGE" https://api.twilio.com/2010-04-01/Accounts/$ACCOUNT/SMS/Messages.json > /dev/null 2>&1
}


CMD=$@
eval "$CMD"
RESULT=$?
if [ "$RESULT" -ne 0 ]
then
    MESSAGE="FAILED: $CMD"
    paplay $ALERT &
    paplay $PROBLEM_ALERT &
else
    MESSAGE="DONE: $CMD"
    paplay $APPLAUSE &
fi

notify-send "$MESSAGE"
sms $PHONE_NUMBER "$MESSAGE"

exit $RESULT
