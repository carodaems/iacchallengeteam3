#!/bin/bash

# Function to fetch ALB DNS name
get_alb_dns_name() {
    lb_name="ecs-alb"
    region="us-east-1"

    alb_dns_name=$(aws elbv2 describe-load-balancers --region $region --names $lb_name --query 'LoadBalancers[0].DNSName' --output text)
    echo $alb_dns_name
}

# Function to test application availability
test_application() {
    alb_dns_name=$1
    app_url="http://$alb_dns_name"

    response=$(curl -s -o /dev/null -w "%{http_code}" $app_url)

    if [[ $response -eq 200 ]]; then
        echo "Success! Application at $app_url is reachable. HTTP Status Code: $response"
        return 0  # Success
    else
        echo "Application at $app_url returned an unexpected status code: $response"
        return 1  # Failure
    fi
}

# Main script
alb_dns_name=$(get_alb_dns_name)

if [[ -n $alb_dns_name ]]; then
    test_application $alb_dns_name
else
    echo "Failed to retrieve ALB DNS name."
fi
