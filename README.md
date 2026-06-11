# 🚀 Multi-Language Runner (Python + Java on EC2)

Automated CI/CD pipeline that executes Python and Java programs on an EC2 instance, triggered by GitHub Actions on every push.

---

## 📁 Repository Structure

```
multi-lang-runner/
├── .github/
│   └── workflows/
│       └── ci-cd.yml          # GitHub Actions workflow
├── python/
│   └── stats.py               # Python program (max/min/avg)
├── java/
│   └── Stats.java             # Java program (max/min/avg)
├── scripts/
│   ├── run_all.sh             # Runs both programs + saves logs
│   └── ec2_setup.sh           # One-time EC2 bootstrap script
└── README.md
```

---

## 🖥️ EC2 Setup (One-Time Steps)

### 1. Launch an EC2 Instance
- **AMI**: Ubuntu 22.04 LTS (recommended) or Amazon Linux 2023
- **Instance type**: t2.micro (free tier) or larger
- **Security Group**: allow inbound SSH (port 22) from GitHub Actions IP ranges
  - Or use `0.0.0.0/0` temporarily (restrict to GitHub IPs in production)

### 2. SSH Into the Instance

```bash
ssh -i your-key.pem ubuntu@<EC2_PUBLIC_IP>
```

### 3. Run the Bootstrap Script

```bash
curl -O https://raw.githubusercontent.com/<YOUR_USER>/multi-lang-runner/main/scripts/ec2_setup.sh
chmod +x ec2_setup.sh
./ec2_setup.sh
```

This installs: `git`, `python3`, `default-jdk`, and support tools.

### 4. Generate an SSH Key Pair for GitHub Actions

Run this **on your local machine** (or in AWS CloudShell):

```bash
ssh-keygen -t ed25519 -C "github-actions-runner" -f github_actions_key
# Two files are created:
#   github_actions_key      ← private key (goes into GitHub secret)
#   github_actions_key.pub  ← public key  (goes onto EC2)
```

### 5. Add the Public Key to EC2

```bash
# On the EC2 instance:
cat github_actions_key.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

### 6. Add GitHub Repository Secrets

In your GitHub repo → **Settings → Secrets and variables → Actions → New repository secret**:

| Secret Name    | Value                                        |
|----------------|----------------------------------------------|
| `EC2_HOST`     | EC2 public IP or hostname (e.g. `3.x.x.x`)  |
| `EC2_USER`     | SSH username (e.g. `ubuntu` or `ec2-user`)   |
| `EC2_SSH_KEY`  | Contents of the `github_actions_key` file    |

---

## ▶️ Running Locally

```bash
# Python
python3 python/stats.py

# Java (compile then run)
javac java/Stats.java -d /tmp/stats_out
java  -cp /tmp/stats_out Stats

# Both programs via the shell script
chmod +x scripts/run_all.sh
./scripts/run_all.sh
```

---

## 📋 Commands Used to Execute Programs

### Python
```bash
python3 python/stats.py
```

### Java
```bash
javac java/Stats.java -d /tmp/out
java  -cp /tmp/out Stats
```

### Run all + save logs
```bash
./scripts/run_all.sh
# Logs saved to: logs/run_YYYYMMDD_HHMMSS.log
```

---

## 📄 Sample Output Logs

### Python Output
```
========================================
        PYTHON STATS PROGRAM
========================================
Numbers  : [42, 17, 85, 3, 96, 54, 28, 71, 9, 63]
Highest  : 96
Lowest   : 3
Average  : 46.80
========================================
```

### Java Output
```
========================================
         JAVA STATS PROGRAM
========================================
Numbers  : [42, 17, 85, 3, 96, 54, 28, 71, 9, 63]
Highest  : 96
Lowest   : 3
Average  : 46.80
========================================
```

### Full run_all.sh Log (logs/run_20240611_142035.log)
```
[2024-06-11 14:20:35] ============================================
[2024-06-11 14:20:35]    MULTI-LANGUAGE CI/CD RUNNER
[2024-06-11 14:20:35] ============================================
[2024-06-11 14:20:35] Repo root : /home/ubuntu/multi-lang-runner
[2024-06-11 14:20:35] Log file  : /home/ubuntu/multi-lang-runner/logs/run_20240611_142035.log
[2024-06-11 14:20:35]
[2024-06-11 14:20:35] >>> Running Python program...
========================================
        PYTHON STATS PROGRAM
========================================
Numbers  : [42, 17, 85, 3, 96, 54, 28, 71, 9, 63]
Highest  : 96
Lowest   : 3
Average  : 46.80
========================================
[2024-06-11 14:20:36] Python program completed successfully.
[2024-06-11 14:20:36]
[2024-06-11 14:20:36] >>> Compiling and running Java program...
========================================
         JAVA STATS PROGRAM
========================================
Numbers  : [42, 17, 85, 3, 96, 54, 28, 71, 9, 63]
Highest  : 96
Lowest   : 3
Average  : 46.80
========================================
[2024-06-11 14:20:37] Java program completed successfully.
[2024-06-11 14:20:37]
[2024-06-11 14:20:37] ============================================
[2024-06-11 14:20:37]    ALL PROGRAMS COMPLETED SUCCESSFULLY
[2024-06-11 14:20:37] ============================================
[2024-06-11 14:20:37] Full log saved to: /home/ubuntu/multi-lang-runner/logs/run_20240611_142035.log
```

---

## ⚙️ How the Workflow Triggers

1. Developer pushes code to `main`
2. GitHub Actions starts `ci-cd.yml`
3. Workflow SSHes into EC2 using stored secrets
4. EC2 pulls the latest code via `git pull`
5. Runtimes are verified (installed if missing)
6. `run_all.sh` executes both programs
7. Logs are printed to the GitHub Actions console

---

## 📂 Viewing Logs on EC2

```bash
# List all run logs
ls -lt ~/multi-lang-runner/logs/

# View the latest log
cat $(ls -t ~/multi-lang-runner/logs/ | head -1 | xargs -I{} echo ~/multi-lang-runner/logs/{})

# Tail logs live during a run
tail -f ~/multi-lang-runner/logs/run_*.log
```
