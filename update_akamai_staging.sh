#!/bin/sh

if [ $# -eq 0 ]; then
    echo "No arguments supplied. Please specify host e.g. www.uat-thetimes.co.uk"
    exit
fi

if [ "$EUID" -ne 0 ]; then 
	echo "Please run as root"
	exit
fi

if [[ "$1" =~ "^www.*" ]]; then 
	echo "address should start with www."
	exit
fi

touch /temphosts

# make backup
cp /etc/hosts /etc/hosts.bk
echo "💾 Made backup to /etc/hosts.bk"

# remove existing entry
found=$( grep "$1" /etc/hosts | xargs )
if [ ! -z "$found" ]; then 
	echo "🗑  Removing entry $1 from hosts file"
	grep -vwE "($1)" /etc/hosts > /temphosts
else
	cp /etc/hosts /temphosts
fi

# lookup akamai staging ip and append to hosts file for specified host
echo "🌍 Getting server addess for $1.edgekey-staging.net"
echo "$(nslookup $1.edgekey-staging.net | awk '/Name:/{getline; print}' | grep -Eo "([0-9]*.[0-9]*.[0-9]*.[0-9]*)$") $1" >> /temphosts
cp /temphosts /etc/hosts

# print confirmation
echo "📝 $1 entry added to /etc/hosts"
echo "❤️  $1 now pointing to Akamai staging"

# remove temp file
rm /temphosts
