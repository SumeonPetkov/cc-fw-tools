#!/usr/bin/python3

import subprocess, os

SQUASHFS_ROOT = os.getenv("SQUASHFS_ROOT")
REPOSITORY_ROOT = os.getenv("REPOSITORY_ROOT")

def extract_commit() -> str:
    git_describe_output = subprocess.run(["git", "--git-dir", os.path.join(REPOSITORY_ROOT, ".git"), "describe", "--tags"], stdout=subprocess.PIPE, text=True, check=True).stdout.strip()
    split_output = git_describe_output.split("-")

    if (len(split_output) >= 3):
        version = f"{split_output[0]}-{split_output[2][1:]}"
    else:
        version = split_output[0]

    if version.startswith("v"):
        return version[1:]
    
    return version

try:
    version = extract_commit()
except:
    version = "Unknown"

version = version + "-oc\0"
encoded = version.encode(encoding="ASCII")
print(version)

with open(os.path.join(SQUASHFS_ROOT, "app", "app"), "r+b") as fp:
    fp.seek(0x34F6E8, os.SEEK_SET)
    fp.write(encoded)
