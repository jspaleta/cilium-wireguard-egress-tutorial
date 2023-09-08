#!/bin/bash
set -e

#Define cleanup procedure
cleanup() {
    echo "Container stopped, performing cleanup..."
    export DONE=1
}


echo -e "Setting up relay-station container"


#Trap SIGTERM
trap 'cleanup' SIGTERM


echo "now waiting for connections on port 8080"
while  [ -z "$DONE" ]; do (echo -e 'HTTP/1.1 200 OK\r\n'; echo -e "\n\tMsg Recieved. Roger, Roger.")  | nc -q 1 -l 8080; done

echo "done"
