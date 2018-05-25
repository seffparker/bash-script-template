#!/bin/bash

## Bash Script Template
## Version: 20180518
## Author: Seff P.

MY_PID=/var/run/task1.pid
MY_LOG=/var/log/task1.log
MY_PID_MAXAGE=43200 #12h

echolog(){
	if [ $# -eq 0 ]
	then cat - | while read -r message
		do
                echo "$(date +"[%F %T %Z] -") $message" | tee -a $MY_LOG
	        done
	else
		echo -n "$(date +'[%F %T %Z]') - " | tee -a $MY_LOG
		echo $* | tee -a $MY_LOG
	fi
}

if [ -f $MY_PID ]
        then
        if kill -0 $(cat $MY_PID) 2> /dev/null
                then MY_PID_AGE=$(expr `date +%s` - `stat -c %Z $MY_PID`)
                if [ $MY_PID_AGE -gt $MY_PID_MAXAGE ]
                        then
                        echolog "WARNING: Previous process (PID $(cat $MY_PID)) looks stuck. Force removing..."
                        pkill -9 -g $(cat $MY_PID)
                        rm -f $MY_PID
                else
                        echolog "ERROR: Another instance of this process (PID $(cat $MY_PID)) is already running"
                        exit 1
                fi
        else
                echolog "ERROR: PID file $MY_PID exists, but process looks dead"
                exit 1
        fi
fi

echolog "INFO: Process starting... (PID: $$)"
echo $$ > $MY_PID
#command1 | echolog

if [ "${PIPESTATUS[0]}" == "0" ]
        then echolog "INFO: Process completed (Removing PID $$)"
else
        echolog "ERROR: Process failed with code ${PIPESTATUS[0]} (Removing PID $$)"
fi

rm -f $MY_PID