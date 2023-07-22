#!/bin/bash

# Set the maximum number of retries and the delay between retries
MAX_RETRIES=20
RETRY_DELAY=10 # seconds

# Function to check if the server is up
is_server_up() {
    curl --output /dev/null --silent --head --fail http://0.0.0.0:8080
}

# Wait for the server to start
retries=0
until is_server_up || [ $retries -eq $MAX_RETRIES ]; do
    retries=$((retries + 1))
    echo "Waiting for server to start..."
    sleep $RETRY_DELAY
done

if is_server_up; then
    echo "Server is up!"
    sh /app/wildfly/bin/jboss-cli.sh --connect --file=/resources/install-driver.cli 
    echo "Database driver installed" 
    sh /app/wildfly/bin/jboss-cli.sh --connect --file=/resources/install-datasource.cli 
    echo "Datasource installed" 
    exit 0
else
    echo "Server did not start within the specified time."
    exit 1
fi
