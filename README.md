# Workflow

### 1. To create a new workspace
```bash
bash <(wget -qO- https://raw.githubusercontent.com/rigbetellabs/workflow/master/start.sh) --name workspace_name
```
Usage and args:
```
Usage: start.sh [OPTIONS] args
	Example: start.sh --name workspace_name -y
 -h, --help      Display this help message
 -y, --yes       Enable -y flag to all commands
 -n, --name      STRING Repository name to create
```

### 2. To port existing workspace
```bash
bash <(wget -qO- https://raw.githubusercontent.com/rigbetellabs/workflow/master/port_files.sh) --path workspace_name
```
Usage and args:
```
Usage: port_files.sh [OPTIONS] args
	Example: port_files.sh --path workspace_name -y
 -h, --help      Display this help message
 -y, --yes       Enable -y flag to all commands
 -p, --path      PATH to the files to revamp
```
