import argparse
import json
import os
import shutil
import paramiko

def main():
    parser = argparse.ArgumentParser(description='Transfer files from source to destination.')
    parser.add_argument('source_path', type=str, help='Source path of the files to transfer')
    parser.add_argument('destination_path', type=str, help='Destination path for the files')
    parser.add_argument('destination_user', type=str, help='Destination user for the files')
    parser.add_argument('destination_ip', type=str, help='Destination IP for the files')
    parser.add_argument('json_file', type=str, help='JSON file containing additional configuration')

    args = parser.parse_args()

    # Load additional configuration from JSON file
    with open(args.json_file, 'r') as f:
        config = json.load(f)
        
        for item in config:
            print(f'{item}')
        
 

if __name__ == '__main__':
    main()
