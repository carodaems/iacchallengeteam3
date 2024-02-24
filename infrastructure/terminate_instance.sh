#!/bin/bash

export AWS_DEFAULT_REGION="us-east-1"

# Set default instance name
instance_name="SqlExecutionInstance"


json_output=$(aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId, Tags[?Key==`Name`].Value|[0], State.Name]' --output json)

# Extract and display relevant information using jq
instance_info=($(echo "${json_output}" | jq -r '.[][][]'))

# Initialize an array to store instances
selected_instances=()

# Iterate over the array
for ((i=0; i<${#instance_info[@]}; i+=3)); do
  instance_id=${instance_info[i]}
  instance_tag=${instance_info[i+1]}
  instance_state=${instance_info[i+2]}

  # Check if it's "running" and the name matches
  if [ "$instance_state" == "running" ] || [ "$instance_state" == "pending" ] && [ "$instance_tag" == "$instance_name" ]; then
    selected_instances+=("$instance_id")
  fi
done

# Print the selected instances
if [ ${#selected_instances[@]} -eq 0 ]; then
  echo "No running instances found with the specified name: $instance_name"
else
  for instance_id in "${selected_instances[@]}"; do
    echo "Wait for the status checks to be '2/2 checks passed'"
    

    while true; do
        # Run the AWS CLI command and store the JSON output in a variable
        json_output=$(aws ec2 describe-instance-status --instance-ids "$instance_id" --output json)

        # Extract the "Status" values for "InstanceStatus" and "SystemStatus"
        instance_status=$(echo "$json_output" | jq -r '.InstanceStatuses[0].InstanceStatus.Details[] | select(.Name == "reachability").Status')
        system_status=$(echo "$json_output" | jq -r '.InstanceStatuses[0].SystemStatus.Details[] | select(.Name == "reachability").Status')

        # Print the extracted values
        echo "Instance Status: $instance_status"
        echo "System Status: $system_status"

        # Check if both statuses are "passed"
        if [ "$instance_status" == "passed" ] && [ "$system_status" == "passed" ]; then
            echo "Terminating instance: $instance_id"
            aws ec2 terminate-instances --instance-ids "$instance_id"
            break
        fi

        # Sleep for a while before checking again
        sleep 10
    done

  done
fi
