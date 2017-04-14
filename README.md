# dreamhost-rasppi-ddns
Script to update Dynamic DNS for Raspberry Pi using Dreamhost's API

## Requirements

Need to install package `uuid-runtime` for `uuidgen`

## Config

Update `KEY` and `DNSREC` to match your records and needs

## Usage

Run in crontab and `ddns.sh` script will update DNS record only if the IP in the record is different than the current IP
