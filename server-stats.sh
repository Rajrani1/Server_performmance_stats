#!/usr/bin/env bash
# server-stats.sh
# Works on RHEL, CentOS, Rocky, AlmaLinux, Ubuntu, Debian

set -u

echo "================= Server Stats ================="
echo "Date: $(date '+%F %T')    Host: $(hostname)"

# ---------------- OS Info ----------------
if [ -f /etc/os-release ]; then
  . /etc/os-release
  echo "OS: $NAME $VERSION"
else
  echo "OS: $(uname -srm)"
fi

# ---------------- Uptime & Load ----------------
if uptime -p >/dev/null 2>&1; then
  echo "Uptime: $(uptime -p)"
else
  uptime
fi
read -r load1 load5 load15 _ < /proc/loadavg
echo "Load average: 1m:${load1} 5m:${load5} 15m:${load15}"

# ---------------- CPU Usage ----------------
get_cpu_usage() {
  read -r _ user nice system idle iowait irq softirq steal guest < /proc/stat
  prev_idle=$((idle + iowait))
  prev_non_idle=$((user + nice + system + irq + softirq + steal))
  prev_total=$((prev_idle + prev_non_idle))
  sleep 1
  read -r _ user nice system idle iowait irq softirq steal guest < /proc/stat
  idle2=$((idle + iowait))
  non_idle2=$((user + nice + system + irq + softirq + steal))
  total2=$((idle2 + non_idle2))
  totald=$((total2 - prev_total))
  idled=$((idle2 - prev_idle))
  awk -v t=$totald -v i=$idled 'BEGIN{printf "%.1f", (t - i)/t*100}'
}
cpu_usage=$(get_cpu_usage)
echo "CPU Usage: ${cpu_usage}%"

# ---------------- Memory ----------------
if command -v free >/dev/null 2>&1; then
  total=$(free -m | awk 'NR==2{print $2}')
  used=$(free -m | awk 'NR==2{print $3}')
  perc=$(awk -v u=$used -v t=$total 'BEGIN{printf "%.1f", u/t*100}')
  echo "Memory: Used ${used}MB / ${total}MB (${perc}%)"
  echo "Memory (human-readable):"
  free -h | head -n 2
else
  echo "free command not available"
fi

# ---------------- Disk ----------------
if df -h --total >/dev/null 2>&1; then
  df -h --total | awk 'END{printf "Disk: Used %s / %s (%s)\\n",$3,$2,$5}'
else
  df -h | awk 'NR==1 || /^\\// {print}'
fi

# ---------------- Top Processes ----------------
echo
echo "Top 5 processes by CPU:"
ps -eo pid,user,%cpu,%mem,cmd --sort=-%cpu | head -n 6

echo
echo "Top 5 processes by Memory:"
ps -eo pid,user,%mem,%cpu,cmd --sort=-%mem | head -n 6

# ---------------- Logged-in Users ----------------
echo
echo "Logged-in users:"
who

# ---------------- Failed Logins ----------------
logfile=""
if [ -f /var/log/auth.log ]; then
  logfile="/var/log/auth.log"   # Debian/Ubuntu
elif [ -f /var/log/secure ]; then
  logfile="/var/log/secure"     # RHEL/CentOS
fi

if [ -n "$logfile" ]; then
  if [ "$(id -u)" -eq 0 ]; then
    echo
    echo "Last 10 failed login attempts:"
    grep -i "failed password" "$logfile" | tail -n 10
  else
    echo
    echo "Run with sudo to see failed login attempts ($logfile)"
  fi
fi

echo
echo "================= End of Report ================="
