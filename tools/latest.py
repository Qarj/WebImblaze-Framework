#!/usr/bin/env python3
version="0.1.0"

import sys, argparse, math, os

def latest(folders):
    latest_folder = ''
    latest_major = 0
    latest_minor = 0
    latest_patch = 0
    latest_version = 0
    
    for folder in folders:
        semantic = folder.split(".")
        if len(semantic) < 3:
            continue

        semantic[2] = semantic[2].split("-")[0]

        major = int(semantic[0])
        minor = int(semantic[1])
        patch = int(semantic[2])

        version = folder.split("-")[-1]
        if version[:1] == 'v':
            version = int(version[1:])
        else:
            version = 0

        if major < latest_major:
            continue
            
        if major == latest_major and minor < latest_minor:
            continue

        if minor == latest_minor and patch < latest_patch:
            continue

        if patch == latest_patch and version < latest_version:
            continue

        latest_folder = folder
        latest_major = major
        latest_minor = minor
        latest_patch = patch
        latest_version = version

    return latest_folder

parser = argparse.ArgumentParser(description='Determine the latest release folder - for folders with names like 3.0.624-zero-release-tests-v1')
parser.add_argument('--path', dest='path', required=False, action='store', help='Target path')
parser.add_argument('--version', action='version', version=version)

args = parser.parse_args()

if (args.path):
    all_immediate_subfolders = next(os.walk(args.path))[1]
    print (latest(all_immediate_subfolders))
