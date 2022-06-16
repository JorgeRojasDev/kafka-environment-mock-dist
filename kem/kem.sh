#!/bin/bash

task="$1 $2"
config=$3

helpFunc() {
  echo "Help:"
  echo "Commands Available:"
  echo "$(printf '\tstart environment')"
  echo "$(printf '\tstop environment')"
  echo "$(printf '\trestart environment')"
  echo "$(printf '\tstart mock <configurationName>')"
  echo "$(printf '\trun-only mock <configurationName>')"
}

startEnvironment() {
  echo "Starting kafka environment..."
  docker-compose -f internal/environment/environment-compose.yml up -d
}

stopEnvironment() {
  echo "Stopping kafka environment..."
  docker-compose -f internal/environment/environment-compose.yml down
}

restartEnvironment() {
  echo "Restarting kafka environment..."
  stopEnvironment
  startEnvironment
}

runOnlyMock() {
  echo "Running Mock with configuration $config"
  docker rm -f kem-container
  winpty docker run --network=host --name=kem-container -t -i -e MOCK_ENVIRONMENT="$config" kem-application
}

startMock() {
  docker image rm -f kem-application:latest
  docker build -f internal/Dockerfile -t kem-application:latest .
  runOnlyMock
}

case $task in
"start environment")
  startEnvironment
  ;;
"stop environment")
  stopEnvironment
  ;;
"restart environment")
  restartEnvironment
  ;;
"start mock")
  startMock
  ;;
"run-only mock")
  runOnlyMock
  ;;
*)
  helpFunc
  ;;
esac
