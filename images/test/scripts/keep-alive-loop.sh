#!/bin/bash
set -e

#Define cleanup procedure
cleanup() {
    echo "Container stopped, performing cleanup..."
    export DONE=1
}


echo -e "Setting up test container"


#Trap SIGTERM
trap 'cleanup' SIGTERM


echo "now waiting in a loop"

while [ -z "$DONE" ]; do
	  sleep 1
done
echo "done"
