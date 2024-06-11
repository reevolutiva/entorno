import argparse
import json
import os
import shutil
import subprocess

def main():
    parser = argparse.ArgumentParser(description='Transfer files from source to destination.')
    parser.add_argument('destination_path', type=str, help='Destination path for the files')
    parser.add_argument('destination_user', type=str, help='Destination user for the files')
    parser.add_argument('destination_ip', type=str, help='Destination IP for the files')
    parser.add_argument('json_file', type=str, help='JSON file containing additional configuration')

    args = parser.parse_args()

    # Load additional configuration from JSON file
    with open(args.json_file, 'r') as f:
        config = json.load(f)
        
        for item in config:
            password = item['password']
            domain = item['domain']
            db = item['db']
            demyx_id = item['demyx_id']
            
            config_path = "/home/hosting/reevolutiva-net/" + domain + "/"
            wordpress_site_path = "/home/hosting/" + domain + "/"
            
            # Run the demyx-transfer.sh script
            #script_args = [ domain, 'root', password , db , args.destination_user, args.destination_ip , args.destination_path , demyx_id ]
            # transfer.sh CONFIG_PATH WORDPRESS_SITE_PATH MYSQL_DATABASE REMOTE_USER REMOTE_HOST REMOTE_PATH"
            trasfer_script = f"./trasnfer.sh {config_path} {wordpress_site_path} {db} {args.destination_user} {args.destination_ip} {args.destination_path}" 
            print( trasfer_script )
            #subprocess.run(['demyx-transfer.sh'] + script_args)

if __name__ == '__main__':
    main()
