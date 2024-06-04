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

    # Create destination directory if it doesn't exist
    if not os.path.exists(args.destination_path):
        os.makedirs(args.destination_path)

    # Copy files from source to destination
    shutil.copytree(args.source_path, args.destination_path)

    # Transfer files to remote server
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(args.destination_ip, username=args.destination_user)

    sftp = ssh.open_sftp()
    sftp.put(args.destination_path, args.destination_path)
    sftp.close()

    ssh.close()

if __name__ == '__main__':
    main()
