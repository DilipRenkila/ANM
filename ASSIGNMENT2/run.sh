#!/bin/sh
set -o xtrace
TOP_DIR=$(cd $(dirname "$0") && pwd)
chmod 777 $TOP_DIR
BACKEND1=$TOP_DIR/list.pl
BACKEND2=$TOP_DIR/network.pl
if [ ! -d $FILES ]; then
    die $LINENO "missing ASSIGNMENT2/network.pl"
fi
if [[ $EUID -eq 0 ]]; then
    echo "You are running this script as root."
    echo "Cut it out."
    echo "Really."
    echo "$TOP_DIR/run.sh"
    exit 1
fi
perl $TOP_DIR/list.pl
while [ true ]
do
    start=`date +%s`
    perl $TOP_DIR/network.pl
    perl $TOP_DIR/apache.pl
    end=`date +%s` 
    runtime=$((end-start))
    sleep $((300-runtime))
done
