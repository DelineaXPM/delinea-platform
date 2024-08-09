# DISCLAIMER: This script is provided as-is without any warranties.
# Please thoroughly review the code and test it in a controlled
# environment before deploying it in a production setting.
# Use it at your own risk.

# Description: PowerShell script to install and register the Delinea Connector
import requests
import time
import json
import argparse
from colorama import init, Fore, Style
from config import TOKEN_URL, CLIENT_ID, CLIENT_SECRET, SCOPE, GRANT_TYPE, REFRESH_GRANT_TYPE, TEST_API_URL

# Initialize colorama
init()

ACCESS_TOKEN = None
REFRESH_TOKEN = None
TOKEN_EXPIRES_AT = 0

def print_heading(heading):
    print(f"\n{Style.BRIGHT}{Fore.CYAN}{heading}{Style.RESET_ALL}")

def get_initial_tokens():
    global ACCESS_TOKEN, REFRESH_TOKEN, TOKEN_EXPIRES_AT

    payload = {
        'grant_type': GRANT_TYPE,
        'client_id': CLIENT_ID,
        'client_secret': CLIENT_SECRET,
        'scope': SCOPE
    }

    response = requests.post(TOKEN_URL, data=payload)
    response_data = response.json()

    if response.status_code == 200:
        ACCESS_TOKEN = response_data['access_token']
        REFRESH_TOKEN = response_data.get('refresh_token')  # Optional, depending on the provider
        expires_in = response_data['expires_in']
        TOKEN_EXPIRES_AT = time.time() + expires_in - 60  # Refresh a minute before expiration
        print_heading("Initial Access Token Obtained")
        print(f"{Fore.GREEN}Access Token: {ACCESS_TOKEN}{Style.RESET_ALL}")
        if REFRESH_TOKEN:
            print(f"{Fore.GREEN}Refresh Token: {REFRESH_TOKEN}{Style.RESET_ALL}")
    else:
        print_heading("Failed to Obtain Initial Tokens")
        print(f"{Fore.RED}{json.dumps(response_data, indent=4)}{Style.RESET_ALL}")


def get_new_access_token():
    global ACCESS_TOKEN, TOKEN_EXPIRES_AT, REFRESH_TOKEN
    headers = {
        'Authorization': f'Bearer {ACCESS_TOKEN}'
    }
    payload = {
        'grant_type': REFRESH_GRANT_TYPE,
        'refresh_token': REFRESH_TOKEN

    }

    response = requests.post(TOKEN_URL, data=payload, headers=headers)
    response_data = response.json()

    if response.status_code == 200:
        ACCESS_TOKEN = response_data['access_token']
        expires_in = response_data['expires_in']
        TOKEN_EXPIRES_AT = time.time() + expires_in - 60  # Refresh a minute before expiration
        print_heading("New Access Token Obtained")
        print(f"{Fore.GREEN}Access Token: {ACCESS_TOKEN}{Style.RESET_ALL}")
        if 'refresh_token' in response_data:
            REFRESH_TOKEN = response_data['refresh_token']
            print(f"{Fore.GREEN}Refresh Token: {REFRESH_TOKEN}{Style.RESET_ALL}")
        # Call the test API after refreshing the token
        call_test_api()
    else:
        print_heading("Failed to Refresh Token")
        print(f"{Fore.RED}{json.dumps(response_data, indent=4)}{Style.RESET_ALL}")

def ensure_valid_token(mimic_expired):
    if mimic_expired or time.time() > TOKEN_EXPIRES_AT:
        print_heading("Access Token Expired")
        print("Refreshing...")
        get_new_access_token()
    else:
        print_heading("Access Token is Still Valid")
        # Call the test API if the token is still valid
        call_test_api()

def call_test_api():
    headers = {
        'Authorization': f'Bearer {ACCESS_TOKEN}'
    }

    response = requests.get(TEST_API_URL, headers=headers)
    
    if response.status_code == 200:
        print_heading("Test API Call Successful")
        print(f"{Fore.GREEN}{json.dumps(response.json(), indent=4)}{Style.RESET_ALL}")
    else:
        print_heading("Test API Call Failed")
        print(f"{Fore.RED}Status Code: {response.status_code}\n{json.dumps(response.json(), indent=4)}{Style.RESET_ALL}")

def main():
    parser = argparse.ArgumentParser(description='Token management script with optional expired token mimic.')
    parser.add_argument('--mimic-expired', action='store_true', help='Mimic an expired token')
    args = parser.parse_args()

    print_heading("Starting Token Acquisition")
    get_initial_tokens()
    ensure_valid_token(args.mimic_expired)

if __name__ == "__main__":
    main()
