#!/bin/bash

RED="\e[31m"
GREEN="\e[92m"
BLUE="\e[36m"
BOLD="\e[1m"
ENDCOLOR="\e[0m"

if [ -z "$1" ]
then 
	echo -e "${RED}Package name not passed${ENDCOLOR}"
	exit 1
fi

echo -e "${BLUE}Creating Package: \n${BOLD}$1${ENDCOLOR}"

CURR_DIR=$(pwd)

mkdir -p $CURR_DIR/$1/packages
echo -e "${GREEN}\t- packages${ENDCOLOR}"

mkdir -p $CURR_DIR/$1/docs
echo -e "${GREEN}\t- docs${ENDCOLOR}"

mkdir -p $CURR_DIR/$1/dockerfiles
echo -e "${GREEN}\t- dockerfiles${ENDCOLOR}"

echo -e "${GREEN}Created directories${ENDCOLOR}"
