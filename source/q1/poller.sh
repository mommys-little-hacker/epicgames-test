#!/bin/bash
# Author: Maxim Vasilev <mxmvasilyev0@gmail.com>
# Description: Collect per process memory usage from list of hosts and report it
# to StatsD

# Raise an error in case of unbound var
set -u

###
# Options
###

# Set to any value to use UDP instead of TCP
stats_udp=
statsd_host=localhost
statsd_port=8125

hostlist="./hosts.txt"

# Path to log file (use stdout to print to terminal)
log_path="stdout"
# Redirect output by child processes to log
log_applications=false
debug=true

###
# Globs
###

# Error codes
E_MISC=20
E_ARGS=21

# Log messages
LOG_E_MISC="Unknown error occurred."
LOG_E_ARGS="Invalid arguments supplied."

###
# Functions
###

collectMemStats(){
    set -o pipefail

    user=${1%%@*}
    host=${1##*@}
    report_file="/tmp/memstats.$$.txt"

    ssh -o 'BatchMode=yes' -l "$user" "$host" ps -e --no-headers -o "pid,%mem" \
    | while read line
    do
        words=($line)
        echo "${host}-${words[0]}:${words[1]}|g" >> "$report_file"
    done

    sendStats "$report_file" || {
        rm -f "$report_file" 2> /dev/null
        errorExit $? "Failed to send metrics to StatsD";
    }
    rm -f "$report_file"
}

sendStats() {
    cat "$1" \
    | nc -N ${stats_udp:+"-u"} "$statsd_host" "$statsd_port"
}

logEvent() {
    timestamp=`date -R`
    log_msg="$@"

    if [[ $log_path = stdout ]]
    then
        echo "[$timestamp] $log_msg"
    else
        echo "[$timestamp] $log_msg" >> $log_path
    fi
}

# Panic function
errorExit() {
    exit_code=$1
    shift
    exit_msg="$@"

    logEvent "$exit_msg"
    exit $exit_code
}

###
# Internal stuff
###

# Enable debug?
[[ $debug = true ]] && set -x

# Redirect output
if [ "$log_applications" = "true" ]
then
    exec >> "$log_path"
    exec 2>> "$log_path"
fi

###
# main()
###

while read hostline
do
    collectMemStats $hostline &
done < "$hostlist"
