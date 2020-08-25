#!/bin/bash
# Author: Maxim Vasilev <admin@qwertys.ru>
# Description: A template for bash scripts

# Raise an error in case of unbound var
set -u
myname=`basename $0`

###
# Options
###

# Path to log file (use stdout to print to terminal)
log_path="stdout"
# Redirect output by child processes to log
log_applications=false
debug_enabled=true

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

orderReport(){
    remote_login="$1"
    remote_host="$2"
    remote_command='mtx=`ps --no-headers -o "pid,%mem" | while read line; do words=($line); echo "${words[0]}:${words[1]}|g"; done`'

    ssh -l $login $host $remote_command
}

collectMem(){
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
    logEvent "$@"
    exit $exit_code
}

###
# Internal stuff
###

# Enable debug?
[[ $debug_enabled = true ]] && set -x

# Redirect output
if [ "$log_applications" = "true" ]
then
    exec >> "$log_path"
    exec 2>> "$log_path"
fi

###
# main()
###

# Start your code here

exit 0
