#!/bin/bash
# Author: Maxim Vasilev <mxmvasilyev0@gmail.com>
# Description: Collect per process memory usage and report to StatsD

# Raise an error in case of unbound var
set -u

###
# Options
###

# Set to any value to use UDP instead of TCP
stats_udp=
statsd_host=localhost
statsd_port=8125

report_file="/tmp/mem_report.$$.txt"

# Path to log file (use stdout to print to terminal)
log_path="stdout"
# Redirect output by child processes to log
log_applications=false
debug=false

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

    ps -e --no-headers -o "pid,%mem" \
    | while read line
    do
        words=($line)
        echo "${words[0]}:${words[1]}|g" >> "$report_file"
    done
}

cleanUp() {
    [ -f "$report_file" ] && rm "$report_file"
}

sendStats() {
    cat "$report_file" \
    | nc ${stats_udp:+"-u"} "$statsd_host" "$statsd_port"
}

logEvent() {
    timestamp=`date -R`
    log_msg="$@"

    if [[ $log_path = "stdout" ]]
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

    cleanUp
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

collectMemStats
sendStats || errorExit $? "Failed to send metrics to StatsD"
cleanUp
