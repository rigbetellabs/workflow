#!/bin/bash

RED="\e[31m"
GREEN="\e[92m"
BLUE="\e[36m"
BOLD="\e[1m"
YELLOW="\e[33m"
ENDCOLOR="\e[0m"

GITIGNORE_URL=https://raw.githubusercontent.com/rigbetellabs/workflow/master/.gitignore
PRECOMMIT_CONFIG_URL=https://raw.githubusercontent.com/rigbetellabs/workflow/master/.pre-commit-config.yaml

YES_FLAG=false

# Function to display script usage
usage() {
 echo "Usage: $0 --name annex [OPTIONS]"
 echo "Options:"
 echo " -h, --help      Display this help message"
 echo " -y, --yes       Enable -y flag to all commands"
 echo " -n, --name      STRING Repository name to create"
}

has_argument() {
    [[ ("$1" == *=* && -n ${1#*=}) || ( ! -z "$2" && "$2" != -*)  ]];
}

extract_argument() {
  echo "${2:-${1#*=}}"
}

# Function to handle options and arguments
handle_options() {
  if [ $# -eq 0 ]
   then
	echo -e "${RED}ERROR: No arg passed, name required${ENDCOLOR}"
	usage
	exit 1
  fi
  while [ $# -gt 0 ]; do
    case $1 in
      -h | --help)
        usage
        exit 0
        ;;
      -Y | --yes)
        YES_FLAG=true
        ;;
      -n | --name*)
        if ! has_argument $@; then
          echo -e "${RED}ERROR: Repository name not passed${ENDCOLOR}" >&2
          usage
          exit 1
        fi

        REPOSITORY_NAME=$(extract_argument $@)

        shift
        ;;
      *)
        echo "Invalid option: $1" >&2
        usage
        exit 1
        ;;
    esac
    shift
  done
}

# Main script execution
handle_options "$@"



CURR_DIR=$(pwd)
WORKING_DIR=${CURR_DIR}/$REPOSITORY_NAME

if test -d $WORKING_DIR; then
	echo -e "${RED}REPOSITORY Already Exists! Please remove and run again${ENDCOLOR}"
	exit 1
fi

echo -e "${BLUE}Creating REPOSITORY: "
echo -e "${BOLD}$REPOSITORY_NAME/${ENDCOLOR}"

mkdir -p $WORKING_DIR/packages
echo -e "${GREEN}\t- packages${ENDCOLOR}"

mkdir -p $WORKING_DIR/docs
echo -e "${GREEN}\t- docs${ENDCOLOR}"

mkdir -p $WORKING_DIR/dockerfiles
echo -e "${GREEN}\t- dockerfiles${ENDCOLOR}"

echo -e "${GREEN}Created directories${ENDCOLOR}\n"

cd $WORKING_DIR

# add .gitignore 
if [ $YES_FLAG != true ]; then
	while true; do
		echo -e "Do you want to add ${BOLD}${BLUE}.gitignore${ENDCOLOR}? [Y/n]"
	    read -p '' yn
	    case $yn in
	        [Yy]* ) wget $GITIGNORE_URL; break;;
			"" )    wget $GITIGNORE_URL; break;;
	        [Nn]* ) echo -e "${GREEN}skipped${ENDCOLOR}"; break;;
	        * )     echo "Please answer yes or no.";;
	    esac
	done
else
	echo -e "${BOLD}${BLUE}Adding... .gitignore${ENDCOLOR}"
	wget $GITIGNORE_URL
fi

# git init
if [ $YES_FLAG != true ]; then
	while true; do
	    echo -e "Do you want to perform ${BOLD}${BLUE}git init${ENDCOLOR}? [Y/n]"
	    read -p '' yn
	    case $yn in
	        [Yy]* ) git init; break;;
			"" )    git init; break;;
	        [Nn]* ) echo -e "${GREEN}skipped${ENDCOLOR}"; break;;
	        * )     echo "Please answer yes or no.";;
	    esac
	done
else
	echo -e "${BOLD}${BLUE}Performing \"git init\"${ENDCOLOR}"
	git init
fi

# Check for pre-commit 
if ! command -v pre-commit --version &> /dev/null ; then
	echo -e "${YELLOW}Warn: pre-commit not found!${ENDCOLOR}"
	while true; do
		echo -e "Do you want install ${BOLD}${BLUE}pre-commit${ENDCOLOR}? [Y/n]"
	    read -p '' yn
	    case $yn in
	        [Yy]* ) sudo apt install pre-commit; break;;
			"" )    sudo apt install pre-commit; break;;
	        [Nn]* ) echo -e "${GREEN}skipped${ENDCOLOR}"; break;;
	        * )     echo "Please answer yes or no.";;
	    esac
	done
fi


# add .pre-commit-config.yaml
if [ $YES_FLAG != true ]; then
	while true; do
		echo -e "Do you want to add ${BOLD}${BLUE}.pre-commit-config.yaml${ENDCOLOR}? [Y/n]"
	    read -p '' yn
	    case $yn in
	        [Yy]* ) wget $PRECOMMIT_CONFIG_URL; break;;
			"" )    wget $PRECOMMIT_CONFIG_URL; break;;
	        [Nn]* ) echo -e "${GREEN}skipped${ENDCOLOR}"; break;;
	        * )     echo "Please answer yes or no.";;
	    esac
	done
else
	echo -e "${BOLD}${BLUE}Adding... .pre-commit-config.yaml${ENDCOLOR}"
	wget $PRECOMMIT_CONFIG_URL
fi

# install pre-commit as git hooks
if [ $YES_FLAG != true ]; then
	while true; do
		echo -e "Do you want install ${BOLD}${BLUE}pre-commit git hooks${ENDCOLOR}? [Y/n]"
	    read -p '' yn
	    case $yn in
	        [Yy]* ) pre-commit install; break;;
			"" )    pre-commit install; break;;
	        [Nn]* ) echo -e "${GREEN}skipped${ENDCOLOR}"; break;;
	        * )     echo "Please answer yes or no.";;
	    esac
	done
else
	echo -e "${BOLD}${BLUE}Installing... pre-commit git hooks${ENDCOLOR}"
	pre-commit install
fi
