#!/bin/bash

task="$1 $2"
config=$3

helpFunc() {
  echo "Help:"
  echo "Available Commands:"
  echo "$(printf '\tstart environment')"
  echo "$(printf '\tstop environment')"
  echo "$(printf '\trestart environment')"
  echo "$(printf '\tcreate topics <topicsFile> -> (default: application-mock.yml)')"
  echo "$(printf '\tstart mock <configurationName> -> (yml file to execute: application-mock-${configurationName}.yml)')"
  echo "$(printf '\trun-only mock <configurationName> -> (yml file to execute: application-mock-${configurationName}.yml)')"
}

startEnvironment() {
  echo "Starting kafka environment..."
  docker-compose -f internal/environment/environment-compose.yml up -d
  docker build -f internal/topics/Dockerfile -t ktc-application:latest .
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

createTopics() {
  docker rm -f ktc-container
  if [ -z "$config" ]; then
    echo "Starting topics from application-mock.yml..."
    winpty docker run --network=host --name=ktc-container -t -i ktc-application
    else
      echo "Starting topics from $config..."
    winpty docker run --network=host --name=ktc-container -t -i -e TOPICS_FILE="$config" ktc-application
  fi
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
"create topics")
  createTopics
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
