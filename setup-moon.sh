#!/bin/sh
set -e

# borrowed from https://github.com/rwv/docker-zerotier-moon
# usage ./start-moon.sh -4 1.2.3.4 -6 2001:abcd:abcd::1 -p 9993

export PATH=/bin:/usr/bin:/usr/local/bin:/sbin:/usr/sbin

moon_port=9993

while getopts "4:6:p:" arg; do
  case $arg in
  4)
    ipv4_address="$OPTARG"
    echo "IPv4 address: $ipv4_address"
    ;;
  6)
    ipv6_address="$OPTARG"
    echo "IPv6 address: $ipv6_address"
    ;;
  p)
    moon_port="$OPTARG"
    echo "Moon port: $moon_port"
    ;;
  ?)
    echo "unknown argument"
    exit 1
    ;;
  esac
done

stableEndpoints=()

if [ -z "${ipv4_address}" ]; then
  echo "Attempting to auto-detect public IPv4 address..."
  detected_ipv4=$(curl -s -4 ident.me)
  if [ -n "${detected_ipv4}" ]; then
    ipv4_address="${detected_ipv4}"
    echo "Detected public IPv4 address: ${ipv4_address}"
  else
    echo "Failed to auto-detect public IPv4 address."
  fi
fi

if [ -z "${ipv6_address}" ]; then
  echo "Attempting to auto-detect public IPv6 address..."
  detected_ipv6=$(curl -s -6 ident.me)
  if [ -n "${detected_ipv6}" ]; then
    ipv6_address="${detected_ipv6}"
    echo "Detected public IPv6 address: ${ipv6_address}"
  else
    echo "Failed to auto-detect public IPv6 address."
  fi
fi

if [ -n "${ipv4_address}" ]; then
  stableEndpoints+=("\"${ipv4_address}\/${moon_port}\"")
fi
if [ -n "${ipv6_address}" ]; then
  stableEndpoints+=("\"${ipv6_address}\/${moon_port}\"")
fi

if [ ${#stableEndpoints[@]} -eq 0 ]; then
  echo "Could not determine a public IPv4 or IPv6 address. Please provide one using -4 or -6."
  exit 1
fi

stableEndpointsForSed=$(IFS=,; echo "${stableEndpoints[*]}")

echo -e "stableEndpoints: ${stableEndpointsForSed}"

if [ -d "/var/lib/zerotier-one/moons.d" ]; then
  moon_id=$(cat /var/lib/zerotier-one/identity.public | cut -d ':' -f1)
  echo -e "Your ZeroTier moon id is \033[0;31m$moon_id\033[0m, you could orbit moon using \033[0;31m\"zerotier-cli orbit $moon_id $moon_id\"\033[0m"
  /usr/sbin/zerotier-one
else
  nohup /usr/sbin/zerotier-one >/dev/null 2>&1 &
  while [ ! -f /var/lib/zerotier-one/identity.secret ]; do
    sleep 1
  done
  /usr/sbin/zerotier-idtool initmoon /var/lib/zerotier-one/identity.public >>/var/lib/zerotier-one/moon.json
  sed -i 's/"stableEndpoints": \[\]/"stableEndpoints": ['$stableEndpointsForSed']/g' /var/lib/zerotier-one/moon.json
  /usr/sbin/zerotier-idtool genmoon /var/lib/zerotier-one/moon.json >/dev/null
  mkdir /var/lib/zerotier-one/moons.d
  mv *.moon /var/lib/zerotier-one/moons.d/
  pkill zerotier-one
  moon_id=$(cat /var/lib/zerotier-one/moon.json | grep \"id\" | cut -d '"' -f4)
  echo -e "Your ZeroTier moon id is \033[0;31m$moon_id\033[0m, you could orbit moon using \033[0;31m\"zerotier-cli orbit $moon_id $moon_id\"\033[0m"
  exec /usr/sbin/zerotier-one
fi