import boto3
import requests

##########################################
######### Check App Availability #########
##########################################

def get_alb_dns_name():
    session = boto3.Session(region_name='us-east-1')
    lb_name = 'ecs-alb'
    
    client = session.client('elbv2')
    response = client.describe_load_balancers(Names=[lb_name])
    
    if 'LoadBalancers' in response:
        alb_dns_name = response['LoadBalancers'][0]['DNSName']
        return alb_dns_name
    else:
        print("ALB not found or no load balancers returned.")
        return None

def test_application(alb_dns_name):
    app_url = f"http://{alb_dns_name}"

    try:
        response = requests.get(app_url)
        if response.status_code == 200:
            print(f"Success! Application at {app_url} is reachable. HTTP Status Code: {response.status_code}")
            return True
        else:
            print(f"Application at {app_url} returned an unexpected status code: {response.status_code}")
            return False
    except requests.RequestException as e:
        print(f"Failed to connect to the application at {app_url}. Error: {e}")
        return False

if __name__ == "__main__":
    alb_dns_name = get_alb_dns_name()

    if alb_dns_name:
        test_application(alb_dns_name)
    else:
        print("Failed to retrieve ALB DNS name.")

