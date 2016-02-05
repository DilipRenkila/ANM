#!/bin/sh
set -o xtrace
TOP_DIR=$(cd $(dirname "$0") && pwd)
chmod 777 $TOP_DIR
BACKEND=$TOP_DIR/backend.pl
if [ ! -d $FILES ]; then
    die $LINENO "missing ASSIGNMENT4/backend.pl"
fi
if [[ $EUID -eq 0 ]]; then
    echo "You are running this script as root."
    echo "Cut it out."
    echo "Really."
    echo "$TOP_DIR/run.sh"
    exit 1
fi
while [ true ]
do
    start=`date +%s`
    perl $TOP_DIR/backend.pl 
    end=`date +%s`
    runtime=$((end-start))
    sleep $((30-runtime))
done
