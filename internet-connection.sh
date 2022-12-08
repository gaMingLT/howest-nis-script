#!/bin/bash


# Usage:
#   ./internet-connection.sh <client-type> <adapter> <ip-connected-interface> <url-website>
# Client:
#    ./internet-connection.sh client eth0 10.0.0.1 https://10.0.0.1:80
#    ./internet-connection.sh client eth0 10.0.0.1 https://10.0.0.1:443
# DMZ Webserver
#    ./internet-connection.sh dmz eth0 10.10.10.2 https://localhost:80
#    ./internet-connection.sh dmz eth0 10.10.10.2 https://localhost:443
# Wan Client
#    ./internet-connection.sh wan eth0 <ip-connected-interface> https://<ip-connected-interface>:80
#    ./internet-connection.sh wan eth0 <ip-connected-interface> https://<ip-connected-interface>:443


## Colors

GREEN='\033[0;32m'
RED='\033[0;31m'
WHITE='\033[0;37m'
RESET='\033[0m'
YELLOW="\033[33m"
BLUE="\033[34m"
PINK="\033[35m"
CYAN="\033[36m"


# Collect arguments

type=$1
network_adapter=$2
ip_connected_interface=$3
url_website=$4


# Functions

## ping ip
ping_ip () {
  # echo "Starting ping command to" $1
  res=$(ping -c 4 $1)

  if [ $? -ne 0 ]; then
    echo -e "${RED}The ip" $1 "is down" ${RESET}
  else
    echo -e "${GREEN}The ip" $1 "is up" ${RESET}
  fi

}


## check device ip-addres
device_ip_address () {
  res=$(ip -4 addr show $1 | grep -oP "(?<=inet ).*(?=/)")
  res2=$(ip addr show ens33 | awk '/inet/ { print $7 }')
  res3=$(ip addr show ens33 | awk '/state/ { print $9 }')

  echo -e "${YELLOW}Current" $1 "adapter has ip" $res "type is:" $res2 "and state:" $res3 ${RESET}
}


## check default gateway
default_gateway () {
  # if required: ip route show default | awk '// { print $3 }'
  res=$(ip route show default)
  echo -e "${YELLOW} $res ${RESET}"
}


## Get website
get_website() {
  res=$(wget -q $1)

  if [ $? -eq 0 ]; then
    echo -e "${GREEN}Connection to website succesfull!" ${RESET}
  else
    echo -e "${RED}Connection unsucesfull" ${REST}
  fi
}


# Run throught test

echo -e "${BLUE}Running test for client type:" $type ${RESET}

## localhost-ip
echo -e "======== Testing TCP/IP Stack ================"
ping_ip "127.0.0.1"
echo -e "\n"

## check device ip-address
echo "========= Checking Device IP-Addres =============="
device_ip_address "$network_adapter"
echo -e "\n"

## check default gateway
echo "========= Checking Default Gateway ==============="
default_gateway
echo -e "\n"

## Ping router interfaces
echo "========= Ping Router Interface ================="
ping_ip "$ip_connected_interface"
echo -e "\n"


## Get Website
if [ -z "$url_website" ]; then
  echo "================ Testing Website ================"
  echo -e "${YELLOW}No website url specified, skipping website test\n" ${RESET}
else
  echo "================ Testing Website ================"
  get_website "$url_website"
  echo -e "\n"
fi

echo -e "${GREEN}Script is finished!"