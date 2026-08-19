#!/bin/sh
PORT=8080
PIDS=$(lsof -ti "tcp:$PORT")

if [ -z "$PIDS" ]; then
  echo "Nothing running on port $PORT"
else
  echo "$PIDS" | xargs kill
  echo "Stopped process(es) on port $PORT: $PIDS"
fi
