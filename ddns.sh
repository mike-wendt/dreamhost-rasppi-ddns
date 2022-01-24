#!/bin/bash

KEY='' # API Key from Dreamhost
CURRIP=`curl -s ifconfig.co`
DNSREC='pi.example.com' # DNS record to check/update
CMD0='dns-list_records'
CMD1='dns-remove_record'
CMD2='dns-add_record'

# Helper function for timestampped logging
function logger {
  TS=`date`
  echo "[$TS] $@"
}

# Helper function for running curl requests
#  $1 = URL to send
#  $2 = Description of request
#  returns response in $RESPONSE
function send_request {
  UUID=`uuidgen`
  RESPONSE=`curl -s -X GET "$1"`

  # Check for success
  if ! (echo $RESPONSE | grep -q 'success'); then
    logger "ERROR: Unsuccessful response for request - $2"
    logger "$RESPONSE"
    exit 1
  else
    logger "INFO: Successful request - $2"
  fi
}

logger "INFO: Current Public IP - $CURRIP"

# List records
send_request "https://api.dreamhost.com/?key=$KEY&unique_id=$UUID&cmd=$CMD0" "List records"

# Check IP of existing record
OLDIP=`echo "$RESPONSE" | grep $DNSREC | awk '{ print $5 }'`
logger "INFO: DNS Record IP - $OLDIP"

# Check if NEW/OLD IPs match
if [[ "$CURRIP" == "$OLDIP" ]]; then
  logger "INFO: Current IP matches existing record, no need to update..."
  exit
elif [[ "$OLD_IP" != "" ]]; then
  logger "INFO: Different IP detected, updating record..." 
  send_request "https://api.dreamhost.com/?key=$KEY&unique_id=$UUID&cmd=$CMD1&record=$DNSREC&type=A&value=$OLDIP" "Remove record"
fi

# Add record
send_request "https://api.dreamhost.com/?key=$KEY&unique_id=$UUID&cmd=$CMD2&record=$DNSREC&type=A&value=$CURRIP&comment=PI" "Add record"
