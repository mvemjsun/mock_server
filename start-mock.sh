#!/usr/bin/env bash
echo "Trying to start stop mock server ..."

PID=`lsof -i:9293 | grep ruby | grep -v grep | awk '{print $2}'`

if [[ -z "$PID" ]]
then
  echo "No mock server running."
else
  echo "Mock server is running with PID $PID. Will kill and restart."
  kill -9 $PID
fi
echo "Starting mock server now"
sleep 2
rackup > /dev/null 2>&1 &
sleep 5

PID=`lsof -i:9293 | grep ruby | grep -v grep | awk '{print $2}'`

if [[ -z "$PID" ]]
then
  echo "Failed to start mock server"
  exit 1
else
  echo "Mock server started"
fi