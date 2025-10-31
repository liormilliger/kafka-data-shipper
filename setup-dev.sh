#!/bin/bash
# This script installs dependencies and builds the project.
# It assumes it is being run from the root of the 'kafka-data-shipper' repo.

# Exit immediately if any command fails
set -e

echo "--- 1. Updating packages and installing dependencies ---"
sudo apt-get update -y
sudo apt-get install -y maven git docker.io docker-compose

echo
echo "--- 2. Building 'common' artifact ---"
mvn install -f ./common-files/common

echo
echo "--- 3. Building 'producer' artifact (skipping tests) ---"
mvn install -f ./common-files/producer -DskipTests

echo
echo "--- 4. Building 'consumer' artifact (skipping tests) ---"
mvn install -f ./common-files/consumer -DskipTests

echo
echo "--- ✅ All builds complete. ---"
echo

echo "--- 5. Starting the entire application stack (MySQL & KRaft Kafka) ---"

sudo docker-compose up --build -d

echo
echo "--- ✅ Stack is launching in the background. ---"
echo "You can view logs with: sudo docker-compose logs -f"
echo "To trigger the producer, run:"
echo "curl -X POST http://localhost:9000/producer/?count=100"