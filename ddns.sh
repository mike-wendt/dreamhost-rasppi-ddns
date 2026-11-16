#!/bin/bash

KEY='' # API Key from Dreamhost
CURRIP=`curl -s https://ifconfig.me`
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
echo "$RESPONSE" | grep $DNSREC | awk '{ print $5 }' > /tmp/ddns-entries.txt
logger "INFO: DNS Record IP(s): $(cat /tmp/ddns-entries.txt | tr '\r\n' ' ')"

# Track if CURRIP is found in the existing records
CURRIP_EXISTS=0

# Iterate through the existing records to clean up or record the CURRIP existance
while read OLDIP; do
  logger "INFO: Checking existing DNS record ($OLDIP) against current IP ($CURRIP)"
  # Check if NEW/OLD IPs match
  if [[ "$CURRIP" == "$OLDIP" ]]; then
    logger "INFO: Verified current IP ($CURRIP) matches existing record, no need to update..."
    CURRIP_EXISTS=1
  elif [[ "$CURRIP" != "$OLDIP" ]]; then
    logger "INFO: Detected outdated record ($OLDIP), removing record..." 
    send_request "https://api.dreamhost.com/?key=$KEY&unique_id=$UUID&cmd=$CMD1&record=$DNSREC&type=A&value=$OLDIP" "Remove record"
  fi
done < /tmp/ddns-entries.txt

# Add record only if CURRIP_EXISTS is 0
if [[ $CURRIP_EXISTS == 0 ]]; then
  logger "INFO: Adding new IP record ($CURRIP) after no existing record found..."
  send_request "https://api.dreamhost.com/?key=$KEY&unique_id=$UUID&cmd=$CMD2&record=$DNSREC&type=A&value=$CURRIP&comment=PI" "Add record"
fi
