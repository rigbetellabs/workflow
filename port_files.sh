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
DIR_NAME=.

# Function to display script usage
usage() {
	echo "Usage: $0 --name annex [OPTIONS]"
	echo "Options:"
	echo " -h, --help      Display this help message"
	echo " -y, --yes       Enable -y flag to all commands"
	echo " -p, --path      PATH to the files to revamp"
}

has_argument() {
	[[ ("$1" == *=* && -n ${1#*=}) || (! -z "$2" && "$2" != -*) ]]
}

extract_argument() {
	echo "${2:-${1#*=}}"
}

# Function to handle options and arguments
handle_options() {
	while [ $# -gt 0 ]; do
		case $1 in
		-h | --help)
			usage
			exit 0
			;;
		-y | --yes)
			YES_FLAG=true
			;;
		-p | --path*)
			if ! has_argument $@; then
				echo -e "${RED}ERROR: Path not passed${ENDCOLOR}" >&2
				usage
				exit 1
			fi

			DIR_NAME=$(extract_argument $@)

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

install_pip() {
	while true; do
		echo -e "Do you want to install ${BOLD}${BLUE}python3-pip${ENDCOLOR}? [Y/n]"
		read -p '' yn
		case $yn in
		[Yy]*)
			sudo apt install python3-pip
			break
			;;
		"")
			sudo apt install python3-pip
			break
			;;
		[Nn]*)
			echo -e "${GREEN}skipped${ENDCOLOR}"
			break
			;;
		*) echo "Please answer yes or no." ;;
		esac
	done
}

check_install_pre_commit() {
	if ! command -v pip --version &>/dev/null; then
		echo -e "${RED}ERROR: pip not found!${ENDCOLOR}"
		install_pip
		pip install pre-commit
	else
		pip install pre-commit
	fi
}

