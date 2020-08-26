#!/bin/bash
# Author: Maxim Vasilev <admin@qwertys.ru>
# Description: A template for bash scripts

# Raise an error in case of unbound var
set -u
myname=`basename $0`

###
# Options
###

hostlist="./hosts.txt"
reporter_script="./reporter.sh"
cron_interval="* * * * *"

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

setupHost(){
    user=${1%%@*}
    host=${1##*@}

    cron_line="$cron_interval bash ~/.reporter.sh"
    crontab="/var/spool/cron/crontabs/$user"

    cat "reporter_script" \
    | ssh -o 'BatchMode=yes' "$user"@"$host" \
        cat > ~/.reporter.sh \
        ';' grep "$cron_line" "$crontab" \
        '||' echo "$cron_line" '>>' "$crontab"
    if [[ $? = 0 ]]
    then
        logEvent "Host $host has been set up successfully"
    else
        logEvent "Failed to set host $host up"
    fi
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

[ -f "$hostlist" ] || errorExit 1 "Could not find host list"
[ -f "$reporter_script" ] || errorExit 1 "Could not find reporter script"

while read hostline
do
    setupHost $hostline &
done < "$hostlist"

exit 0
