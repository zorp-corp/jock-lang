#!/usr/bin/env python3
import subprocess
import re

# Function to get the latest commit hash for the specified branch from a repo
def get_latest_commit(repo_url, branch="master"):
    print(repo_url)
    try:
        result = subprocess.run(
            ["git", "ls-remote", repo_url, branch],
            capture_output=True,
            text=True,
            check=True
        )
        print(result.stdout)
        return result.stdout.split()[0]
    except subprocess.CalledProcessError:
        print(f"Failed to retrieve the latest commit from {repo_url} on branch {branch}")
        return None

# Read the current Cargo.toml file
try:
    with open("Cargo.toml", "r") as file:
        cargo_toml = file.read()

    # Find all Git repo dependencies with their current revision hashes
    matches = re.findall(
        r'(\s*([^=\s]+)\s*=\s*{[^}]*git\s*=\s*"([^"]+)",\s*rev\s*=\s*")([a-f0-9]+)(")',
        cargo_toml
    )

    if not matches:
        print("No git dependencies with revisions found in Cargo.toml.")
    else:
        updated_toml = cargo_toml
        for match in matches:
            repo_name, _, repo_url, current_hash, trailing = match
            print(f"Checking latest commit for {repo_name} at {repo_url}...")

            # Retrieve the latest commit hash
            latest_commit_hash = get_latest_commit(repo_url, 'status' if repo_url[-9:] == 'sword.git' else 'master')
            if latest_commit_hash and latest_commit_hash != current_hash:
                print(f"Updating {repo_name}: {current_hash} -> {latest_commit_hash}")
                updated_toml = re.sub(
                    rf'{current_hash}',
                    rf'{latest_commit_hash}',
                    updated_toml
                )
            else:
                print(f"{repo_name} is already up to date.")

        # Write the updated content back to Cargo.toml if changes were made
        if updated_toml != cargo_toml:
            with open("Cargo.toml", "w") as file:
                file.write(updated_toml)
            print("Cargo.toml updated with the latest commit hashes.")
        else:
            print("No updates were necessary.")

except Exception as e:
    print(f"An error occurred: {e}")
