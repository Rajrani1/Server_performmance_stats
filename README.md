# Server_performmance_stats
Server_performmance_stats

# server-stats.sh

A portable Bash script to display basic server performance statistics.  
Tested on **RHEL/CentOS/Rocky/AlmaLinux** and **Debian/Ubuntu** systems.

---

## 🔧 Features

- **CPU Usage** (calculated from `/proc/stat`)
- **Memory Usage** (used vs total, MB & %)
- **Disk Usage** (used vs total, %)
- **Top 5 processes by CPU**
- **Top 5 processes by Memory**
- **Logged-in users**
- **Failed login attempts** (last 10, requires root)

Optional extended info:
- OS / Distro details
- System uptime
- Load averages

---

## 🚀 Usage

### 1. Clone / Copy the Script
```bash
curl -O https://github.com/Rajrani1/Server_performmance_stats   # or copy from repo
