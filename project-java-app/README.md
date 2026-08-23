# Project Java App — GitHub Repository Setup

## Overview

As part of my DevOps learning journey, I successfully configured Git and GitHub for my Java application and pushed the project to a GitHub repository using SSH authentication.

## Challenge

Initially, I attempted to push the project using HTTPS:

```bash
git push -u origin main

GitHub rejected the authentication attempt with:

remote: Invalid username or token.
Password authentication is not supported for Git operations.
fatal: Authentication failed

I also encountered:

remote: Permission to agboolaojubril/project-java-app.git denied
fatal: unable to access ... 403

Solution: I configured SSH authentication between my WSL environment and GitHub.

ssh-keygen -t ed25519 -C "GitHub SSH Key"

The key pair was created at:

~/.ssh/id_ed25519
~/.ssh/id_ed25519.pub

Added the public key to GitHub

I copied the public key using: cat ~/.ssh/id_ed25519.pub

and added it to my GitHub account under: Settings → SSH and GPG keys → New SSH key

Tested SSH authentication: ssh -T git@github.com

GitHub successfully authenticated my account:
"Hi agboolaojubril! You've successfully authenticated,
but GitHub does not provide shell access."

Changed the Git remote from HTTPS to SSH:
git remote set-url origin git@github.com:agboolaojubril/project-java-app.git

I verified the remote with: git remote -v

I pushed the project using: git push -u origin main

The push completed successfully:
Enumerating objects: 64, done.
Counting objects: 100% (64/64), done.
Writing objects: 100% (64/64), 45.16 KiB, done.

To github.com:agboolaojubril/project-java-app.git
 * [new branch] main -> main

branch 'main' set up to track 'origin/main'.


Result

The Java application was successfully pushed to GitHub and the local main branch is now tracking the remote origin/main branch.

What I Learned
GitHub no longer supports password authentication for Git operations over HTTPS.
SSH keys provide secure authentication between my development environment and GitHub.
The private SSH key must never be shared.
The public SSH key can be added to GitHub.
Git remotes can be configured to use HTTPS or SSH.
git push -u origin main creates the upstream relationship between the local and remote branches.
Understanding Git authentication is an important part of a DevOps workflow.
Next Steps

I will continue developing this project by implementing additional DevOps practices, including:

Containerization with Docker
Infrastructure as Code
Configuration management
CI/CD automation
Cloud deployment
Monitoring and logging
Automated testing

Repository
https://github.com/agboolaojubril/project-java-app
