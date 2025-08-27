#!/bin/bash
set -euo pipefail

# Usage:
#   sudo ./setup-network.sh <iface> <ip[/cidr]> <gateway> [dns1,dns2,...]
# Example:
#   sudo ./setup-network.sh ens18 10.20.0.95 10.20.0.1 8.8.8.8,8.8.4.4

DEFAULT_CIDR="24"

need() { command -v "$1" >/dev/null 2>&1 || { echo "Missing dependency: $1"; exit 1; }; }

if [ "${EUID}" -ne 0 ]; then
  echo "Please run as root"; exit 1
fi

if [ "$#" -lt 3 ] || [ "$#" -gt 4 ]; then
  echo "Usage: $0 <iface> <ip[/cidr]> <gateway> [dns1,dns2,...]"
  exit 1
fi

need nmcli
# Optional but nice to warn if NM isn't running
if ! systemctl is-active --quiet NetworkManager; then
  echo "Warning: NetworkManager is not active; attempting to proceed..."
fi

IFACE="$1"
IP_INPUT="$2"      # e.g., 10.20.0.95 or 10.20.0.95/24
GATEWAY="$3"
DNS_CSV="${4:-}"   # comma-separated

# Normalize IP/CIDR (add /24 if user gave bare IP)
if [[ "$IP_INPUT" == */* ]]; then
  IPCIDR="$IP_INPUT"
else
  IPCIDR="$IP_INPUT/$DEFAULT_CIDR"
fi

# NetworkManager keyfiles expect semicolon-separated DNS
DNS_SEMI="$( [ -n "$DNS_CSV" ] && echo "$DNS_CSV" | sed 's/,/;/g' || true )"

ID="static-${IFACE}"
KEYFILE="/etc/NetworkManager/system-connections/${ID}.nmconnection"

echo "Configuring ${IFACE} with ${IPCIDR} (GW ${GATEWAY}) via keyfile '${KEYFILE}'..."

# 1) Remove any existing profiles bound to this device (safer than delete-by-name)
while IFS= read -r NAME; do
  [ -n "$NAME" ] || continue
  echo "Deleting existing connection profile: ${NAME}"
  nmcli connection delete "${NAME}" || true
done < <(nmcli -t -f NAME,DEVICE connection show | awk -F: -v d="${IFACE}" '$2==d {print $1}')

# 2) Write keyfile
install -d -m 0700 /etc/NetworkManager/system-connections

{
  echo "[connection]"
  echo "id=${ID}"
  echo "type=ethernet"
  echo "interface-name=${IFACE}"
  echo "autoconnect=true"
  echo
  echo "[ipv4]"
  echo "address1=${IPCIDR},${GATEWAY}"
  if [ -n "${DNS_SEMI}" ]; then
    echo "dns=${DNS_SEMI}"
    echo "ignore-auto-dns=true"
  fi
  echo "method=manual"
  echo
  echo "[ipv6]"
  echo "method=ignore"
} > "${KEYFILE}"

chmod 600 "${KEYFILE}"
chown root:root "${KEYFILE}"

# 3) Reload and activate
nmcli connection reload
nmcli -w 15 connection up id "${ID}"

# 4) Show status
echo
nmcli connection show "${ID}"
echo
ip -4 addr show dev "${IFACE}" || true
