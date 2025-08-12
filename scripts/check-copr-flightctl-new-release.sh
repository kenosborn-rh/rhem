#!/bin/bash

PACKAGE="flightctl-services"

# Get installed version
INSTALLED=$(rpm -q --qf "%{VERSION}-%{RELEASE}\n" $PACKAGE 2>/dev/null || echo "Not Installed")

# Query all repos (including COPR) for the latest version
LATEST=$(dnf info $PACKAGE 2>/dev/null \
         | awk '/Version     :/ {v=$3} /Release     :/ {r=$3} END {if (v != "") print v"-"r; else print "Not Found"}')

echo "Installed Version: $INSTALLED"
echo "Latest Version:    $LATEST"

if [[ "$LATEST" == "Not Found" ]]; then
    echo "⚠️ Package $PACKAGE not found in any enabled repo."
elif [ "$INSTALLED" != "$LATEST" ]; then
    echo "🚨 A new version is available!"
else
    echo "✅ You are running the latest version."
fi

