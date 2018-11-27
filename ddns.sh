#!/bin/bash

KEY='' # API Key from Dreamhost
CURRIP=`curl -s ifconfig.co`
DNSREC='pi.example.com' # DNS record to check/update
UUID=`uuidgen`
CMD0='dns-list_records'
CMD1='dns-remove_record'
CMD2='dns-add_record'

date
echo "NEW IP: $CURRIP"

# List records
LINK="https://api.dreamhost.com/?key=$KEY&unique_id=$UUID&cmd=$CMD0"
RESPONSE=`curl -s -X GET "$LINK"`

#echo "$LINK"
#echo "$REPSONSE"

# Check IP of existing record
OLDIP=`echo "$RESPONSE" | grep $DNSREC | awk '{ print $5 }'`
echo "OLD IP: $OLDIP"

# Check if NEW/OLD IPs match
if [ "$CURRIP" = "$OLDIP" ]; then
  echo "SAME IP WILL NOT UPDATE RECORD"
  exit
fi

# Different IP remove/update

# Remove record 
UUID=`uuidgen`
ARGS="record=$DNSREC&type=A&value=$OLDIP"
LINK="https://api.dreamhost.com/?key=$KEY&unique_id=$UUID&cmd=$CMD1&$ARGS"
RESPONSE=`curl -s -X GET "$LINK"`

#echo "$LINK"
echo "$RESPONSE"

# Add record
UUID=`uuidgen`
ARGS="record=$DNSREC&type=A&value=$CURRIP&comment=PI"
LINK="https://api.dreamhost.com/?key=$KEY&unique_id=$UUID&cmd=$CMD2&$ARGS"
RESPONSE=`curl -s -X GET "$LINK"`

#echo "$LINK"
echo "$RESPONSE"
