#!/usr/bin/env bash
echo "Trying to stop mock server ..."

PID=`lsof -i:9292 | grep ruby | grep -v grep | awk '{print $2}'`

if [[ -z "$PID" ]]
then
  echo "No mock server running."
else
  echo "Mock server is running with PID $PID. Will kill now."
  kill -9 $PID
fi

sleep 3

PID=`lsof -i:9292 | grep ruby | grep -v grep | awk '{print $2}'`
if [[ -z "$PID" ]]
then
  echo "Mock server stopped."
else
  echo "Could not stop mock server."
  exit 1
fi