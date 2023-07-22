#!/bin/bash

# This script verifies that the artifacts are present in the target directory
# and moves them to the WildFly directory.
deployments_dir=/deployments
wildfly_deployment_dir=/app/wildfly/standalone/deployments

check_wars() {
    # Verifies if has some war at deployments directory
    if [ -f "$deployments_dir/*.war" ]; then
        # Get list of wars.
        wars=$(ls $deployments_dir/*.war)
        # For each war, check if is the same of present in WildFly deployment directory
        for war in $wars; do
            # Get war name
            war_name=$(basename $war)
            # Verifies if the artifacts are different from the ones in the WildFly directory.
            if ! cmp -s "$deployments_dir/$war_name" "$wildfly_deployment_dir/$war_name"; then
                # Moves the artifacts to the WildFly directory.
                cp "$deployments_dir/$war_name" "$wildfly_deployment_dir/$war_name"
                echo "$war_name moved to WildFly directory."
            fi
        done
    fi
}

# infinite loop
sleep 50s
until false; do
    check_wars
    sleep 10s
done