create_temp() {
	sudo mkdir -p $WORKING_DIR/../temp/
	sudo mv $WORKING_DIR/* ../temp
}

create_dir() {
	echo -e "${BLUE}Creating new Strecture: "
	echo -e "${BOLD}$DIR_NAME/${ENDCOLOR}"

	mkdir -p $WORKING_DIR/packages
	echo -e "${GREEN}\t- packages${ENDCOLOR}"

	mkdir -p $WORKING_DIR/docs
	echo -e "${GREEN}\t- docs${ENDCOLOR}"

	mkdir -p $WORKING_DIR/dockerfiles
	echo -e "${GREEN}\t- dockerfiles${ENDCOLOR}"

	echo -e "${GREEN}Created directories${ENDCOLOR}\n"
}

copy_files_to_packages() {
	sudo mv $WORKING_DIR/../temp/* $WORKING_DIR/packages && sudo rm -rf $WORKING_DIR/../temp/
}

check_for_git() {
	if test -d $WORKING_DIR/packages/.git; then
		echo -e "${YELLOW}Found .git moving it outside...${ENDCOLOR}\n"
		sudo mv $WORKING_DIR/packages/.git $WORKING_DIR/
	fi
}
check_for_md(){
	if test -f $WORKING_DIR/packages/README.md; then
		echo -e "${YELLOW}Found README.md moving it outside...${ENDCOLOR}\n"
		sudo mv $WORKING_DIR/packages/README.md $WORKING_DIR/
	fi
}

# Main script execution
handle_options "$@"

CURR_DIR=$(pwd)
WORKING_DIR=${CURR_DIR}/$DIR_NAME

if ! test -d $WORKING_DIR; then
	echo -e "${RED}$WORKING_DIR \nDirectory Doesn't Exists! Please provide a directory${ENDCOLOR}"
	exit 1
else
	echo $WORKING_DIR
	cd $WORKING_DIR
fi

# copy files to packages folder
if [ $YES_FLAG != true ]; then
	while true; do
		echo -e "Do you want to ${BOLD}${BLUE}copy files to new structure${ENDCOLOR}? [Y/n]"
		read -p '' yn
		case $yn in
		[Yy]*)
			create_temp
			create_dir
			copy_files_to_packages
			check_for_git
			check_for_md
			break
			;;
		"")
			create_temp
			create_dir
			copy_files_to_packages
			check_for_git
			check_for_md
			break
			;;
		[Nn]*)
			echo -e "${GREEN}skipped${ENDCOLOR}"
			break
			;;
		*) echo "Please answer yes or no." ;;
		esac
	done
else
	echo -e "${BOLD}${BLUE}Copying files to new structure${ENDCOLOR}"
	create_temp
	create_dir
	copy_files_to_packages
	check_for_git
	check_for_md
fi

#########################
# add .gitignore
if [ $YES_FLAG != true ]; then
	while true; do
		echo -e "Do you want to add ${BOLD}${BLUE}.gitignore${ENDCOLOR}? [Y/n]"
		read -p '' yn
		case $yn in
		[Yy]*)
			wget $GITIGNORE_URL
			break
			;;
		"")
			wget $GITIGNORE_URL
			break
			;;
		[Nn]*)
			echo -e "${GREEN}skipped${ENDCOLOR}"
			break
			;;
		*) echo "Please answer yes or no." ;;
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
		[Yy]*)
			git init
			break
			;;
		"")
			git init
			break
			;;
		[Nn]*)
			echo -e "${GREEN}skipped${ENDCOLOR}"
			break
			;;
		*) echo "Please answer yes or no." ;;
		esac
	done
else
	echo -e "${BOLD}${BLUE}Performing \"git init\"${ENDCOLOR}"
	git init
fi

# Check for pre-commit
if ! command -v pre-commit --version &>/dev/null; then
	echo -e "${YELLOW}Warn: pre-commit not found!${ENDCOLOR}"
	while true; do
		echo -e "Do you want install ${BOLD}${BLUE}pre-commit${ENDCOLOR}? [Y/n]"
		read -p '' yn
		case $yn in
		[Yy]*)
			check_install_pre_commit
			break
			;;
		"")
			check_install_pre_commit
			break
			;;
		[Nn]*)
			echo -e "${GREEN}skipped${ENDCOLOR}"
			break
			;;
		*) echo "Please answer yes or no." ;;
		esac
	done
fi

# add .pre-commit-config.yaml
if [ $YES_FLAG != true ]; then
	while true; do
		echo -e "Do you want to add ${BOLD}${BLUE}.pre-commit-config.yaml${ENDCOLOR}? [Y/n]"
		read -p '' yn
		case $yn in
		[Yy]*)
			wget $PRECOMMIT_CONFIG_URL
			break
			;;
		"")
			wget $PRECOMMIT_CONFIG_URL
			break
			;;
		[Nn]*)
			echo -e "${GREEN}skipped${ENDCOLOR}"
			break
			;;
		*) echo "Please answer yes or no." ;;
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
		[Yy]*)
			pre-commit install
			break
			;;
		"")
			pre-commit install
			break
			;;
		[Nn]*)
			echo -e "${GREEN}skipped${ENDCOLOR}"
			break
			;;
		*) echo "Please answer yes or no." ;;
		esac
	done
else
	echo -e "${BOLD}${BLUE}Installing... pre-commit git hooks${ENDCOLOR}"
	pre-commit install
fi

# run pre-commit for initialization
if [ $YES_FLAG != true ]; then
	while true; do
		echo -e "Do you want run ${BOLD}${BLUE}pre-commit${ENDCOLOR}? [Y/n]"
		read -p '' yn
		case $yn in
		[Yy]*)
			pre-commit run --all-files
			break
			;;
		"")
			pre-commit run --all-files
			break
			;;
		[Nn]*)
			echo -e "${GREEN}skipped${ENDCOLOR}"
			break
			;;
		*) echo "Please answer yes or no." ;;
		esac
	done
else
	echo -e "${BOLD}${BLUE}Running... pre-commit${ENDCOLOR}"
	pre-commit run --all-files
fi

echo -e "${GREEN}${BOLD}\nDONE...!\n${ENDCOLOR}"
