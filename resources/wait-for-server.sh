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
    # If first param isnt default
    if [ "$1" != "default" ]; then
        DATASOURCE_FILE="/resources/cli/install-datasource.$1.cli"
        DRIVER_FILE="/resources/cli/install-driver.$1.cli"
        # Call jboss cli with file of driver var
        sh /app/wildfly/bin/jboss-cli.sh --connect --file=$DRIVER_FILE
        echo "Database driver installed" 
        sh /app/wildfly/bin/jboss-cli.sh --connect --file=$DATASOURCE_FILE
        echo "Datasource installed" 
    fi
    exit 0
else
    echo "Server did not start within the specified time."
    exit 1
fi
