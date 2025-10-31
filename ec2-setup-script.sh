#!/bin/bash
set -e

REPO_URL="https://github.com/liormilliger/kafka-data-shipper.git"
PROJECT_DIR="kafka-data-shipper"

echo "--- 1. Updating packages and installing dependencies ---"
sudo apt-get update -y
sudo apt-get install -y maven git docker.io docker-compose

echo
echo "--- 2. Cloning the repository ---"
if [ -d "$PROJECT_DIR" ]; then
    echo "Removing existing directory: $PROJECT_DIR"
    sudo rm -rf $PROJECT_DIR
fi

git clone $REPO_URL $PROJECT_DIR
cd $PROJECT_DIR

echo "Successfully cloned repo and moved to $PROJECT_DIR"
echo "Current directory: $(pwd)"

echo
echo "--- 3. Building 'common' artifact ---"
mvn install -f ./common-files/common

echo
echo "--- 4. Building 'producer' artifact (skipping tests) ---"
mvn install -f ./common-files/producer -DskipTests

echo
echo "--- 5. Building 'consumer' artifact (skipping tests) ---"
mvn install -f ./common-files/consumer -DskipTests

echo
echo "--- ✅ All builds complete. ---"
echo

echo "--- 6. Starting the entire application stack (MySQL & KRaft Kafka) ---"
sudo docker-compose up --build -d

echo
echo "--- ✅ Stack is launching in the background. ---"
echo "You can view logs with: sudo docker-compose logs -f"
echo "To trigger the producer, run:"
echo "curl -X POST http://localhost:9000/producer/?count=100"