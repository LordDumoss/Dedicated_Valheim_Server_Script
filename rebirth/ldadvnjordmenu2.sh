#!/bin/bash
###############################################################################################
###############################################################################################
####
#### From: Zerobandwidth
####
#### Thank you for using the menu script, this started out as just me and blew up quickly.
#### If Frankenstein was a bash script, this is what you would get, so please help me improve it.
#### Feel free to use and change this as you wish just not for profit.
#### If you need anything, please visit our Discord Server: https://discord.gg/ejgQUfc
#### *** GLHF - V/r, Zerobandwidth and Team
####
###############################################################################################
####
####  Forked from: njordmenu.sh 4.0Thor
#### This version: ldadvnjordmenu2.sh
####  Modified by: Lord Du'Moss
####      Updated: 18-SEPT-2026
####
###############################################################################################
####
#### I would like to thank Zerobandwidth and the development team
#### this wonderfull script. :)
####
#### Please use the same discord for issues.
####
#### LD VERSION: 1.0.+
#### Added: Linux support for Fedora-Cento-RHEL-OEL-yum/dnf based systems.
#### Added: Multiple servers on a single node based on WORLDNAME.
#### Installed: "${worldpath}/${worldname}"
####   Example: /home/steam/valheimserver/SomeValheimWorldName
####
#### LD VERSION: 2.2.5B
####      Fixed: all rpm manager sections to work on all Linux flavors.
####      Fixed: steam download for all Linux flavors.
####      Fixed: bepinex download issues due to Thunderstore URL changes.
####        ...: Should now always find and download the latest version.
####    Updated: The Bepinex create startup script function.
####        .U1: Added the new bepinex parameters to startup.
####        .U2: Fixed to run on all Linux flavors.
####    Removed: All ValheimPlus code, as this system is no longer maintained.
####      Added: Back the rename world function. Use with care.
####       Beta: Finished the Firewall controls.
####        ...: See "FIREWALL CONFIGURATION" section.
####
#### LD VERSION: 2.2.6B -- Comments
#### LD VERSION: 2.2.7B -- minor menu format fixes.
#### LD VERSION: 2.2.8B -- minor bugs
####
#### *** - Lord Du'Moss
####
###############################################################################################
#### Current Options: DE=German, EN=English, FR=French, SP=Spanish"
###############################################################################################
###############################################################################################
## Sourceing OS and language system env variables.
## NOTE: If there is no /etc/os-release file please use package manager to install it.
###############################################################################################
source /etc/os-release
if [ "$1" == "" ]
then
	LANGUAGE=EN
else
	LANGUAGE=$1
fi
source lang/$LANGUAGE.conf
###############################################################
########################  Santiy Check  #######################
###############################################################
echo "$(tput setaf 4)"$DRAW60""
echo "$(tput setaf 0)$(tput setab 7)"$CHECKSUDO"$(tput sgr 0)"
echo "$(tput setaf 0)$(tput setab 7)"$CHECKSUDO1"$(tput sgr 0)"
echo "$(tput setaf 4)"$DRAW60""
# Re-run as root through sudo when needed.
[[ "$EUID" -eq 0 ]] || exec sudo "$0" "$@"
clear

### ========================================================================
### SYSTEM GLOBAL PATHS & ENVIRONMENT CORE REGISTRY
### ========================================================================
### WARNING: Modify these variables ONLY if you understand file trees.
### Overriding these incorrectly will break multi-world deployment maps.
### Binary Root: The absolute base path where dedicated server engines reside.
valheimInstallPath=/home/steam/valheimserver
### Engine Save Tree: Native directory where IronGate databases store saves and worlds.
worldpath=/home/steam/.config/unity3d/IronGate/Valheim
### Database Indexer: Plain-text list of active worlds tracked by this script.
worldfilelist=/home/steam/worlds.txt
# Admin Tracker: Keeps a list of administrative credentials and setup choices.
worldconfigfile=/home/steam/serverSetup.txt
### Archive Repository: Root path used by the automated system backup tools.
backupPath=/home/steam/backups
### ========================================================================
### ADVANCED CONFIGURATION PARAMETERS (SteamCMD Tracking Flags)
### ========================================================================
### NOTE: This parameter is a legacy toggle reserved for manual Enterprise
### RHEL/OEL/CentOS tarball deployments where SteamCMD is unbundled.
### On Fedora 44 and Ubuntu nodes, the core installer routines natively handle
### automated directory pruning and dependency verification steps.
### Options: [ n = No (Keep files) | y = Yes (Wipe directory fresh) ]
freshinstall="n"
### ========================================================================
### FIREWALL CONFIGURATION
### ========================================================================
### Master Switch: Toggle automated firewall rule management [ y = Yes | n = No ]
### NOTE: Setting this to "y" allows the script to inject network rules using sudo.
usefw="n"
# Active Engine: Specify the exact firewall manager active on your distribution.
# Mappings: Use "firewalld" for Fedora/RHEL or "ufw" for Ubuntu/Debian.
fwbeingused="firewalld"
# Disabling Array: Known system firewall daemons tracked by this script.
# CRITICAL: Do not modify this array list. The script uses this sequence to cleanly
# purge and disable conflicting security layers during global resets.
fwsystems=( arptables ebtables firewalld iptables ip6tables ufw )
# ========================================================================
# SYSTEM DIAGNOSTICS & RUNTIME DEBUGGING
# ========================================================================
# Master Debug Toggle: Display low-level tracing messages [ y = Yes | n = No ]
# NOTE: Setting this to "y" prints structural data metrics to the screen
# during complex state transitions and function executions.
debugmsg="n"
# Developers can Copy/Paste Snippet Template below:
# [ "$debugmsg" == "y" ] && echo "DEBUG: Enter messaging notes here"
###############################################################
# Set Menu Version for menu display
###############################################################
mversion="4.0-Thor"
ldversion="2.2.6B"
########################################################################
#############################Set COLOR VARS#############################
########################################################################
NOCOLOR='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHTRED='\033[1;31m'
LIGHTGREEN='\033[1;32m'
YELLOW='\033[1;33m'
WHITE='\033[1;37m'
clear='\e[0m'
##
# Color Functions
##
ColorRed(){
	echo -ne $RED$1$clear
}
ColorGreen(){
	echo -ne $GREEN$1$clear
}
ColorOrange(){
	echo -ne $ORANGE$1$clear
}
ColorBlue(){
	echo -ne $BLUE$1$clear
}
ColorPurple(){
	echo -ne $PURPLE$1$clear
}
ColorCyan(){
	echo -ne $CYAN$1$clear
}
ColorLightRed(){
	echo -ne $LIGHTRED$1$clear
}
ColorLightGreen(){
	echo -ne $LIGHTGREEN$1$clear
}
ColorYellow(){
	echo -ne $LIGHTYELLOW$1$clear
}
ColorWhite(){
	echo -ne $WHITE$1$clear
}
########################################################################
#####################Check for Menu Updates#############################
########################################################################
# Track the current script path and git state for update checks.
MENUSCRIPT="$(readlink -f "$0")"
SCRIPTFILE="$(basename "$MENUSCRIPT")"
SCRIPTPATH="$(dirname "$SCRIPT")"
SCRIPTNAME="$0"
ARGS=( "$@" )
BRANCH=$(git rev-parse --abbrev-ref HEAD)
UPSTREAM=$(git rev-parse --abbrev-ref --symbolic-full-name @{upstream})

# Check for script updates from the upstream git branch.
function script_check_update() {
    echo "1"
    git fetch

    # Check if there are updates available.
    if [ -n "$(git diff --name-only "$UPSTREAM" "$SCRIPTFILE")" ]; then
        echo "$GIT_ECHO_CHECK"
        sleep 1
        git pull --force
        git stash
        git checkout "$BRANCH"
        git pull --force
        echo "$GIT_ECHO_UPDATING"
        sleep 1
        chmod +x *menu.sh
        sleep 1
        # Restart the script with the same arguments
        exec "$SCRIPTNAME" "${ARGS[@]}"
        # Exit the old instance
        exit 1
    else
        echo "$GIT_ECHO_NO_UPDATES"
    fi
}

########################################################################
##############MAIN VALHEIM SERVER ADMIN FUNCTIONS START#################
########################################################################

########################################################################
#####################Install Valheim Server START#######################
########################################################################

# Create the dedicated steam account used to run the server.
function valheim_server_steam_account_creation() {
    echo "$START_INSTALL_1_PARA"

    while true; do
        tput setaf 2; echo "$DRAW60" ; tput setaf 9;
        tput setaf 2; echo "$STEAM_NON_ROOT_STEAM_PASSWORD" ; tput setaf 9;
        tput setaf 2; echo "$DRAW60" ; tput setaf 9;
        tput setaf 1; echo "$STEAM_PASS_MUST_BE" ; tput setaf 9;
        tput setaf 1; echo "$STEAM_PASS_MUST_BE_1" ; tput setaf 9;
        tput setaf 2; echo "$DRAW60" ; tput setaf 9;
        tput setaf 2; echo "$STEAM_GOOD_EXAMPLE" ; tput setaf 9;
        tput setaf 1; echo "$STEAM_BAD_EXAMPLE" ; tput setaf 9;
        tput setaf 2; echo "$DRAW60" ; tput setaf 9;
        echo ""

        read -p "$STEAM_PLEASE_ENTER_STEAM_PASSWORD" userpassword

        tput setaf 2; echo "$DRAW60" ; tput setaf 9;

        if [[ ${#userpassword} -ge 6 && "$userpassword" == *[[:lower:]]* && "$userpassword" == *[[:upper:]]* && "$userpassword" =~ ^[[:alnum:]]+$ ]]; then
            break
        else
            tput setaf 2; echo "$STEAM_PASS_NOT_ACCEPTED" ; tput setaf 9;
            tput setaf 2; echo "$STEAM_PASS_NOT_ACCEPTED_1" ; tput setaf 9;
        fi
    done

    echo ""

    # Set environment and bash profile for steam user.
    tput setaf 1; echo "$INSTALL_BUILD_NON_ROOT_STEAM_ACCOUNT" ; tput setaf 9;
    sleep 1

	if command -v apt-get >/dev/null; then
		# Ubuntu / Debian / Mint / Pop!_OS
		useradd --create-home --shell /bin/bash steam
		echo "steam:$userpassword" | chpasswd
		cp /etc/skel/.bashrc /home/steam/.bashrc
		cp /etc/skel/.profile /home/steam/.profile

	elif command -v dnf >/dev/null || command -v yum >/dev/null; then
		# Fedora / RHEL / CentOS / Rocky Linux / AlmaLinux
		if getent group steam >/dev/null 2>&1; then
			echo "Group 'steam' is assigned to another user profile. Creating account using it as an existing group attachment..."
			sudo useradd -m -g steam -s /bin/bash steam
		else
			# Fallback if the group is entirely unassigned
			sudo useradd -mU -s /bin/bash steam
		fi
		echo "steam:$userpassword" | chpasswd

	elif command -v pacman >/dev/null; then
		# Arch Linux / Manjaro
		useradd -m -s /bin/bash steam
		echo "steam:$userpassword" | chpasswd

	elif command -v zypper >/dev/null; then
		# openSUSE / SUSE Linux Enterprise
		useradd -mU -s /bin/bash steam
		echo "steam:$userpassword" | chpasswd

	else
		echo "Unsupported or unrecognized Linux distribution."
	fi

    tput setaf 2; echo "$ECHO_DONE" ; tput setaf 9;
}

# Collect the public display name shown in the server browser.
function valheim_server_public_server_display_name() {
    echo ""

    # Display instructions for Valheim Server Public Display Name
    for msg in "$DRAW60" "$PUBLIC_SERVER_DISPLAY_NAME" "$DRAW60" "$PUBLIC_SERVER_DISPLAY_NAME_1" \
               "$PUBLIC_SERVER_DISPLAY_NAME_2" "$DRAW60" "$PUBLIC_SERVER_DISPLAY_GOOD_EXAMPLE" \
               "$PUBLIC_SERVER_DISPLAY_GOOD_EXAMPLE_1" "$PUBLIC_SERVER_DISPLAY_BAD_EXAMPLE" "$DRAW60"; do
        tput setaf 2; echo "$msg"; tput setaf 9;
    done

    echo ""

    # Prompt user for Valheim Server Public Display Name
    read -p "$PUBLIC_SERVER_ENTER_NAME" displayname

    tput setaf 2; echo "------------------------------------------------------------"; tput setaf 9;
    echo ""
}

# Collect and validate the local world name.
function valheim_server_local_world_name() {
    # Set world name function that will be used for .db and .fwl files
    echo ""

    while true; do
        # Display instructions for setting the world name
        for msg in "$DRAW60" "$WORLD_SET_WORLD_NAME_HEADER" "$DRAW60" "$WORLD_SET_CHAR_RULES" \
                   "$WORLD_SET_NO_SPECIAL_CHAR_RULES" "$DRAW60" "$WORLD_GOOD_EXAMPLE" \
                   "$WORLD_BAD_EXAMPLE" "$DRAW60"; do
            tput setaf 2; echo "$msg"; tput setaf 9;
        done

        echo ""
        read -p "$WORLD_SET_WORLD_NAME_VAR" worldname
        tput setaf 2; echo "------------------------------------------------------------"; tput setaf 9;

        # Validate the world name.
        if [[ ${#worldname} -ge 4 && "$worldname" =~ ^[[:alnum:]]+$ ]]; then
            break
        else
            tput setaf 2; echo "$WORLD_SET_ERROR"; tput setaf 9;
            tput setaf 2; echo "$WORLD_SET_ERROR_1"; tput setaf 9;
        fi
    done

    clear
    echo ""
}

# Choose the base Valheim port for the server.
function valheim_server_public_valheim_port() {
    # Take user input for Valheim Server port and display instructions
    echo ""

    for msg in "$DRAW60" "$FUNCTION_VALHEIM_SERVER_INSTALL_LD_SETPORTNEW_HEADER" "$DRAW60" \
               "$FUNCTION_VALHEIM_SERVER_INSTALL_LD_SETPORTNEW_INFO1" "$FUNCTION_VALHEIM_SERVER_INSTALL_LD_SETPORTNEW_INFO2" \
               "$DRAW60" "$FUNCTION_VALHEIM_SERVER_INSTALL_LD_SETPORTNEW_INFO3" "$FUNCTION_VALHEIM_SERVER_INSTALL_LD_SETPORTNEW_INFO4" \
               "$FUNCTION_VALHEIM_SERVER_INSTALL_LD_SETPORTNEW_INFO5" "$DRAW60"; do
        tput setaf 2; echo "$msg"; tput setaf 9;
    done

    echo ""

    while true; do
        read -p "$FUNCTION_VALHEIM_SERVER_INSTALL_LD_SETPORTNEW_ENTER" portnumber
        # Validate port number.
        if [[ ${#portnumber} -ge 4 && ${#portnumber} -le 6 ]] && [[ $portnumber -gt 1024 && $portnumber -le 65530 ]] && [[ "$portnumber" =~ ^[[:alnum:]]+$ ]]; then
            break
        fi
    done

    tput setaf 2; echo "------------------------------------------------------------"; tput setaf 9;
    clear
    echo ""
}

# Set whether the server is public.
function valheim_server_public_listing() {
    # Set public listing: 1 = Display Server, 0 = LAN or do not display server public
    echo ""

    for msg in "$DRAW60" "$PUBLIC_ENABLED_DISABLE_HEADER" "$DRAW60" "$PUBLIC_ENABLED_DISABLE_INFO" \
               "$DRAW60" "$PUBLIC_ENABLED_DISABLE_EXAMPLE_SHOW" "$PUBLIC_ENABLED_DISABLE_EXAMPLE_LAN_NO_SHOW" "$DRAW60"; do
        tput setaf 2; echo "$msg"; tput setaf 9;
    done

    echo ""
    read -p "$PUBLIC_ENABLED_DISABLE_INPUT" publicList

    tput setaf 2; echo "------------------------------------------------------------"; tput setaf 9;
    echo ""

    # Display credentials
    echo "$CREDS_DISPLAY_CREDS_PRINT_OUT_HEADER"
    tput setaf 2; echo "$DRAW60"; tput setaf 9;
    tput setaf 2; echo "$CREDS_DISPLAY_CREDS_PRINT_OUT_STEAM_PASSWORD $userpassword"; tput setaf 9;
    tput setaf 2; echo "$CREDS_DISPLAY_CREDS_PRINT_OUT_SERVER_NAME $displayname"; tput setaf 9;
    tput setaf 2; echo "$CREDS_DISPLAY_CREDS_PRINT_OUT_WORLD_NAME $worldname"; tput setaf 9;
    tput setaf 2; echo "Port number being used: $portnumber"; tput setaf 9;
    tput setaf 2; echo "$CREDS_DISPLAY_CREDS_PRINT_OUT_ACCESS_PASS $password"; tput setaf 9;
    tput setaf 2; echo "$CREDS_DISPLAY_CREDS_PRINT_OUT_SHOW_PUBLIC $publicList"; tput setaf 9;
    tput setaf 2; echo "$DRAW60"; tput setaf 9;
    echo ""
}

# Collect and validate the server password.
function valheim_server_public_access_password() {
    # Added security for password complexity
    echo ""

    for msg in "$DRAW60" "$SERVER_ACCESS_PASS_HEADER" "$DRAW60" "$SERVER_ACCESS_INFO" \
               "$DRAW60" "$SERVER_ACCESS_PUBLIC_NAME_INFO $displayname" "$SERVER_ACCESS_WORLD_NAME_INFO $worldname" "$DRAW60"; do
        tput setaf 2; echo "$msg"; tput setaf 9;
    done

    while true; do
        for msg in "$SERVER_ACCESS_WARN_INFO" "$SERVER_ACCESS_WARN_INFO_1" "$DRAW60" \
                   "$SERVER_ACCESS_GOOD_EXAMPLE" "$SERVER_ACCESS_BAD_EXAMPLE" "$DRAW60"; do
            tput setaf 1; echo "$msg"; tput setaf 9;
        done

        read -p "$SERVER_ACCESS_ENTER_PASSWORD" password
        tput setaf 2; echo "------------------------------------------------------------"; tput setaf 9;

        # Validate password complexity.
        if [[ ${#password} -ge 5 && "$password" == *[[:lower:]]* && "$password" == *[[:upper:]]* && "$password" =~ ^[[:alnum:]]+$ ]]; then
            break
        else
            tput setaf 2; echo "$SERVER_ACCESS_PASSWORD_ERROR"; tput setaf 9;
            tput setaf 2; echo "$SERVER_ACCESS_PASSWORD_ERROR_1"; tput setaf 9;
        fi
    done
}

# Set the Crossplay option.
function valheim_server_set_crossplay() {
    echo ""

    for msg in "$DRAW60" "Set up Crossplay" "$DRAW60" \
               "Crossplay allows you to play with friends on other platforms" \
               "Crossplay 1 = Enabled" "Crossplay 0 = Disabled" \
               "$DRAW60" "Do you wish to enable Crossplay?" "$DRAW60"; do
        tput setaf 2; echo "$msg"; tput setaf 9;
    done

    echo ""
    read -p "Enter 1 for Yes or 0 for No: " crossplay
    tput setaf 2; echo "------------------------------------------------------------"; tput setaf 9;
    echo ""
}

# Save server config values to the tracked config files.
function build_configuration_env_files_set_permissions() {
    ## Populate the system control worldfilelist and worldconfigfile parameters files.
    echo "$DRAW60"
    echo "$CREDS_DISPLAY_CREDS_PRINT_OUT_STEAM_PASSWORD $userpassword"
    echo "$CREDS_DISPLAY_CREDS_PRINT_OUT_SERVER_NAME $displayname"
    echo "$CREDS_DISPLAY_CREDS_PRINT_OUT_WORLD_NAME $worldname"
    echo "$CREDS_DISPLAY_CREDS_PRINT_OUT_PORT_USED $portnumber"
    echo "$CREDS_DISPLAY_CREDS_PRINT_OUT_ACCESS_PASS $password"
    echo "$CREDS_DISPLAY_CREDS_PRINT_OUT_SHOW_PUBLIC $publicList"
    echo "CrossPlay Option 1 = Enabled - 0 = Disabled $crossplay"
    echo "$DRAW60"

    if [ ! -f "$worldconfigfile" ]; then
       touch "$worldconfigfile"
    fi

    {
        echo "$DRAW60"
        echo "$CREDS_DISPLAY_CREDS_PRINT_OUT_STEAM_PASSWORD $userpassword"
        echo "$CREDS_DISPLAY_CREDS_PRINT_OUT_SERVER_NAME $displayname"
        echo "$CREDS_DISPLAY_CREDS_PRINT_OUT_WORLD_NAME $worldname"
        echo "$CREDS_DISPLAY_CREDS_PRINT_OUT_PORT_USED $portnumber"
        echo "$CREDS_DISPLAY_CREDS_PRINT_OUT_ACCESS_PASS $password"
        echo "$CREDS_DISPLAY_CREDS_PRINT_OUT_SHOW_PUBLIC $publicList"
        echo "CrossPlay Option 1 = Enabled - 0 = Disabled $crossplay"
        echo "$DRAW60"
    } >> "$worldconfigfile"

    sleep 1

    if [ ! -f "$worldfilelist" ]; then
        touch "$worldfilelist"
    fi

    echo "$worldname" >> "$worldfilelist"

    sleep 1

    chown -Rf steam:steam /home/steam/*.txt
    clear
}

# Run the installation flow, including SteamCMD and world setup.
function valheim_server_install() {
    clear
    echo ""

    # First-time install flow.
    if [ "$newinstall" == "y" ]; then
        for msg in "Thank you for using the Njord Menu system." \
                   "This appears to be the first time the menu has" \
                   "been run on this system." \
                   "Installing the first Valheim server started."; do
            tput setaf 2; echo "$msg"; tput setaf 9;
        done

        linux_server_update
        valheim_server_steam_account_creation
        Install_steamcmd_client
        valheim_server_public_server_display_name
        valheim_server_local_world_name
        portnumber=2456
        valheim_server_public_listing
        valheim_server_public_access_password
        valheim_server_set_crossplay
        build_configuration_env_files_set_permissions
    else
        # Additional world install flow.
        valheim_server_public_server_display_name
        valheim_server_local_world_name
        valheim_server_public_valheim_port
        valheim_server_public_listing
        valheim_server_public_access_password
        valheim_server_set_crossplay
        build_configuration_env_files_set_permissions
    fi

    nocheck_valheim_update_install

    tput setaf 1; echo "$INSTALL_BUILD_SET_STEAM_PERM"; tput setaf 9;
    chown -Rf steam:steam /home/steam/*
    tput setaf 2; echo "$ECHO_DONE"; tput setaf 9;
    sleep 1

    # ========================================================================
    # BEGIN of AUTOMATED INSTALLER FIREWALL INJECTION LAYER
    # ========================================================================
    if [ "${usefw}" == "y" ]; then
        # Calculate the end of the port range.
        local port_max=$((portnumber + 2))

        case "${fwbeingused}" in
            ufw)
                if command -v ufw >/dev/null; then
                    sudo ufw allow ${portnumber}:${port_max}/udp
                    echo "Adding ports ${portnumber}:${port_max}/udp to the UFW system."
                fi
                ;;
            iptables)
                if command -v iptables >/dev/null; then
                    echo "Configuring iptables bindings placeholder."
                fi
                ;;
            firewalld)
                if command -v firewall-cmd >/dev/null; then
                    local fw_active_state
                    fw_active_state=$(systemctl is-active firewalld 2>/dev/null)

                    if [ "$fw_active_state" == "active" ]; then
                        currentPort="$portnumber"
                        sftc="val"
                        add_Valheim_server_public_ports
                    else
                        echo "Firewalld is configured in your script header but is currently stopped in OS memory. Skipping rule injection."
                    fi
                fi
                ;;
            *)
                echo "No firewall configuration detected matching: ${fwbeingused}"
                ;;
        esac
    else
        local system_fw_check
        system_fw_check=$(systemctl is-active firewalld 2>/dev/null || systemctl is-active ufw 2>/dev/null)
        if [ "$system_fw_check" == "active" ];
		then
            disable_all_firewalls
        fi
    fi
    # ========================================================================
    # END of AUTOMATED INSTALLER FIREWALL INJECTION LAYER
    # ========================================================================

    tput setaf 2; echo "$ECHO_DONE"; tput setaf 9;
    sleep 1

	# Build the world-specific Valheim startup script.
    tput setaf 1; echo "$INSTALL_BUILD_DELETE_OLD_CONFIGS"; tput setaf 9;
    tput setaf 1; echo "$INSTALL_BUILD_DELETE_OLD_CONFIGS_1"; tput setaf 9;

    if [ ! -d "${valheimInstallPath}/${worldname}" ]; then
        echo "Directory missing for ${worldname}. Creating path structure..."
        mkdir -p "${valheimInstallPath}/${worldname}"
        chown -Rf steam:steam "${valheimInstallPath}/${worldname}"
    fi

    [ -e ${valheimInstallPath}/${worldname}/start_valheim_${worldname}.sh ] && rm ${valheimInstallPath}/${worldname}/start_valheim_${worldname}.sh
    sleep 1

    cat > ${valheimInstallPath}/${worldname}/start_valheim_${worldname}.sh <<EOF
#!/bin/bash
export templdpath=\$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=./linux64:\$LD_LIBRARY_PATH
export SteamAppId=892970
./valheim_server.x86_64 -name "${displayname}" -port "${portnumber}" -nographics -batchmode -world "${worldname}" -password "${password}" -public "${publicList}" -savedir "${worldpath}/${worldname}" -logfile "${worldpath}/${worldname}/valheim_server.log" -crossplay "${crossplay}"
export LD_LIBRARY_PATH=\$templdpath
EOF

    tput setaf 2; echo "$ECHO_DONE"; tput setaf 9;
    sleep 1

    # Delete old check log script.
    tput setaf 1; echo "$INSTALL_BUILD_DELETE_OLD_SCRIPT"; tput setaf 9;
    [ -e /home/steam/check_log.sh ] && rm /home/steam/check_log.sh

    # Set the startup script executable.
    tput setaf 1; echo "$INSTALL_BUILD_SET_PERM_ON_START_VALHEIM"; tput setaf 9;
    chmod +x ${valheimInstallPath}/${worldname}/start_valheim_${worldname}.sh
    tput setaf 2; echo "$ECHO_DONE"; tput setaf 9;
    sleep 1

    # Build the systemd service for the Valheim server.
    tput setaf 1; echo "$INSTALL_BUILD_DEL_OLD_SERVICE_CONFIG"; tput setaf 9;
    tput setaf 1; echo "$INSTALL_BUILD_DEL_OLD_SERVICE_CONFIG_1"; tput setaf 9;

    # Remove old Valheim Server Service
    [ -e /etc/systemd/system/valheimserver_${worldname}.service ] && rm /etc/systemd/system/valheimserver_${worldname}.service
    [ -e /lib/systemd/system/valheimserver_${worldname}.service ] && rm /lib/systemd/system/valheimserver_${worldname}.service
    sleep 1

    # Add new Valheim Server Service
    cat > /lib/systemd/system/valheimserver_${worldname}.service <<EOF
[Unit]
Description=Valheim Server
Wants=network-online.target
After=syslog.target network.target nss-lookup.target network-online.target

[Service]
Type=simple
Restart=on-failure
RestartSec=5
StartLimitInterval=60s
StartLimitBurst=3
User=steam
Group=steam
ExecStartPre=$steamexe +login anonymous +force_install_dir ${valheimInstallPath}/${worldname} +app_update 896660 validate +exit
ExecStart=${valheimInstallPath}/${worldname}/start_valheim_${worldname}.sh
ExecReload=/bin/kill -s HUP \$MAINPID
KillSignal=SIGINT
WorkingDirectory=${valheimInstallPath}/${worldname}
LimitNOFILE=100000

[Install]
WantedBy=multi-user.target
EOF

    tput setaf 2; echo "$ECHO_DONE"; tput setaf 9;
    sleep 1

    # Set ownership of the steam directory.
    tput setaf 1; echo "$INSTALL_BUILD_SET_STEAM_PERMS"; tput setaf 9;
    chown -Rf steam:steam /home/steam/*
    tput setaf 2; echo "$ECHO_DONE"; tput setaf 9;
    sleep 1

    # Reload daemon config.
    tput setaf 1; echo "$INSTALL_BUILD_RELOAD_DAEMONS"; tput setaf 9;
    systemctl daemon-reload
    tput setaf 2; echo "$ECHO_DONE"; tput setaf 9;
    sleep 1

    # Start the world service.
    tput setaf 1; echo "$INSTALL_BUILD_START_VALHEIM_SERVICE"; tput setaf 9;
    systemctl start valheimserver_${worldname}.service
    tput setaf 2; echo "$ECHO_DONE"; tput setaf 9;
    sleep 1

    # Enable service on boot.
    tput setaf 1; echo "$INSTALL_BUILD_ENABLE_VALHEIM_SERVICE"; tput setaf 9;
    systemctl enable valheimserver_${worldname}.service
    tput setaf 2; echo "$ECHO_DONE"; tput setaf 9;
    sleep 2

    clear
    tput setaf 2; echo "$INSTALL_BUILD_FINISH_THANK_YOU"; tput setaf 9;
    echo ""
    echo ""
}

########################################################################
#####################Install Valheim Server END#########################
########################################################################

########################################################################
#####################Manager Valheim Server BEGIN#######################
########################################################################

# Update the operating system and install required server dependencies.
function linux_server_update() {
    # Dynamically read core OS parameters if not initialized
    [ -z "$ID" ] && [ -f /etc/os-release ] && source /etc/os-release

    echo "OS Detected: $ID"
    echo "Version: $VERSION"

    # ==========================================
    # STEP 1: INITIAL CORE UPGRADES
    # ==========================================
    tput setaf 1; echo "$CHECK_FOR_UPDATES"; tput setaf 9;

    if command -v apt-get >/dev/null; then
        sudo apt update && sudo apt upgrade -y
    elif command -v dnf >/dev/null; then
        sudo dnf upgrade -y --refresh
    elif command -v yum >/dev/null; then
        sudo yum clean all && sudo yum upgrade -y
    else
        echo "Unsupported package manager encountered."
    fi

    tput setaf 2; echo "$ECHO_DONE"; tput setaf 9; sleep 1

    # ==========================================
    # STEP 2: INSTALL BASE 32-BIT & UTILITY PACKAGES
    # ==========================================
    tput setaf 1; echo "$INSTALL_ADDITIONAL_FILES"; tput setaf 9;

    if command -v apt-get >/dev/null; then
        sudo apt install -y lib32gcc1 libsdl2-2.0-0 libsdl2-2.0-0:i386 git mlocate net-tools unzip curl lsof
    elif command -v dnf >/dev/null || command -v yum >/dev/null; then
        if [[ "$ID" == "fedora" ]] || [[ "$ID" =~ ^(centos|ol|rhel|rocky|almalinux)$ ]]; then
            # Safe universal package names across Red Hat extensions
            sudo ${cat_pkg_mgr:-dnf} install -y glibc.i686 libstdc++.i686 git mlocate net-tools unzip curl lsof
        else
            echo "Unsupported RPM-based flavor."
        fi
    fi

    tput setaf 2; echo "$ECHO_DONE"; tput setaf 9; sleep 1

    # ==========================================
    # STEP 3: ENVIRONMENT PREPARATION (UBUNTU-ONLY)
    # ==========================================
    tput setaf 1; echo "$INSTALL_SPCP"; tput setaf 9;
    if command -v apt-get >/dev/null; then
        sudo apt install -y software-properties-common
    else
        echo "$FUNCTION_LINUX_SERVER_UPDATE_YUM_REQUIRED_NO"
    fi

    tput setaf 2; echo "$ECHO_DONE"; tput setaf 9; sleep 1

    # ==========================================
    # STEP 4: EXTRA THIRD-PARTY REPOSITORY BINDINGS
    # ==========================================
    tput setaf 1; echo "$ADD_MULTIVERSE"; tput setaf 9;

    if command -v apt-get >/dev/null; then
        sudo add-apt-repository -y multiverse

    elif [[ "$ID" == "fedora" ]]; then
        # Install RPM Fusion repositories.
        sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
        # Add the Negativo17 Steam repository.
        sudo dnf config-manager addrepo --from-repofile=https://negativo17.org/repos/fedora-steam.repo

    elif [[ "$ID" =~ ^(centos|ol|rhel|rocky|almalinux)$ ]]; then
        if [[ "${VERSION:0:1}" == "7" ]]; then
            # Configure repositories for legacy enterprise systems.
            sudo yum install -y https://fedoraproject.org
            sudo yum-config-manager --add-repo=https://negativo17.org
        else
            # Configure repositories for newer enterprise systems.
            sudo dnf install -y https://fedoraproject.org{VERSION:0:1}.noarch.rpm
            sudo dnf config-manager --add-repo=https://negativo17.org
        fi
    else
        echo "No target repositories found matching this environment."
    fi

    # ==========================================
    # STEP 5: ARCHITECTURE OVERLAYS (UBUNTU-ONLY)
    # ==========================================
    tput setaf 1; echo "$ADD_I386"; tput setaf 9;
    if command -v apt-get >/dev/null; then
        sudo dpkg --add-architecture i386
    else
        echo "$FUNCTION_LINUX_SERVER_UPDATE_RHL_REQUIRED_NO"
    fi

    tput setaf 2; echo "$ECHO_DONE"; tput setaf 9; sleep 1

    # ==========================================
    # STEP 6: POST-REPOSITORY TRANSACTION SYNC
    # ==========================================
    tput setaf 1; echo "$CHECK_FOR_UPDATES_AGAIN"; tput setaf 9;
    if command -v apt-get >/dev/null; then
        sudo apt update && sudo apt install -y libpulse-dev libatomic1 libc6
    elif command -v dnf >/dev/null; then
        sudo dnf upgrade -y --refresh --allowerasing
    elif command -v yum >/dev/null; then
        sudo yum update -y
    fi

    tput setaf 2; echo "$ECHO_DONE"; tput setaf 9; sleep 1
}

# Install SteamCMD and configure its required network access.
function Install_steamcmd_client() {
    # Install steamcmd and related dependencies based on the Linux flavor
    tput setaf 1; echo "$INSTALL_STEAMCMD_LIBSD12"; tput setaf 9;

    if command -v apt-get >/dev/null; then
	    # Install SteamCMD from the Debian-based package repository.
        echo steam steam/license note '' | sudo debconf-set-selections
        echo steam steam/question select 'I AGREE' | sudo debconf-set-selections
        sudo apt install -y steamcmd libsdl2-2.0-0 libsdl2-2.0-0:i386
        tput setaf 2; echo "$ECHO_DONE"; tput setaf 9;
    elif command -v yum >/dev/null; then
	    # Install Steam packages where available on RPM-based systems.
        if [[ "$ID" == "fedora" ]] || [[ "$ID" =~ ^(centos|ol|rhel)$ && "${VERSION:0:1}" == "8" ]]; then
            sudo dnf -y install steam kernel-modules-extra
        elif [[ "$ID" =~ ^(centos|ol|rhel)$ && "${VERSION:0:1}" == "7" ]]; then
            sudo yum -y install steam
        else
            echo "Unsupported version for yum/dnf."
        fi

        # Download and install SteamCMD manually for yum systems.
        steamzipfile="/home/steam/steamcmd/steamcmd_linux.tar.gz"
        mkdir -p /home/steam/steamcmd
        cd /home/steam/steamcmd

        [ -e $steamzipfile ] && rm $steamzipfile
        [ "$freshinstall" == "y" ] && rm -rfv /home/steam/steamcmd/*

        wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
        tar xf steamcmd_linux.tar.gz
        tput setaf 2; echo "$ECHO_DONE"; tput setaf 9;
    else
        echo "Unsupported package manager."
    fi

    # Configure firewall settings for SteamCMD.
    if [ "${usefw}" == "y" ]; then
        case "${fwbeingused}" in
            ufw)
                if command -v ufw >/dev/null; then
                    sudo ufw allow 1200/udp
                    sudo ufw allow 27020/udp
                    sudo ufw allow 27000-27015/udp
                    sudo ufw allow 27015-27016/both
                    sudo ufw allow 27030-27039/both
                    echo "UFW rules added."
                fi
                ;;
            iptables)
                echo "IPTables configuration not implemented."
                ;;
            firewalld)
                if command -v firewall-cmd >/dev/null; then
                    if [ "$is_firewall_enabled" == "y" ] && [ "$get_firewall_status" == "y" ]; then
                        sftc="ste"
                        add_Valheim_server_public_ports
                    fi
                fi
                ;;
            *)
                echo "Unsupported firewall configuration."
                ;;
        esac
    else
        # Disable detected firewall services when firewall management is off.
        [ "${is_firewall_enabled}" == "y" ] && disable_all_firewalls
    fi

    tput setaf 2; echo "$ECHO_DONE"; tput setaf 9;
    sleep 1

    # Build symbolic link for steamcmd.
    tput setaf 1; echo "$INSTALL_BUILD_SYM_LINK_STEAMCMD"; tput setaf 9;

    if command -v apt-get >/dev/null; then
        # Ubuntu: SteamCMD is installed under /usr/games/.
        echo "Creating symbolic link."
		ln -sf /usr/games/steamcmd /home/steam/steamcmd
    else
        # Fedora/RHEL: SteamCMD runs from its downloaded directory.
        echo "Symbolic link not required for other Linux systems."
    fi

    tput setaf 2; echo "$ECHO_DONE"; tput setaf 9;
    sleep 1
}

########################################################################
#####################Manager Valheim Server END#########################
########################################################################
########################################################################
##########BACKUP AND RESTORE WORLD DATA SECTION START###################
########################################################################

#Backup World DB and FWL Files
function backup_world_data() {
    echo ""
    echo ""

    # Request confirmation before stopping the server.
    tput setaf 1; echo "$BACKUP_WORLD_DATA_HEADER"; tput setaf 9;
    tput setaf 1; echo "$BACKUP_WORLD_INFO_CONFIRM"; tput setaf 9;
    read -p "$BACKUP_WORLD_INPUT_CONFIRM_Y_N" confirmBackup

    ## Continue only after confirmation.
    if [ "$confirmBackup" == "y" ]; then
        # Use the current date and time in the backup filename.
        TODAY=$(date +%Y-%m-%d-%T)

        tput setaf 5; echo "$BACKUP_WORLD_CHECK_DIRECTORY"; tput setaf 9;
        tput setaf 5; echo "$BACKUP_WORLD_CHECK_DIRECTORY_1"; tput setaf 9;
        dldir="$backupPath/$worldname"
        [ ! -d "$dldir" ] && mkdir -p "$dldir"
        sleep 1

        # Remove backup files older than fourteen days.
        tput setaf 1; echo "$BACKUP_WORLD_CONDUCT_CLEANING"; tput setaf 9;
        find "$backupPath/$worldname/"* -mtime +14 -type f -delete
        tput setaf 2; echo "$BACKUP_WORLD_CONDUCT_CLEANING_LOKI"; tput setaf 9;
        sleep 1

        # Stop the server before copying live save data.
        tput setaf 1; echo "$BACKUP_WORLD_STOPPING_SERVICES"; tput setaf 9;
        systemctl stop valheimserver_${worldname}.service
        tput setaf 1; echo "$BACKUP_WORLD_STOP_INFO"; tput setaf 9;
        tput setaf 2; echo "$BACKUP_WORLD_STOP_INFO_1"; tput setaf 9;
        tput setaf 2; echo "$BACKUP_WORLD_STOP_WAIT_10_SEC"; tput setaf 9;
        sleep 10

        # Archive the world save directory.
        tput setaf 1; echo "$BACKUP_WORLD_MAKING_TAR"; tput setaf 9;
        tar czf "$backupPath/$worldname/valheim-backup-$TODAY.tgz" "$worldpath/$worldname/"*
        tput setaf 2; echo "$BACKUP_WORLD_MAKING_TAR_COMPLETE"; tput setaf 9;
        sleep 1

        # Restart the server after the backup completes.
        tput setaf 2; echo "$BACKUP_WORLD_RESTARTING_SERVICES"; tput setaf 9;
        systemctl start valheimserver_${worldname}.service
        tput setaf 2; echo "$BACKUP_WORLD_RESTARTING_SERVICES_1"; tput setaf 9;
        echo ""

        # Return backup ownership to the steam account.
        tput setaf 2; echo "$BACKUP_WORLD_SET_PERMS_FILES"; tput setaf 9;
        chown -Rf steam:steam "$backupPath/$worldname"
        tput setaf 2; echo "$BACKUP_WORLD_PROCESS_COMPLETE"; tput setaf 9;
        echo ""
    else
        tput setaf 3; echo "$BACKUP_WORLD_PROCESS_CANCELED"; tput setaf 9;
    fi
}


# Restore a selected compressed world backup.
# Thanks to GITHUB @LachlanMac and @Kurt
function restore_world_data() {
    # Initialize empty array
    declare -a backups

    # Load available backups into the selection array.
    for file in "${backupPath}/${worldname}"/*.tgz; do
        backups+=("$file")
    done

    # Display the available backup files.
    bIndex=1
    for item in "${backups[@]}"; do
        basefile=$(basename "$item")
        echo "$bIndex> $basefile"
        bIndex=$((bIndex + 1))
    done

    # Request the backup selection.
    tput setaf 2; echo "$RESTORE_WORLD_DATA_HEADER"; tput setaf 9;
    tput setaf 2; echo "$RESTORE_WORLD_DATA_CONFIRM"; tput setaf 9;
    read -p "$RESTORE_WORLD_DATA_SELECTION" selectedIndex

    # Confirm the selected backup before restoring it.
    restorefile=$(basename "${backups[selectedIndex - 1]}")
    echo -ne "
$(ColorRed '------------------------------------------------------------')
$(ColorGreen ' '"$RESTORE_WORLD_DATA_SHOW_FILE"' $restorefile ?')
$(ColorGreen ' '"$RESTORE_WORLD_DATA_ARE_YOU_SURE"' ')
$(ColorOrange ' '"$RESTORE_WORLD_DATA_VALIDATE_DATA_WITH_CONFIG"' ${valheimInstallPath}/${worldname}/start_valheim_${worldname}.sh')
$(ColorOrange ' '"$RESTORE_WORLD_DATA_INFO"' ')
$(ColorGreen ' '"$RESTORE_WORLD_DATA_CONFIRM_1"' ') "

    # Read user input confirmation
    read -p "" confirmBackupRestore

    # Stop the service and restore the selected archive.
    if [ "$confirmBackupRestore" == "y" ]; then
        # Stop Valheim server
        tput setaf 1; echo "$RESTORE_WORLD_DATA_STOP_VALHEIM_SERVICE"; tput setaf 9;
        systemctl stop valheimserver_${worldname}.service
        tput setaf 2; echo "$RESTORE_WORLD_DATA_STOP_VALHEIM_SERVICE_1"; tput setaf 9;
        sleep 5

        # Copy the selected archive into the world save directory.
        tput setaf 2; echo "$RESTORE_WORLD_DATA_COPYING ${backups[selectedIndex - 1]} to ${worldpath}/${worldname}/"; tput setaf 9;
        cp "${backups[selectedIndex - 1]}" "${worldpath}/${worldname}/"

        # Extract the backup and restore file ownership.
        tput setaf 2; echo "$RESTORE_WORLD_DATA_UNPACKING ${worldpath}/${restorefile}"; tput setaf 9;
        tar xzf "${worldpath}/${worldname}/${restorefile}" --strip-components=7 --directory "${worldpath}/${worldname}/"
        chown -Rf steam:steam "${worldpath}/${worldname}/"
        rm "${worldpath}/${worldname}"/*.tgz

        # Start the restored world service.
        tput setaf 2; echo "$RESTORE_WORLD_DATA_STARTING_VALHEIM_SERVICES"; tput setaf 9;
        tput setaf 2; echo "$RESTORE_WORLD_DATA_CUSS_LOKI"; tput setaf 9;
        systemctl start valheimserver_${worldname}.service
    else
        tput setaf 2; echo "$RESTORE_WORLD_DATA_CANCEL_CUSS_LOKI"; tput setaf 9;
    fi
}

########################################################################
##########BACKUP AND RESTORE WORLD DATA SECTION END#####################
##########=========================================#####################
##########       VALHEIM UPDATE SECTION START      #####################
########################################################################

# Install or update the official Valheim server files.
function nocheck_valheim_update_install() {
    # Set Steam executable and update/install Valheim.
    tput setaf 1; echo "$INSTALL_BUILD_DOWNLOAD_INSTALL_STEAM_VALHEIM"; tput setaf 9;
    sleep 1

    # Execute the SteamCMD update.
    $steamexe +login anonymous +force_install_dir "${valheimInstallPath}/${worldname}" +app_update 896660 validate +exit +quit 2>/dev/null
    
    tput setaf 2; echo "$ECHO_DONE"; tput setaf 9;
}

# Apply a confirmed official Valheim update.
function continue_with_valheim_update_install() {
    clear
    echo ""
    echo -ne "
$(ColorOrange "$FUNCTION_INSTALL_VALHEIM_UPDATES")
$(ColorRed "$DRAW60")"
    echo ""
    tput setaf 2; echo "$FUNCTION_INSTALL_VALHEIM_FOUND"; tput setaf 9;
    tput setaf 2; echo "$FUNCTION_INSTALL_VALHEIM_UPDATE_INFO"; tput setaf 9;
    tput setaf 2; echo "$FUNCTION_INSTALL_VALHEIM_UPDATE_CONFIRM"; tput setaf 9;
    echo -ne "
$(ColorRed "$DRAW60")"
    echo ""
    read -p "$PLEASE_CONFIRM" confirmOfficialUpdates

    # Apply the update only after confirmation.
    if [ "$confirmOfficialUpdates" == "y" ]; then
        tput setaf 2; echo "$FUNCTION_INSTALL_VALHEIM_UPDATE_APPLY_INFO"; tput setaf 9;
        $steamexe +login anonymous +force_install_dir "${valheimInstallPath}/${worldname}" +app_update 896660 validate +exit 2>/dev/null
        chown -Rf steam:steam "${valheimInstallPath}/${worldname}"
        echo ""
    else
        tput setaf 2; echo "$FUNCTION_INSTALL_VALHEIM_UPDATES_CANCEL"; tput setaf 9;
        sleep 3
        clear
    fi
}

 Compare the official and local Valheim build identifiers.
function check_apply_server_updates_beta() {
	### beta function
    echo ""
    echo "Downloading Official Valheim Repo Log Data for comparison only"

    # Remove cached Steam application data before checking the repository.
    find "/home" "/root" -wholename "*/.steam/appcache/appinfo.vdf" -exec rm -f {} +

    # Read the current official build identifier.
    #repoValheim=$($steamexe +login anonymous +app_info_update 1 +app_info_print 896660 +quit | grep -A10 branches | grep -A2 public | grep buildid | cut -d'"' -f4)
     repoValheim=$($steamexe +login anonymous +app_info_update 1 +app_info_print 896660 +quit 2>/dev/null | grep -A10 branches | grep -A2 public | grep buildid | cut -d'"' -f4)
    echo "Official Valheim: $repoValheim"

    # Read the locally installed build identifier.
    localValheim=$(grep buildid "${valheimInstallPath}/${worldname}/steamapps/appmanifest_896660.acf" | cut -d'"' -f4)
    echo "Local Valheim Ver: $localValheim"

    # Update and restart the service when versions differ.
	if [ "$repoValheim" == "$localValheim" ]; then
        echo "No new updates found"
        sleep 2
    else
        echo "Update found, initiating update process!"
        sleep 2
        continue_with_valheim_update_install
        systemctl restart valheimserver_${worldname}.service
        echo ""
    fi

    echo ""
}

# Confirm before checking for and applying server updates.
function confirm_check_apply_server_updates() {
    while true; do
        echo -ne "
$(ColorRed "$DRAW60")"
        echo ""
        tput setaf 2; echo "$FUNCTION_CONFIRM_CHECK_APPLY_SERVER_UPDATES_INFO"; tput setaf 9;
        tput setaf 2; echo "$FUNCTION_CONFIRM_CHECK_APPLY_SERVER_UPDATES_INFO_1"; tput setaf 9;
        tput setaf 2; echo "$FUNCTION_CONFIRM_CHECK_APPLY_SERVER_UPDATES_INFO_2"; tput setaf 9;
        tput setaf 2; echo "$PLEASE_CONFIRM"; tput setaf 9;
        echo -ne "
$(ColorRed "------------------------------------------------------------")"
        echo ""
        tput setaf 2; read -p "$FUNCTION_CONFIRM_CHECK_APPLY_SERVER_UPDATES_CONTINUE" yn; tput setaf 9;
        echo -ne "
$(ColorRed "------------------------------------------------------------")"

        case $yn in
            [Yy]* )
                check_apply_server_updates_beta
                break
                ;;
            [Nn]* )
                break
                ;;
            * )
                echo "$PLEASE_CONFIRM"
                ;;
        esac
    done
}

# Stop Valheim Server Service
function stop_valheim_server() {
    clear
    echo ""
    echo -ne "
$(ColorOrange "$FUNCTION_STOP_VALHEIM_SERVER_SERVICE_HEADER")
$(ColorRed "$DRAW60")"
    echo ""
    tput setaf 2; echo "$FUNCTION_STOP_VALHEIM_SERVER_SERVICE_INFO"; tput setaf 9;
    tput setaf 2; echo "$FUNCTION_STOP_VALHEIM_SERVER_SERVICE_INFO_1"; tput setaf 9;
    echo -ne "
$(ColorRed "$DRAW60")"
    echo ""
    read -p "$PLEASE_CONFIRM" confirmStop

    # If 'y', then continue, else cancel
    if [ "$confirmStop" == "y" ]; then
        echo ""
        echo "$FUNCTION_STOP_VALHEIM_SERVER_SERVICE_STOPPING"
        sudo systemctl stop valheimserver_${worldname}.service
        echo ""
    else
        echo "$FUNCTION_STOP_VALHEIM_SERVER_SERVICE_CANCEL"
        sleep 3
        clear
    fi
}

# Start Valheim Server Service
function start_valheim_server() {
    clear
    echo ""
    echo -ne "
$(ColorOrange ''"$FUNCTION_START_VALHEIM_SERVER_SERVICE_HEADER"'')
$(ColorRed ''"$DRAW60"'')"
	echo ""
	tput setaf 2; echo "$FUNCTION_START_VALHEIM_SERVER_SERVICE_INFO" ; tput setaf 9;
	tput setaf 2; echo "$FUNCTION_START_VALHEIM_SERVER_SERVICE_INFO_1" ; tput setaf 9;
	echo -ne "
$(ColorRed ''"$DRAW60"'')"
	echo ""
		read -p "$PLEASE_CONFIRM" confirmStart
	#if y, then continue, else cancel
    if [ "$confirmStart" == "y" ]; then
		echo ""
		tput setaf 2; echo "$FUNCTION_START_VALHEIM_SERVER_SERVICE_START" ; tput setaf 9;
		sudo systemctl start valheimserver_${worldname}.service
		echo ""
    else
		echo "$FUNCTION_START_VALHEIM_SERVER_SERVICE_CANCEL"
        sleep 3
		clear
	fi
}

# Restart Valheim Server Service
function restart_valheim_server() {
    clear
    echo ""
    echo -ne "
$(ColorOrange ''"$FUNCTION_RESTART_VALHEIM_SERVICE_SERVICE_HEADER"'')
$(ColorRed ''"$DRAW60"'')"
	echo ""
	tput setaf 2; echo "$FUNCTION_RESTART_VALHEIM_SERVICE_SERVICE_INFO" ; tput setaf 9;
	tput setaf 2; echo "$FUNCTION_RESTART_VALHEIM_SERVICE_SERVICE_INF0_1" ; tput setaf 9;
	echo -ne "
$(ColorRed ''"$DRAW60"'')"
	echo ""
		read -p "$PLEASE_CONFIRM" confirmRestart
	#if y, then continue, else cancel
    if [ "$confirmRestart" == "y" ]; then
		tput setaf 2; echo "$FUNCTION_RESTART_VALHEIM_SERVICE_SERVICE_RESTART" ; tput setaf 9;
		sudo systemctl restart valheimserver_${worldname}.service
		echo ""
    else
        echo "$FUNCTION_RESTART_VALHEIM_SERVICE_SERVICE_CANCEL"
        sleep 3
		clear
	fi
}

# Display Valheim Server Status
function display_valheim_server_status() {
    echo ""
    sudo systemctl status --no-pager -l valheimserver_${worldname}.service
    echo ""
    echo "Returning to menu in 5 Seconds"
    sleep 5
}

########################################################################
##############      VALHEIM UPDATE SECTION END       ###################
##############=======================================###################
##############Valheim Server Information output START###################
########################################################################

# Display Valheim Vanilla Configuration File
function display_start_valheim() {
    echo ""
    sudo cat ${valheimInstallPath}/${worldname}/start_valheim_${worldname}.sh
    echo ""
    echo "Returning to menu in 5 Seconds"
    sleep 5
}

# Display Valheim World Data Folder
function display_world_data_folder() {
    echo ""
    sudo ls -lisa $worldpath/$worldname/worlds
    echo ""
    echo "Returning to menu in 5 Seconds"
    sleep 5
}

# Print System INFOS
function display_system_info() {
    echo ""
    echo -e "$DRAW80"
    echo -e "$FUNCTION_DISPLAY_SYSTEM_INFO_HEADER"
    echo -e "$FUNCTION_DISPLAY_SYSTEM_INFO_HOSTNAME $(hostname)"
    echo -e "$FUNCTION_DISPLAY_SYSTEM_INFO_UPTIME $(uptime -p)"
    echo -e "$FUNCTION_DISPLAY_SYSTEM_INFO_MANUFACTURER $(cat /sys/class/dmi/id/chassis_vendor)"
    echo -e "$FUNCTION_DISPLAY_SYSTEM_INFO_PRODUCT_NAME $(cat /sys/class/dmi/id/product_name)"
    echo -e "$FUNCTION_DISPLAY_SYSTEM_INFO_VERSION $(cat /sys/class/dmi/id/product_version)"
    echo -e "$FUNCTION_DISPLAY_SYSTEM_INFO_SERIAL_NUMBER $(cat /sys/class/dmi/id/product_serial)"
    echo -e "$FUNCTION_DISPLAY_SYSTEM_INFO_MACHINE_TYPE $(if lscpu | grep -q Hypervisor; then echo "VM"; else echo "Physical"; fi)"
    echo -e "$FUNCTION_DISPLAY_SYSTEM_INFO_OPERATION_SYSTEM $(hostnamectl | grep "Operating System" | cut -d ' ' -f5-)"
    echo -e "$FUNCTION_DISPLAY_SYSTEM_INFO_KERNEL $(uname -r)"
    echo -e "$FUNCTION_DISPLAY_SYSTEM_INFO_ARCHITECTURE $(arch)"
    echo -e "$FUNCTION_DISPLAY_SYSTEM_INFO_PROCESSOR_NAME $(awk -F':' '/^model name/ {print $2}' /proc/cpuinfo | uniq | sed -e 's/^[ \t]*//')"
    echo -e "$FUNCTION_DISPLAY_SYSTEM_INFO_ACTIVE_USER $(w -h | awk '{print $1}' | sort | uniq)"
    echo -e "$FUNCTION_DISPLAY_SYSTEM_INFO_SYSTEM_MAIN_IP $(hostname -I | awk '{print $1}')"
    echo ""
    echo -e "$FUNCTION_DISPLAY_SYSTEM_INFO_CPU_MEM_HEADER"
    echo -e "$FUNCTION_DISPLAY_SYSTEM_INFO_MEMORY_USAGE $(free | awk '/Mem/{printf("%.2f %%"), $3/$2*100}')"
    echo -e "$FUNCTION_DISPLAY_SYSTEM_INFO_CPU_USAGE $(awk -v sum=0 -v idle=0 '{if ($1 ~ /^cpu/) {sum += $2+$3+$4+$5+$6+$7+$8; idle += $5}} END {printf("%.2f %%\n"), (sum-idle)*100/sum}' /proc/stat)"
    echo ""
    echo -e "$FUNCTION_DISPLAY_SYSTEM_INFO_DISK_HEADER"
    df -Ph | awk '$5+0 > 80'
    echo -e "$DRAW80"
    echo ""
    echo "Returning to menu in 5 seconds"
    sleep 5
}


# PRINT NETWORK INFO
function display_network_info() {
    echo ""
    sudo netstat -atunp | grep valheim
    echo ""
    echo "Returning to menu in 5 Seconds"
    sleep 5
}

# Display History of Connected Players
function display_player_history() {
    echo ""
    grep ZDOID ${worldpath}/${worldname}/valheim_server.log
    grep *HAND* ${worldpath}/${worldname}/valheim_server.log
    echo ""
    echo "Returning to menu in 5 Seconds"
    sleep 5
}
function get_worldseed() {
    # Extract the world seed from the .fwl file
    worldseed=$(hexdump -s 9 -n 10 -e '2/1 "%02x"' "${worldpath}/${worldname}/worlds_local/${worldname}.fwl" | tr -d ' ')

    echo ""
    echo -e '\E[32m'"$worldseed"
    echo ""
    echo "Returning to menu in 5 seconds - This might not be working 100% still testing"
    sleep 5
}

########################################################################
###############VALHEIM SERVER INFORMATION SECTION END###################
###############======================================###################
###############    FIREWALL CONTROL SECTION START    ###################
########################################################################

# Report whether the selected firewall utility is installed.
function is_admin_firewall_installed() {
    if command -v "$fwbeingused" >/dev/null; then
        is_admin_firewall_installed=y
    else
        is_admin_firewall_installed=n
    fi
    echo -e '\E[32m'"$is_admin_firewall_installed"
}

# Report which supported firewall utilities are installed.
function is_any_firewall_installed() {
    fwiufw=n; fwifwd=n; fwiipt=n; fwiipt6=n; fwiebt=n

    if command -v ufw >/dev/null; then
        fwiufw=y
        echo -ne "\n$(ColorOrange "Uncomplicated Firewall (ufw) is installed.")"
    fi
    if command -v firewall-cmd >/dev/null; then
        fwifwd=y
        echo -ne "\n$(ColorOrange "FireWALLD is installed.")"
    fi
    if command -v iptables >/dev/null; then
        fwiipt=y
        echo -ne "\n$(ColorOrange "IPTables is installed.")"
    fi
    if command -v ip6tables >/dev/null; then
        fwiipt6=y
        echo -ne "\n$(ColorOrange "IP6Tables is installed.")"
    fi
    if command -v ebtables >/dev/null; then
        fwiebt=y
        echo -ne "\n$(ColorOrange "EBTables is installed.")"
    fi

    if [[ "$fwiufw" == "y" || "$fwifwd" == "y" || "$fwiipt" == "y" || "$fwiipt6" == "y" || "$fwiebt" == "y" ]]; then
        is_any_firewall_installed=y
    else
        is_any_firewall_installed=n
    fi
}

# Report whether the selected firewall is enabled.
function is_admin_firewall_enabled(){
    if command -v "${fwbeingused}" >/dev/null; then
        is_admin_firewall_enabled=$(systemctl is-enabled "$fwbeingused" 2>/dev/null)
    else
        is_admin_firewall_enabled="not-installed"
    fi
    echo -e '\E[32m'"$is_admin_firewall_enabled "
}

# Report whether any supported firewall service is enabled.
function is_any_firewall_enabled() {
    local fwearp=n fweebt=n fwefwd=n fweipt=n fweipt6=n fweufw=n

    command -v arptables >/dev/null && systemctl is-enabled arptables >/dev/null 2>&1 && fwearp=y
    command -v ebtables >/dev/null && systemctl is-enabled ebtables >/dev/null 2>&1 && fweebt=y
    command -v firewall-cmd >/dev/null && systemctl is-enabled firewalld >/dev/null 2>&1 && fwefwd=y
    command -v iptables >/dev/null && systemctl is-enabled iptables >/dev/null 2>&1 && fweipt=y
    command -v ip6tables >/dev/null && systemctl is-enabled ip6tables >/dev/null 2>&1 && fweipt6=y
    command -v ufw >/dev/null && systemctl is-enabled ufw >/dev/null 2>&1 && fweufw=y

    if [[ "$fwearp" == "y" || "$fweebt" == "y" || "$fwefwd" == "y" || "$fweipt" == "y" || "$fweipt6" == "y" || "$fweufw" == "y" ]]; then
        is_any_firewall_enabled="y"
        echo -ne "\n$(ColorOrange "Firewall(s) Enabled: -- UFW: ${fweufw} -- Firewalld: ${fwefwd} -- Iptables: ${fweipt} -- Ip6tables: ${fweipt6} -- ARPTables: ${fwearp} -- EBTables: ${fweebt}")"
    else
        is_any_firewall_enabled="n"
        echo -ne "\n$(ColorOrange "No Firewall enabled.")"
    fi
}

# Return the active state of the selected firewall.
function get_firewall_status() {
    if [ "$usefw" == "y" ]; then
        local check_enabled
        check_enabled=$(systemctl is-enabled "$fwbeingused" 2>/dev/null)
        if [ "$check_enabled" == "enabled" ]; then
            get_firewall_status=$(systemctl is-active "$fwbeingused" 2>/dev/null)
        else
            get_firewall_status="NotEnabled"
        fi
    else
        get_firewall_status="NoFWAdmin"
    fi
    echo -e '\E[32m'"$get_firewall_status"
}

# Return the systemd substate of the selected firewall.
function get_firewall_substate(){
    if [ "${usefw}" == "y" ] ; then
        local check_enabled
        check_enabled=$(systemctl is-enabled "$fwbeingused" 2>/dev/null)
        if [ "$check_enabled" == "enabled" ] ; then
            if command -v "$fwbeingused" >/dev/null; then
                get_firewall_substate=$(systemctl show -p SubState "$fwbeingused" | cut -d= -f2)
            else
                get_firewall_substate="Error"
            fi
        else
            get_firewall_substate="NotEnabled"
        fi
    else
        get_firewall_substate="NoFWAdmin"
    fi
    echo -e '\E[32m'"$get_firewall_substate "
}

# Display detailed information from the selected firewall backend.
function get_firewall_moreinfo(){
    if [ "${usefw}" == "y" ] ; then
        if [ "${fwbeingused}" == "firewalld" ] ; then
            if command -v firewall-cmd >/dev/null; then
                echo "--- Raw Firewalld Global Core State ---"
                firewall-cmd --state
                echo "Default Zone: $(firewall-cmd --get-default-zone)"
                echo "Active Zones: $(firewall-cmd --get-active-zones)"
                echo "Allowed Rules layout on Public Target:"
                sudo firewall-cmd --zone=public --permanent --list-all
                get_firewall_moreinfo="Success"
            fi
        elif [ "${fwbeingused}" == "ufw" ] ; then
            if command -v ufw >/dev/null; then
                sudo ufw status verbose
                get_firewall_moreinfo="Success"
            fi
        else
            get_firewall_moreinfo="Firewall mapping info display not implemented for ${fwbeingused}."
        fi
    else
        get_firewall_moreinfo="Firewall Admin not enabled."
    fi
    echo -e '\E[32m'"$get_firewall_moreinfo "
    echo "Press Enter to return to the menu..." && read -r
}

# Check whether the current Valheim port range is already allowed.
function is_port_added_firewall(){
    is_port_added_firewall="n"
    # Use currentPort when available, otherwise use portnumber.
    local target_port="${currentPort:-$portnumber}"
    [ -z "$target_port" ] && target_port=2456
    local port_max=$((target_port + 2))

    if command -v "${fwbeingused}" >/dev/null; then
        if [ "${fwbeingused}" == "firewalld" ] ; then
            local portlistarray
            portlistarray=$(sudo firewall-cmd --zone=public --permanent --list-ports)
            if [[ "$portlistarray" == *"${target_port}-${port_max}/udp"* ]]; then
                is_port_added_firewall="y"
            else
                is_port_added_firewall="n"
            fi
        elif [ "${fwbeingused}" == "ufw" ]; then
            if sudo ufw status | grep -q "${target_port}/udp"; then
                is_port_added_firewall="y"
            else
                is_port_added_firewall="n"
            fi
        else
            is_port_added_firewall="Unsupported-FW"
        fi
    else
        is_port_added_firewall="Not-Installed"
    fi
    echo -e '\E[32m'"$is_port_added_firewall "
}

# Enable and start the configured firewall service.
function enable_prefered_firewall(){
    if command -v "${fwbeingused}" >/dev/null; then
        sudo systemctl unmask "${fwbeingused}" 2>/dev/null
        sudo systemctl enable "${fwbeingused}"
        sudo systemctl start "${fwbeingused}"
        enable_prefered_firewall="Completed"
    else
        enable_prefered_firewall="Firewall Admin not enabled."
    fi
    echo -e '\E[32m'"$enable_prefered_firewall "
    sleep 2
}

# Stop and disable all known firewall services.
function disable_all_firewalls(){
    for fws in "${fwsystems[@]}"
    do
        if command -v "$fws" >/dev/null; then
            echo "Stopping and disabling $fws..."
            sudo systemctl stop "$fws" 2>/dev/null
            sudo systemctl disable "$fws" 2>/dev/null
        fi
    done
    disable_all_firewalls="All known Firewall systems disabled."
    echo -e '\E[32m'"$disable_all_firewalls "
    sleep 2
}

# Add SteamCMD or Valheim ports to the selected firewall.
function add_Valheim_server_public_ports(){
    if [ "${usefw}" == "y" ] ; then
        local target_port="${currentPort:-$portnumber}"
        [ -z "$target_port" ] && target_port=2456
        local port_max=$((target_port + 2))

        if [ "${fwbeingused}" == "firewalld" ] ; then
            if [ "$sftc" == "ste" ] ; then
                echo "Injecting SteamCMD Network Rules into Firewalld Zone Profiles..."
                sudo firewall-cmd --zone=public --permanent --add-port={1200/udp,27000-27015/udp,27020/udp,27015-27016/tcp,27030-27039/tcp}
            elif [ "$sftc" == "val" ] ; then
                echo "Injecting Valheim [${worldname}] Base Port Rules (${target_port}-${port_max}/udp) into Firewalld..."
                sudo firewall-cmd --zone=public --permanent --add-port=${target_port}-${port_max}/udp
            fi
            sudo firewall-cmd --reload
            echo "Current allowed ports:"
            sudo firewall-cmd --zone=public --permanent --list-ports
        elif [ "${fwbeingused}" == "ufw" ]; then
            if [ "$sftc" == "ste" ] ; then
                echo "Injecting SteamCMD Network Rules into UFW Rules Layout..."
                sudo ufw allow 1200/udp
                sudo ufw allow 27020/udp
                sudo ufw allow 27000:27015/udp
                sudo ufw allow 27015:27016/tcp
                sudo ufw allow 27030:27039/tcp
            elif [ "$sftc" == "val" ] ; then
                echo "Injecting Valheim [${worldname}] Base Port Rules (${target_port}:${port_max}/udp) into UFW..."
                sudo ufw allow ${target_port}:${port_max}/udp
            fi
            sudo ufw reload 2>/dev/null
            sudo ufw status concise
        fi
    fi
    echo "Press Enter to continue..." && read -r
}

# Remove SteamCMD or Valheim ports from the selected firewall.
function remove_Valheim_server_public_ports(){
    if [ "${usefw}" == "y" ] ; then
        local target_port="${currentPort:-$portnumber}"
        [ -z "$target_port" ] && target_port=2456
        local port_max=$((target_port + 2))

        if [ "${fwbeingused}" == "firewalld" ] ; then
            if [ "$sftc" == "ste" ] ; then
                echo "Purging SteamCMD Rules from Firewalld Zone Profiles..."
                sudo firewall-cmd --zone=public --permanent --remove-port={1200/udp,27000-27015/udp,27020/udp,27015-27016/tcp,27030-27039/tcp}
            elif [ "$sftc" == "val" ] ; then
                echo "Purging Valheim [${worldname}] Ports (${target_port}-${port_max}/udp) from Firewalld..."
                sudo firewall-cmd --zone=public --permanent --remove-port=${target_port}-${port_max}/udp
            fi
            sudo firewall-cmd --reload
            sudo firewall-cmd --zone=public --permanent --list-ports
        elif [ "${fwbeingused}" == "ufw" ]; then
            if [ "$sftc" == "ste" ] ; then
                echo "Purging SteamCMD Rules from UFW Layout Profiles..."
                sudo ufw delete allow 1200/udp
                sudo ufw delete allow 27020/udp
               sudo ufw delete allow 27000:27015/udp
                sudo ufw delete allow 27015:27016/tcp
                sudo ufw delete allow 27030:27039/tcp
            elif [ "$sftc" == "val" ] ; then
                sudo ufw delete allow ${target_port}:${port_max}/udp
            fi
            sudo ufw reload 2>/dev/null
        fi
    fi
    echo "Press Enter to continue..." && read -r
}

# Create a Firewalld service XML profile for SteamCMD or Valheim.
function create_firewalld_service_file(){
    if [ "${usefw}" == "y" ] && [ "${fwbeingused}" == "firewalld" ] ; then
        local target_port="${currentPort:-$portnumber}"
        [ -z "$target_port" ] && target_port=2456
        local port_max=$((target_port + 2))
        local checkfile

        if [ "$sftc" == "ste" ] ; then
            checkfile=/etc/firewalld/services/steam.xml
            if [ -f "$checkfile" ] ; then
                echo "Steam XML configuration profile exists."
            else
                sudo cat <<EOF > "$checkfile"
<?xml version="1.0" encoding="utf-8"?>
<service>
  <short>Steam service</short>
  <description>These are the ports needed for Steam and Steamcmd</description>
  <port protocol="udp" port="1200"/>
  <port protocol="udp" port="27000-27015"/>
  <port protocol="udp" port="27020"/>
  <port protocol="tcp" port="27015-27016"/>
  <port protocol="tcp" port="27030-27039"/>
</service>
EOF
            fi
        elif [ "$sftc" == "val" ] ; then
            checkfile=/etc/firewalld/services/valheimserver-${worldname}.xml
            if [ -f "$checkfile" ] ; then
                echo "Valheim World XML configuration profile exists."
            else
                sudo cat <<EOF > "$checkfile"
<?xml version="1.0" encoding="utf-8"?>
<service>
   <short>Valheim ${worldname} Server</short>
   <description>Valheim ${worldname} game server ports</description>
   <port protocol="udp" port="${target_port}-${port_max}"/>
 </service>
EOF
            fi
        fi
        sudo firewall-cmd --reload
        [ -f "$checkfile" ] && cat "$checkfile"
    else
        echo "This action requires Firewalld to be explicitly enabled."
    fi
    echo "Press Enter to continue..." && read -r
}

# Delete a Firewalld service XML profile.
function delete_firewalld_service_file(){
    if [ "${usefw}" == "y" ] && [ "${fwbeingused}" == "firewalld" ] ; then
        local checkfile
        if [ "$sftc" == "ste" ] ; then
            checkfile=/etc/firewalld/services/steam.xml
        elif [ "$sftc" == "val" ] ; then
            checkfile=/etc/firewalld/services/valheimserver-${worldname}.xml
        fi
        if [ -f "$checkfile" ] ; then
            sudo rm -f "$checkfile"
            echo "Deleted $checkfile successfully."
        else
            echo "File does not exist."
        fi
        sudo firewall-cmd --reload
    else
        echo "This action requires Firewalld to be explicitly enabled."
    fi
    echo "Press Enter to continue..." && read -r
}

# Add a Firewalld service profile to the public zone.
function add_firewalld_public_service(){
    if [ "${usefw}" == "y" ] && [ "${fwbeingused}" == "firewalld" ] ; then
        if [ "$sftc" == "ste" ] ; then
            sudo firewall-cmd --zone=public --permanent --add-service=steam
        elif [ "$sftc" == "val" ] ; then
            sudo firewall-cmd --zone=public --permanent --add-service=valheimserver-${worldname}
        fi
        sudo firewall-cmd --reload
        sudo firewall-cmd --zone=public --permanent --list-services
    else
        echo "This action requires Firewalld to be explicitly enabled."
    fi
    echo "Press Enter to continue..." && read -r
}

# Remove a Firewalld service profile from the public zone.
function remove_firewalld_public_service(){
    if [ "${usefw}" == "y" ] && [ "${fwbeingused}" == "firewalld" ] ; then
        if [ "$sftc" == "ste" ] ; then
            sudo firewall-cmd --zone=public --permanent --remove-service=steam
        elif [ "$sftc" == "val" ] ; then
            sudo firewall-cmd --zone=public --permanent --remove-service=valheimserver-${worldname}
        fi
        sudo firewall-cmd --reload
        sudo firewall-cmd --zone=public --permanent --list-services
    else
        echo "This action requires Firewalld to be explicitly enabled."
    fi
    echo "Press Enter to continue..." && read -r
}

# Placeholder for adding entries to /etc/services.
function add_to_etc_services_file(){
    echo "Feature placeholder text only."
}

########################################################################
##########         FIREWALL CONTROL SECTION END           ##############
##########================================================##############
##########    MAIN VALHEIM SERVER ADMIN FUNCTIONS END     ##############
##########================================================##############
##########  VALHEIM SERVER SERVICE CONTROL SECTION START  ##############
########################################################################

# Read the active world's startup configuration.
function get_current_config() {
    if [ -f "$worldfilelist" ]; then
        readarray -t worldlistarray < "$worldfilelist"
    else
        unset worldlistarray
    fi

	# Select the active world and SteamCMD executable.
    set_world_server
    set_steamexe

    configfile="${valheimInstallPath}/${worldname}/start_valheim_${worldname}.sh"

    # Extract current server values from the startup script.
	currentDisplayName=$(perl -n -e '/\-name "?([^"]+)"? \-port/ && print "$1\n"' "$configfile")
    currentPort=$(perl -n -e '/\-port "?([^"]+)"? \-nographics/ && print "$1\n"' "$configfile")
    currentWorldName=$(perl -n -e '/\-world "?([^"]+)"? \-password/ && print "$1\n"' "$configfile")
    currentPassword=$(perl -n -e '/\-password "?([^"]+)"? \-public/ && print "$1\n"' "$configfile")
    currentPublicSet=$(perl -n -e '/\-public "?([^"]+)"? \-savedir/ && print "$1\n"' "$configfile")
    currentSaveDir=$(perl -n -e '/\-savedir "?([^"]+)"? \-logfile/ && print "$1\n"' "$configfile")
    currentLogfileDir=$(perl -n -e '/\-logfile "?([^"]+)"? \-crossplay/ && print "$1\n"' "$configfile")
    currentCrossplayStatus=$(perl -n -e '/\-crossplay "?([^"]+)"?$/ && print "$1\n"' "$configfile")
}

# Display the currently loaded server configuration.
function print_current_config() {
    echo -e "$FUNCTION_PRINT_CURRENT_CONFIG_PUBLIC_NAME $(tput setaf 2)${currentDisplayName}$(tput setaf 9)"
    echo -e "$FUNCTION_PRINT_CURRENT_CONFIG_PORT $(tput setaf 2)${currentPort}$(tput setaf 9)"
    echo -e "$FUNCTION_PRINT_CURRENT_CONFIG_LOCAL_WORLD_NAME $(tput setaf 2)${currentWorldName}$(tput setaf 9)"
    echo -e "$FUNCTION_PRINT_CURRENT_CONFIG_LOCAL_WORLD_NAME_INFO"
    echo -e "$FUNCTION_PRINT_CURRENT_CONFIG_ACCESS_PASSWORD $(tput setaf 2)${currentPassword}$(tput setaf 9)"
    echo -e "$FUNCTION_PRINT_CURRENT_CONFIG_PUBLIC_LISTING $(tput setaf 2)${currentPublicSet}$(tput setaf 9)"
    echo -e "Current Crossplay setting: 1 = Enable, 2 = Disabled $(tput setaf 2)${currentCrossplayStatus}$(tput setaf 9)"
    echo -e "This is the save path: $(tput setaf 2)${currentSaveDir}$(tput setaf 9)"
    echo -e "$FUNCTION_PRINT_CURRENT_CONFIG_PUBLIC_LISTING_INFO"
}

# Copy current values into editable configuration variables.
function set_config_defaults() {
    setCurrentDisplayName=$currentDisplayName
    setCurrentPort=$currentPort
    setCurrentWorldName=$currentWorldName
    setCurrentPassword=$currentPassword
    setCurrentPublicSet=$currentPublicSet
    setCurrentSaveDir=$currentSaveDir
    setCurrentLogfileDir=$currentLogfileDir
    setCurrentCrossplayStatus=$currentCrossplayStatus
}

# Rewrite the startup script and restart the selected world service.
function write_config_and_restart() {
    tput setaf 1; echo "$FUNCTION_WRITE_CONFIG_RESTART_INFO"; tput setaf 9;
    sleep 1

    configfile="${valheimInstallPath}/${worldname}/start_valheim_${worldname}.sh"

    # Build the updated Valheim startup script.    
	cat > "$configfile" <<EOF
#!/bin/bash
export templdpath=\$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=./linux64:\$LD_LIBRARY_PATH
export SteamAppId=892970
./valheim_server.x86_64 -name "${setCurrentDisplayName}" -port "${setCurrentPort}" -nographics -batchmode -world "${setCurrentWorldName}" -password "${setCurrentPassword}" -public "${setCurrentPublicSet}" -savedir "${worldpath}/${worldname}" -logfile "${setCurrentLogfileDir}" -crossplay "${setCurrentCrossplayStatus}"
export LD_LIBRARY_PATH=\$templdpath
EOF

    echo "$FUNCTION_WRITE_CONFIG_RESTART_SET_PERMS $configfile"
    chown steam:steam "$configfile"
    chmod +x "$configfile"
    echo "$ECHO_DONE"
    echo "$FUNCTION_WRITE_CONFIG_RESTART_SERVICE_INFO"
    sudo systemctl restart valheimserver_${worldname}.service
    echo ""
}

# Change the public server display name.
function change_public_display_name() {
    get_current_config
    print_current_config
    set_config_defaults
    echo ""
    tput setaf 2; echo "$DRAW60"; tput setaf 9;
    read -p "$FUNCTION_CHANGE_PUBLIC_DISPLAY_EDIT_NAME_INFO: " setCurrentDisplayName
    echo ""
    read -p "$PLEASE_CONFIRM (y/n): " confirmPublicNameChange
    if [ "$confirmPublicNameChange" == "y" ]; then
        write_config_and_restart
    else
        echo "$FUNCTION_CHANGE_PUBLIC_DISPLAY_CANCEL_CHANGING"
        sleep 3
        clear
    fi
}

# Change the Crossplay setting.
function change_crossplay_status() {
    get_current_config
    set_config_defaults
    currentCrossplayStatus=$(perl -n -e '/\-crossplay "?([^"]+)"?$/ && print "$1\n"' "${valheimInstallPath}/${worldname}/start_valheim_${worldname}.sh")

    echo ""
    if [ "$currentCrossplayStatus" == "1" ]; then
        echo "Crossplay is currently set to: Enabled"
    else
        echo "Crossplay is currently set to: Disabled"
    fi
    echo ""
    read -p "Please enter 1 to Enable Crossplay or 0 to Disable Crossplay: " setCurrentCrossplayStatus
    read -p "$PLEASE_CONFIRM (y/n): " confirmCrossplayStatusChange

    if [ "$confirmCrossplayStatusChange" == "y" ]; then
        write_config_and_restart
    else
        echo "Updating Crossplay option cancelled"
        sleep 3
        clear
    fi
}

# Change the default server port.
function change_default_server_port() {
    get_current_config
    print_current_config
    set_config_defaults
    echo ""

    while true; do
        read -p "$FUNCTION_CHANGE_DEFAULT_SERVER_PORT_EDIT_PORT: " setCurrentPort
        # Validate the replacement port.
		if [[ ${#setCurrentPort} -ge 4 && ${#setCurrentPort} -le 6 ]] && [[ $setCurrentPort -gt 1024 && $setCurrentPort -le 65530 ]] && [[ "$setCurrentPort" =~ ^[[:alnum:]]+$ ]]; then
            break
        fi
        echo "$FUNCTION_CHANGE_DEFAULT_SERVER_PORT_ERROR_CHECK_MSG"
    done

    read -p "$PLEASE_CONFIRM (y/n): " confirmServerPortChange
    if [ "$confirmServerPortChange" == "y" ]; then
        write_config_and_restart
    else
        echo "$FUNCTION_CHANGE_DEFAULT_SERVER_PORT_CANCEL"
        sleep 3
        clear
    fi
}

# Rename the active world and migrate its save files.
function change_local_world_name() {
    echo ""
    tput setaf 3; echo "$FUNCTION_CHANGE_LOCAL_WORLD_NAME_MSG"; tput sgr0;
    tput setaf 1; echo "WARNING: Advanced Users only! Altering session names incorrectly will cause data decoupling."; tput sgr0;
    echo ""

    get_current_config
    print_current_config
    set_config_defaults

    while true; do
        tput setaf 2; echo "$DRAW60" ; tput sgr0;
        read -p "$WORLD_SET_WORLD_NAME_VAR: " setCurrentWorldName
        tput setaf 2; echo "------------------------------------------------------------" ; tput sgr0;

        # Validate the replacement world name.
		if [[ ${#setCurrentWorldName} -ge 4 && "$setCurrentWorldName" =~ ^[[:alnum:]]+$ ]]; then
            break
        else
            tput setaf 2; echo "$WORLD_SET_ERROR" ; tput sgr0;
        fi
    done

    read -p "$PLEASE_CONFIRM (y/n): " confirmChangeWorldName

    if [ "$confirmChangeWorldName" == "y" ]; then
        echo "Stopping active service tracking thread..."
        sudo systemctl stop valheimserver_${worldname}.service 2>/dev/null

        # Copy the database and world definition under the new name.
		local old_save_dir="${worldpath}/${worldname}/worlds_local"
        if [ -d "$old_save_dir" ]; then
            [ -f "${old_save_dir}/${worldname}.db" ] && cp "${old_save_dir}/${worldname}.db" "${old_save_dir}/${setCurrentWorldName}.db"
            [ -f "${old_save_dir}/${worldname}.fwl" ] && cp "${old_save_dir}/${worldname}.fwl" "${old_save_dir}/${setCurrentWorldName}.fwl"
        fi

        # Update the tracked world list.
		if [ -f "$worldfilelist" ]; then
            sed -i "s/^${worldname}$/${setCurrentWorldName}/g" "$worldfilelist"
        fi

        # Remove the old service definition.
		sudo systemctl disable valheimserver_${worldname}.service 2>/dev/null
        sudo rm -f /lib/systemd/system/valheimserver_${worldname}.service
        sudo rm -f /etc/systemd/system/multi-user.target.wants/valheimserver_${worldname}.service

        worldname="$setCurrentWorldName"
        setCurrentWorldName="$setCurrentWorldName"

        valheimVanilla="1"
        set_valheim_server_vanillaOrBepinex_operations

        tput setaf 2; echo "Session migration successfully completed!"; tput sgr0;
        sleep 3
        clear
    else
        echo "$FUNCTION_CHANGE_SERVER_WORLD_NAME_CANCEL"
        sleep 3
        clear
    fi
}

# Change the server access password.
function change_server_access_password() {
    get_current_config
    print_current_config
    set_config_defaults
    echo ""

    while true; do
        read -p "$FUNCTION_CHANGE_SERVER_ACCESS_PASSWORD_ENTER_NEW: " setCurrentPassword
        # Validate the replacement password.
		if [[ ${#setCurrentPassword} -ge 5 && "$setCurrentPassword" == *[[:lower:]]* && "$setCurrentPassword" == *[[:upper:]]* && "$setCurrentPassword" =~ ^[[:alnum:]]+$ ]]; then
            break
        fi
        echo "$FUNCTION_CHANGE_SERVER_ACCESS_PASSWORD_ERROR_MSG"
    done

    read -p "$PLEASE_CONFIRM (y/n): " confirmServerAccessPassword
    if [ "$confirmServerAccessPassword" == "y" ]; then
        write_config_and_restart
    else
        echo "$FUNCTION_CHANGE_SERVER_ACCESS_PASSWORD_CANCEL"
        sleep 3
        clear
    fi
}

# Enable public server listing.
function write_public_on_config_and_restart() {
    get_current_config
    set_config_defaults
    setCurrentPublicSet=1
    write_config_and_restart
}

# Disable public server listing.
function write_public_off_config_and_restart() {
    get_current_config
    set_config_defaults
    setCurrentPublicSet=0
    write_config_and_restart
}

# Display the complete current server configuration.
function display_full_config() {
    get_current_config
    print_current_config
}

########################################################################
####################CHANGE VALHEIM START CONFIG END#####################
####################===============================#####################
####################  BepInEx ADMIN SECTION START  #####################
########################################################################

# Edit the BepInEx configuration file and optionally restart the server.
function bepinex_mod_options() {
	clear
    nano ${valheimInstallPath}/${worldname}/BepInEx/config/BepInEx.cfg

	echo ""
    tput setaf 2; echo "$DRAW80" ; tput setaf 9;
    tput setaf 2;  echo "$FUNCTION_BEPINEX_EDIT_CONFIG_SAVE_RESTART" ; tput setaf 9;
    tput setaf 2;  echo "$FUNCTION_BEPINEX_EDIT_CONFIG_SAVE_RESTART_1" ; tput setaf 9;
    tput setaf 2; echo "$DRAW80" ; tput setaf 9;
    echo ""

	read -p "$PLEASE_CONFIRM" confirmRestart

	#if y, then continue, else cancel
    if [ "$confirmRestart" == "y" ]; then
		echo ""
		echo "$FUNCTION_BEPINEX_EDIT_RESTART_SERVICES"
		sudo systemctl restart valheimserver_${worldname}.service
		echo ""
		else
		echo "$FUNCTION_BEPINEX_EDIT_CANCEL"
	fi
    sleep 2
    clear

}



# Build the legacy BepInEx startup wrapper.
function build_start_server_bepinex_configuration_file() {

cat > ${valheimInstallPath}/${worldname}/start_server_bepinex.sh <<'EOF'
#!/bin/sh
# BepInEx running script
#
# This script is used to run a Unity game with BepInEx enabled.
#
# Usage: Configure the script below and simply run this script when you want to run your game modded.

# -------- SETTINGS --------
# ---- EDIT AS NEEDED ------
worldname=$(pwd | cut -d'/' -f5)

# EDIT THIS: The name of the executable to run
# LINUX: This is the name of the Unity game executable [preconfigured]
# MACOS: This is the name of the game app folder, including the .app suffix [must provide if needed]
executable_name="valheim_server.x86_64"

# EDIT THIS: Valheim server parameters
# Can be overriden by script parameters named exactly like the ones for the Valheim executable
# (e.g. ./start_server_bepinex.sh -name "MyValheimPlusServer" -password "somethingsafe" -port 2456 -world "myworld" -public 1)
server_name="$(perl -n -e '/\-name "?([^"]+)"? \-port/ && print "$1\n"' start_valheim_${worldname}.sh)"
server_password="$(perl -n -e '/\-password "?([^"]+)"? \-public/ && print "$1\n"' start_valheim_${worldname}.sh)"
server_port="$(perl -n -e '/\-port "?([^"]+)"? \-nographics/ && print "$1\n"' start_valheim_${worldname}.sh)"
server_world="$(perl -n -e '/\-world "?([^"]+)"? \-password/ && print "$1\n"' start_valheim_${worldname}.sh)"
server_public="$(perl -n -e '/\-public "?([^"]+)"? \-savedir/  && print "$1\n"' start_valheim_${worldname}.sh)"
server_savedir=$(perl -n -e '/\-savedir "?([^"]+)"? \-logfile/ && print "$1\n"' start_valheim_${worldname}.sh)
server_logfiledir=$(perl -n -e '/\-logfile "?([^"]+)"?$/ && print "$1\n"' start_valheim_${worldname}.sh)


# The rest is automatically handled by BepInEx for Valheim+
# Set base path of start_server_bepinex.sh location
export VALHEIM_PLUS_SCRIPT="$(readlink -f "$0")"
export VALHEIM_PLUS_PATH="$(dirname "$VALHEIM_PLUS_SCRIPT")"

# Whether or not to enable Doorstop. Valid values: TRUE or FALSE
export DOORSTOP_ENABLE=TRUE

# What .NET assembly to execute. Valid value is a path to a .NET DLL that mono can execute.
export DOORSTOP_INVOKE_DLL_PATH="${VALHEIM_PLUS_PATH}/BepInEx/core/BepInEx.Preloader.dll"

# Which folder should be put in front of the Unity dll loading path
export DOORSTOP_CORLIB_OVERRIDE_PATH="${VALHEIM_PLUS_PATH}/unstripped_corlib"

# ----- DO NOT EDIT FROM THIS LINE FORWARD  ------
# ----- (unless you know what you're doing) ------

if [ ! -x "$1" -a ! -x "${VALHEIM_PLUS_PATH}/$executable_name" ]; then
	echo "Please open start_server_bepinex.sh in a text editor and provide the correct executable."
	exit 1
fi

doorstop_libs="${VALHEIM_PLUS_PATH}/doorstop_libs"
arch=""
executable_path=""
lib_postfix=""

os_type=$(uname -s)
case $os_type in
	Linux*)
		executable_path="${VALHEIM_PLUS_PATH}/${executable_name}"
		lib_postfix="so"
		;;
	Darwin*)
		executable_name="$(basename "${executable_name}" .app)"
		real_executable_name="$(defaults read "${VALHEIM_PLUS_PATH}/${executable_name}.app/Contents/Info" CFBundleExecutable)"
		executable_path="${VALHEIM_PLUS_PATH}/${executable_name}.app/Contents/MacOS/${real_executable_name}"
		lib_postfix="dylib"
		;;
	*)
		echo "Cannot identify OS (got $(uname -s))!"
		echo "Please create an issue at https://github.com/BepInEx/BepInEx/issues."
		exit 1
		;;
esac

executable_type=$(LD_PRELOAD="" file -b "${executable_path}");

case $executable_type in
	*64-bit*)
		arch="x64"
		;;
	*32-bit*|*i386*)
		arch="x86"
		;;
	*)
		echo "Cannot identify executable type (got ${executable_type})!"
		echo "Please create an issue at https://github.com/BepInEx/BepInEx/issues."
		exit 1
		;;
esac

doorstop_libname=libdoorstop_${arch}.${lib_postfix}
export LD_LIBRARY_PATH="${doorstop_libs}":"${LD_LIBRARY_PATH}"
export LD_PRELOAD="$doorstop_libname":"${LD_PRELOAD}"
export DYLD_LIBRARY_PATH="${doorstop_libs}"
export DYLD_INSERT_LIBRARIES="${doorstop_libs}/$doorstop_libname"

export templdpath="$LD_LIBRARY_PATH"
export LD_LIBRARY_PATH="${VALHEIM_PLUS_PATH}/linux64":"${LD_LIBRARY_PATH}"
export SteamAppId=892970

for arg in "$@"
do
	case $arg in
	-name)
	server_name=$2
	shift 2
	;;
	-password)
	server_password=$2
	shift 2
	;;
	-port)
	server_port=$2
	shift 2
	;;
	-world)
	server_world=$2
	shift 2
	;;
	-public)
	server_public=$2
	shift 2
	;;
	-savedir)
	server_savedir=$2
	shift 2
	;;
	esac
done

"${VALHEIM_PLUS_PATH}/${executable_name}" -name "${server_name}" -password "${server_password}" -port "${server_port}" -world "${server_world}" -public "${server_public}" -savedir "${server_savedir}" -logfile "${server_logfiledir}" -logappend -logflush

export LD_LIBRARY_PATH=$templdpath
EOF
}

# Read server settings from the vanilla startup script.
function set_valheim_server_vanillaOrBepinex_operations() {
    # Build systemctl configurations for execution of processes for Valheim Server
    tput setaf 1; echo "$FUNCTION_BEPINEX_BUILD_CONFIG_INFO"; tput sgr0;
    tput setaf 1; echo "$FUNCTION_BEPINEX_BUILD_CONFIG_INFO_1"; tput sgr0;

    # 1. Cleanly pull live variable baselines and execute your write function
    get_current_config
    set_config_defaults
    write_config_and_restart

    # Remove old Valheim Server Service file instances to prevent target locks
    [ -e /etc/systemd/system/valheimserver_${worldname}.service ] && rm -f /etc/systemd/system/valheimserver_${worldname}.service
    [ -e /lib/systemd/system/valheimserver_${worldname}.service ] && rm -f /lib/systemd/system/valheimserver_${worldname}.service
    sleep 1

    # 2. Generate the base systemd unit configuration container layout
    sudo cat <<EOF > /lib/systemd/system/valheimserver_${worldname}.service
[Unit]
Description=Valheim Server
Wants=network-online.target
After=syslog.target network.target nss-lookup.target network-online.target

[Service]
Type=simple
Restart=on-failure
RestartSec=5
StartLimitInterval=60s
StartLimitBurst=3
User=steam
Group=steam
ExecStartPre=/home/steam/steamcmd/linux32/steamcmd +login anonymous +force_install_dir ${valheimInstallPath}/${worldname} +app_update 896660 validate +exit
EOF

    # 3. Dynamic execution handoff checking
    if [ "$valheimVanilla" == "1" ]; then
        echo "$FUNCTION_BEPINEX_BUILD_CONFIG_SET_VANILLA"
        sudo cat <<EOF >> /lib/systemd/system/valheimserver_${worldname}.service
ExecStart=${valheimInstallPath}/${worldname}/start_valheim_${worldname}.sh
ExecReload=/bin/kill -s HUP \$MAINPID
KillSignal=SIGINT
WorkingDirectory=${valheimInstallPath}/${worldname}
LimitNOFILE=100000

[Install]
WantedBy=multi-user.target
EOF
    else
        echo "$FUNCTION_BEPINEX_BUILD_CONFIG_SET"
        sudo cat <<EOF >> /lib/systemd/system/valheimserver_${worldname}.service
ExecStart=${valheimInstallPath}/${worldname}/start_valw_bepinex.sh
ExecReload=/bin/kill -s HUP \$MAINPID
KillSignal=SIGINT
WorkingDirectory=${valheimInstallPath}/${worldname}
LimitNOFILE=100000

[Install]
WantedBy=multi-user.target
EOF
    fi

    # 4. Flush the systemd cache and cycle the service daemon
    sudo systemctl daemon-reload
    sudo systemctl enable valheimserver_${worldname}.service
    sudo systemctl restart valheimserver_${worldname}.service

    tput setaf 2; echo "Done"; tput sgr0;
    sleep 1
}

# Download, install, and configure the latest BepInEx package.
function install_valheim_bepinex() {
    clear
	# Ensure unzip is available before extracting the package.
    if command -v unzip >/dev/null 2>&1; then
        echo "  -> Status: unzip is already installed."
    else
        echo "  -> Status: unzip is MISSING. Initializing automated deployment sequence..."
        if command -v dnf >/dev/null 2>&1; then
            echo "  -> Executing: dnf install -y unzip"
            dnf install -y unzip
        elif command -v apt >/dev/null 2>&1; then
            echo "  -> Executing: apt install unzip -y"
            apt install unzip -y
        elif command -v yum >/dev/null 2>&1; then
            echo "  -> Executing: yum install unzip -y"
            yum install unzip -y
        fi
    fi
    echo ""

    tput setaf 2; echo "$FUNCTION_BEPINEX_INSTALL_CHANGING_DIR"; tput setaf 9;
    cd /opt || exit 1
    mkdir -p bepinexdl && cd bepinexdl || exit 1

    tput setaf 2; echo "$FUNCTION_BEPINEX_INSTALL_DOWNLOADING_BEPINEX_FROM_REPO"; tput setaf 9;

    # Query Thunderstore for the current package version.
    local dynamicLatestVersion=$(curl -sL -H "accept: application/json" "https://thunderstore.io/api/experimental/package/denikson/BepInExPack_Valheim/" | python3 -c "import sys, json; print(json.load(sys.stdin)['latest']['version_number'])")

    # Extract and copy the BepInEx package into the world directory.
    wget -O bepinex.zip   https://thunderstore.io/package/download/denikson/BepInExPack_Valheim/${dynamicLatestVersion}

    tput setaf 2; echo "$FUNCTION_BEPINEX_INSTALL_UNPACKING_FILES"; tput setaf 9;
    unzip -o bepinex.zip

    if [ ! -d "${valheimInstallPath}/${worldname}" ]; then
        echo "  -> Destination missing. Forcing folder tree generation..."
        mkdir -p "${valheimInstallPath}/${worldname}"
    fi

    # Sync archive elements over into place
    cp -a BepInExPack_Valheim/. "${valheimInstallPath}/${worldname}"

    tput setaf 2; echo "$FUNCTION_BEPINEX_INSTALL_CREATING_VER_STAMP"; tput setaf 9;
    # Write version verification code straight to storage tracking files
    echo "$dynamicLatestVersion" > "${valheimInstallPath}/${worldname}/localValheimBepinexVersion"

    ### Cleanup temporary source tracking space
    # cd "${valheimInstallPath}/${worldname}" || exit 1
    # rm -rf /opt/bepinexdl

    [ -e start_valw_bepinex.sh ] && rm start_valw_bepinex.sh

    tput setaf 2; echo "$FUNCTION_BEPINEX_INSTALL_BUILDING_NEW_BEPINEX_CONFIG"; tput setaf 9;
    build_valw_bepinex_configuration_file

    tput setaf 2; echo "$FUNCTION_BEPINEX_INSTALL_SETTING_STEAM_OWNERSHIP"; tput setaf 9;
    chown -Rf steam:steam /home/steam/*
    chmod +x start_valw_bepinex.sh
    echo ""

    # clear

    tput setaf 2; echo "$FUNCTION_BEPINEX_INSTALL_GET_THEIR_VIKING_ON"; tput setaf 9;
    tput setaf 2; echo "$FUNCTION_BEPINEX_INSTALL_LETS_GO"; tput setaf 9;
}

# Enable BepInEx for the selected Valheim world.
function valheim_bepinex_enable() {
clear
    echo ""
    tput setaf 2; echo "$FUNCTION_BEPINEX_ENABLE" ; tput setaf 9;
    valheimVanilla=2
    set_valheim_server_vanillaOrBepinex_operations
    sleep 1
    systemctl daemon-reload
    sleep 1
    echo "$FUNCTION_BEPINEX_RESTARTING"
    systemctl restart valheimserver_${worldname}.service
    sleep 1
    tput setaf 2; echo "$FUNCTION_BEPINEX_ENABLED_ACTIVE" ; tput setaf 9;
    echo ""
}

# Disable BepInEx and return to the vanilla launcher.
function valheim_bepinex_disable() {
clear
    echo ""
    tput setaf 2; echo "$FUNCTION_BEPINEX_DISABLE" ; tput setaf 9;
    valheimVanilla=1
    set_valheim_server_vanillaOrBepinex_operations
    sleep 1
    systemctl daemon-reload
    sleep 1
    echo "$FUNCTION_BEPINEX_DISABLE_RESTARTING"
    systemctl restart valheimserver_${worldname}.service
    sleep 1
    tput setaf 2; echo "$FUNCTION_BEPINEX_DISABLE_INFO" ; tput setaf 9;
    echo ""
}

# Compare local and remote BepInEx versions and apply an update.
function valheim_bepinex_update() {
    clear

    # Baseline tracking fallback parameter setup
    local legacyBaselineVersion="0.0.0000"

    local officialBepInEx=$(curl -sL -H "accept: application/json" "https://thunderstore.io/api/experimental/package/denikson/BepInExPack_Valheim/" | python3 -c "import sys, json; print(json.load(sys.stdin)['latest']['version_number'])")

    local_file_path="${valheimInstallPath}/${worldname}/localValheimBepinexVersion"

    if [ -f "$local_file_path" ] && [ -s "$local_file_path" ]; then
        echo "  -> Status: Tracking file exists and contains binary data."
        localBepInEx=$(cat "$local_file_path")
    else
        echo "  -> Status: Tracking file is missing or 0 bytes. Defaulting to fallback reference string."
        localBepInEx="$legacyBaselineVersion"
    fi
    echo ""

    clear

    # Render clean structural user screen
    tput setaf 2; echo "============================================================"; tput setaf 9;
    echo "Official BepInEx Version: $(tput setaf 2)$officialBepInEx$(tput setaf 9)"
    echo "Local BepInEx Version   : $(tput setaf 1)$localBepInEx$(tput setaf 9)"
    tput setaf 2; echo "============================================================"; tput setaf 9;
    echo ""

    if [[ "$officialBepInEx" == "$localBepInEx" ]]; then
        tput setaf 2; echo "$FUNCTION_BEPINEX_UPDATE_NO_UPDATE_FOUND"; tput setaf 9;
        sleep 3
    else
        tput setaf 2; echo "$FUNCTION_BEPINEX_UPDATE_UPDATE_FOUND"; tput setaf 9;
        tput setaf 2; echo "$FUNCTION_BEPINEX_UPDATE_CONTINUE"; tput setaf 9;
        read -p "$PLEASE_CONFIRM" confirmValBepinexUpdate

		# Back up the current BepInEx configuration before updating. 
        if [ "$confirmValBepinexUpdate" == "y" ]; then
            tput setaf 2; echo "$FUNCTION_BEPINEX_UPDATE_BACKING_UP_BEPINEX_CONFIG"; tput setaf 9;
            mkdir -p "$backupPath"
            sleep 1

            TODAYMK="$(date +%Y-%m-%d-%T)"
            config_source="${valheimInstallPath}/${worldname}/BepInEx/config/BepInEx.cfg"

            if [ -f "$config_source" ]; then
                cp "$config_source" "${backupPath}/BepInEx.cfg-$TODAYMK.cfg"
                echo "Backup saved: ${backupPath}/BepInEx.cfg-$TODAYMK.cfg"
            else
                echo "No source BepInEx.cfg found to copy. Skipping config backup step."
            fi

            tput setaf 2; echo "$FUNCTION_BEPINEX_UPDATE_DOWNLOADING_BEPINEX"; tput setaf 9;
            install_valheim_bepinex
            sleep 2

            tput setaf 2; echo "$FUNCTION_BEPINEX_UPDATE_RESTARTING_SERVICES"; tput setaf 9;
            restart_valheim_server
        else
            echo "$FUNCTION_BEPINEX_UPDATE_CANCELED"; tput setaf 9;
            sleep 2
        fi
    fi
}



# Build the current BepInEx startup wrapper.
function build_valw_bepinex_configuration_file() {
  cat > "${valheimInstallPath}/${worldname}/start_valw_bepinex.sh" << 'EOF'
#!/bin/sh
# BepInEx running script
#
# This script is used to run a Unity game with BepInEx enabled.
#
# Usage: Configure the script below and simply run this script when you want to run your game modded.
# -------- SETTINGS --------
# ---- EDIT AS NEEDED ------
# EDIT THIS: The name of the executable to run
# LINUX: This is the name of the Unity game executable
# MACOS: This is the name of the game app folder, including the .app suffix
# Resolve the BepInEx path according to the host platform.
if command -v apt-get >/dev/null; then
   export VALHEIM_BEP_SCRIPT="$(readlink -f "$0")"
   export VALHEIM_BEP_PATH="$(dirname "$VALHEIM_BEP_SCRIPT")"
   worldname=$(pwd | cut -d'/' -f5)
elif command -v dnf >/dev/null || command -v yum >/dev/null; then
   export VALHEIM_BEP_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
   export VALHEIM_BEP_SCRIPT="${VALHEIM_BEP_PATH}/start_valw_bepinex.sh"
   worldname="$(basename "${VALHEIM_BEP_PATH}")"
else
   echo "Mapping error encountered."
   exit
fi

# Read Valheim arguments from the world startup script.
# Importing server parameters to BepInEx via Perl (FIXED for trailing arguments)
server_name="$(perl -n -e '/\-name "?([^"]+)"?(?=\s|\b)/ && print "$1\n"' ${VALHEIM_BEP_PATH}/start_valheim_${worldname}.sh | head -n1)"
server_password="$(perl -n -e '/\-password "?([^"]+)"?(?=\s|\b)/ && print "$1\n"' ${VALHEIM_BEP_PATH}/start_valheim_${worldname}.sh | head -n1)"
server_port="$(perl -n -e '/\-port "?([^"]+)"?(?=\s|\b)/ && print "$1\n"' ${VALHEIM_BEP_PATH}/start_valheim_${worldname}.sh | head -n1)"
server_world="$(perl -n -e '/\-world "?([^"]+)"?(?=\s|\b)/ && print "$1\n"' ${VALHEIM_BEP_PATH}/start_valheim_${worldname}.sh | head -n1)"
server_public="$(perl -n -e '/\-public "?([^"]+)"?(?=\s|\b)/ && print "$1\n"' ${VALHEIM_BEP_PATH}/start_valheim_${worldname}.sh | head -n1)"
server_savedir=$(perl -n -e '/\-savedir "?([^"]+)"?(?=\s|\b)/ && print "$1\n"' ${VALHEIM_BEP_PATH}/start_valheim_${worldname}.sh | head -n1)
server_logfiledir=$(perl -n -e '/\-logfile "?([^"]+)"?(?=\s|\b)/ && print "$1\n"' ${VALHEIM_BEP_PATH}/start_valheim_${worldname}.sh | head -n1)
server_crossplay=$(perl -n -e '/\-crossplay "?([^"]+)"?(?=\s|\b)/ && print "$1\n"' ${VALHEIM_BEP_PATH}/start_valheim_${worldname}.sh | head -n1)

# The rest is automatically handled by BepInEx
# Whether or not to enable Doorstop. Valid values: TRUE or FALSE
# BepInEx-specific settings
# NOTE: Do not edit unless you know what you are doing!
export DOORSTOP_ENABLE=TRUE
export DOORSTOP_ENABLED=1
export DOORSTOP_INVOKE_DLL_PATH=${VALHEIM_BEP_PATH}/BepInEx/core/BepInEx.Preloader.dll
export DOORSTOP_TARGET_ASSEMBLY=${VALHEIM_BEP_PATH}/BepInEx/core/BepInEx.Preloader.dll
export DOORSTOP_CORLIB_OVERRIDE_PATH=${VALHEIM_BEP_PATH}/unstripped_corlib
export LD_LIBRARY_PATH=${VALHEIM_BEP_PATH}/doorstop_libs:${VALHEIM_BEP_PATH}/linux64:${LD_LIBRARY_PATH}
export LD_PRELOAD=libdoorstop_x64.so:$LD_PRELOAD
export SteamAppId=892970

echo "Starting server PRESS CTRL-C to exit"

# Tip: Make a local copy of this script to avoid it being overwritten by steam.
# NOTE: Minimum password length is 5 characters & Password cant be in the server name.
# NOTE: You need to make sure the ports 2456-2458 is being forwarded to your server through your local router & firewall.
# Start Valheim through BepInEx with the collected server settings.
#exec ./valheim_server.x86_64 -name "My server" -port 2456 -world "Dedicated" -password "secret"
exec "${VALHEIM_BEP_PATH}/valheim_server.x86_64" -name "${server_name}" -password "${server_password}" -port "${server_port}" -world "${server_world}" -public "${server_public}" -savedir "${server_savedir}" -logfile "${server_logfiledir}" -crossplay "${server_crossplay}"
EOF
}

# Display the latest BepInEx version reported by Thunderstore.
function check_bepinex_repo() {
    local raw_json=$(curl -sL -H "accept: application/json" "https://thunderstore.io/api/experimental/package/denikson/BepInExPack_Valheim/") # | python3 -c "import sys, json; print(json.load(sys.stdin)['latest']['version_number'])")
    latestBepinex=$(echo "$raw_json" | python3 -c "import sys, json; print(json.load(sys.stdin)['latest']['version_number'])" 2>&1)
    echo "$latestBepinex"
    echo ""
	sleep 2
}

# Display the locally installed BepInEx version.
function check_local_bepinex_build() {
   localValheimBepinexVer=${valheimInstallPath}/${worldname}/localValheimBepinexVersion

   if [[ -e $localValheimBepinexVer ]] ; then
    localValheimBepinexBuild=$(cat ${localValheimBepinexVer})
        echo $localValheimBepinexBuild
    else
        echo "0.0.0";
  fi
}

# Display and process the BepInEx administration menu.
function bepinex_menu(){
echo ""
menu_header_bepinex_enable
echo -ne "
$(ColorCyan '--------------'"$FUNCTION_BEPINEX_MENU_HEADER"'--------------')
$(ColorCyan '-')$(ColorGreen ' 1)') $FUNCTION_BEPINEX_MENU_INSTALL
$(ColorCyan '---------------'"$FUNCTION_BEPINEX_MENU_ADMIN_HEADER"'--------------')
$(ColorCyan '-')$(ColorGreen ' 2)') $FUNCTION_BEPINEX_MENU_ENABLE
$(ColorCyan '-')$(ColorGreen ' 3)') $FUNCTION_BEPINEX_MENU_DISABLE
$(ColorCyan '-')$(ColorGreen ' 4)') $FUNCTION_BEPINEX_MENU_START
$(ColorCyan '-')$(ColorGreen ' 5)') $FUNCTION_BEPINEX_MENU_STOP
$(ColorCyan '-')$(ColorGreen ' 6)') $FUNCTION_BEPINEX_MENU_RESTART
$(ColorCyan '-')$(ColorGreen ' 7)') $FUNCTION_BEPINEX_MENU_STATUS
$(ColorCyan '-')$(ColorGreen ' 8)') $FUNCTION_BEPINEX_MENU_UPDATE
$(ColorCyan '------'"$FUNCTION_BEPINEX_MENU_MOD_PLUGIN_HEADER"'------')
$(ColorCyan ''"$FUNCTION_BEPINEX_MENU_MOD_INFO"'')
$(ColorCyan ''"$FUNCTION_BEPINEX_MENU_MOD_INFO_1"'')
$(ColorCyan ''"$FUNCTION_BEPINEX_MENU_MOD_INFO_2"'')
$(ColorCyan ''"$FUNCTION_BEPINEX_MENU_MOD_INFO_3"'')
$(ColorCyan ''"$FUNCTION_BEPINEX_MENU_MOD_INFO_4"'')
$(ColorCyan '-')$(ColorGreen ' 9)') $FUNCTION_BEPINEX_MENU_BEPINEX_CONFIG_EDIT
$(ColorCyan '------------------------------------------------')
$(ColorCyan '-')$(ColorGreen ' 0)') $FUNCTION_BEPINEX_MENU_RETURN_MAIN
$(ColorPurple ''"$CHOOSE_MENU_OPTION"'')"
        read a
        case $a in
		1) install_valheim_bepinex ; bepinex_menu ;;
		2) valheim_bepinex_enable ; bepinex_menu ;;
		3) valheim_bepinex_disable ; bepinex_menu ;;
		4) start_valheim_server ; bepinex_menu ;;
		5) stop_valheim_server ; bepinex_menu ;;
		6) restart_valheim_server ; bepinex_menu ;;
		7) display_valheim_server_status ; bepinex_menu ;;
		8) valheim_bepinex_update ; bepinex_menu ;;
		9) bepinex_mod_options ; bepinex_menu ;;
		0) menu ; menu ;;
		   *)  echo -ne " $(ColorRed ''"$WRONG_MENU_OPTION"'')" ; bepinex_menu ;;
        esac
}

########################################################################
###############      BepInEx ADMIN SECTION END      ####################
###############=====================================####################
###############   LEGACY MENU UPGRADE SECTION START ####################
########################################################################

### Migrate an installation from the older Njord menu layout.
function get_current_config_upgrade_menu() {
    echo "Rebuilding Configuration Files for New Njord Menu"
	# Stop the original Valheim service before migration.
    systemctl stop valheimserver.service
    sleep 5
	# Preserve the existing steam home directory before restructuring files.
    cp -Rf /home/steam /home/steambackup
    # Create the world list from the legacy startup script when needed.
    [ -f "$worldfilelist" ] || perl -n -e '/\-world "?([^"]+)"? \-password/ && print "$1\n"' /home/steam/valheimserver/start_valheim.sh > /home/steam/worlds.txt

    if [ ! -f "$worldfilelist" ]; then
         touch "$worldfilelist"
    fi
    chown steam:steam /home/steam/worlds.txt
    setNewWorldNamePathing=$(cat /home/steam/worlds.txt)
	# Move the legacy installation into the world-specific directory layout.
    mkdir -p ${valheimInstallPath}/${setNewWorldNamePathing}
    rsync -a --exclude ${setNewWorldNamePathing} ${valheimInstallPath}/ /home/steam/valheimserver/${setNewWorldNamePathing}
    find ${valheimInstallPath} -mindepth 1 -maxdepth 1 -type d,f -not -name ${setNewWorldNamePathing} -exec rm -Rf '{}' \;
    mv ${valheimInstallPath}/${setNewWorldNamePathing}/start_valheim.sh ${valheimInstallPath}/${setNewWorldNamePathing}/start_valheim_${setNewWorldNamePathing}.sh
    get_current_config
    # Rebuild the world startup script and systemd service.
    cat > ${valheimInstallPath}/${worldname}/start_valheim_${worldname}.sh <<EOF
#!/bin/bash
export templdpath=\$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=./linux64:\$LD_LIBRARY_PATH
export SteamAppId=892970
./valheim_server.x86_64 -name "${setCurrentDisplayName}" -port "${setCurrentPort}" -nographics -batchmode -world "${setCurrentWorldName}" -password "${setCurrentPassword}" -public "${setCurrentPublicSet}" -savedir "${worldpath}/${worldname}" -logfile "${setCurrentLogfileDir}" -crossplay "${setCurrentCrossplayStatus}"
export LD_LIBRARY_PATH=\$templdpath
EOF
    # Remove the legacy service definition before creating the new one.
    find /. -name valheimserver.service -exec rm -rf {} \;
    worldname=$(cat /home/steam/worlds.txt)

    cat > /lib/systemd/system/valheimserver_${worldname}.service <<EOF
[Unit]
Description=Valheim Server
Wants=network-online.target
After=syslog.target network.target nss-lookup.target network-online.target

[Service]
Type=simple
Restart=on-failure
RestartSec=5
StartLimitInterval=60s
StartLimitBurst=3
User=steam
Group=steam
ExecStartPre=/home/steam/steamcmd/linux32/steamcmd +login anonymous +force_install_dir ${valheimInstallPath}/${worldname} +app_update 896660 validate +exit
ExecStart=${valheimInstallPath}/${worldname}/start_valheim_${worldname}.sh
ExecReload=/bin/kill -s HUP \$MAINPID
KillSignal=SIGINT
WorkingDirectory=${valheimInstallPath}/${worldname}
LimitNOFILE=100000

[Install]
WantedBy=multi-user.target
EOF

    # Restore world data into the new save directory.
    mkdir -p ${worldpath}/${worldname}
    rsync -a --exclude ${worldname} ${worldpath}/ /${worldpath}/${worldname}
    chown -Rf steam:steam /home/steam
    systemctl daemon-reload
    systemctl start valheimserver_${worldname}.service
    echo "Upgrade Complete. Please restart the Njord Menu."
    sleep 3
}

########################################################################
###################LEGACY MENU UPGRADE SECTION END######################
###################===============================######################
###################  MENUS STATUS VARIBLES START  ######################
########################################################################

# Read and cache the current official Valheim build identifier.
function check_official_valheim_release_build() {
    # 1. Simple check: If the steam user does NOT exist, force-create the target directory structure
    if ! getent passwd steam >/dev/null 2>&1; then
        echo "First-time setup detected. Skipping"
    else
        official_build_file="${valheimInstallPath}/${worldname}/officialvalheimbuild"

        update_official_repo() {
		    # Refresh the cached official build identifier.
            find "/home" "/root" -wholename "*/.steam/appcache/appinfo.vdf" | xargs -r rm -f --

            # Use a fallback when SteamCMD is unavailable.
            if [ -z "$steamexe" ] || [ ! -f "$steamexe" ]; then
                currentOfficialRepo="000000"
            else
                #currentOfficialRepo=$($steamexe +login anonymous +app_info_update 1 +app_info_print 896660 +quit | grep -A10 branches | grep -A2 public | grep buildid | cut -d'"' -f4)
                currentOfficialRepo=$($steamexe +login anonymous +app_info_update 1 +app_info_print 896660 +quit 2>/dev/null | grep -A10 branches | grep -A2 public | grep buildid | cut -d'"' -f4)
			fi
            # Save the build identifier for later menu displays.
            echo "$currentOfficialRepo" > "$official_build_file"

            # Only try to chown if the steam user actually exists in the system database
            getent passwd steam >/dev/null 2>&1 && chown -Rf steam:steam "$official_build_file"
            echo "$currentOfficialRepo"
        } 
		
        if [[ $(find "$official_build_file" -mmin +59 -print 2>/dev/null) ]]; then
            update_official_repo
        elif [ ! -f "$official_build_file" ]; then
            update_official_repo
        elif [ -f "$official_build_file" ]; then
            currentOfficialRepo=$(cat "$official_build_file")
            echo "$currentOfficialRepo"
        else
            echo "$NO_DATA"
        fi
    fi
}



# Read the locally installed Valheim build identifier.
function check_local_valheim_build() {
localValheimAppmanifest=${valheimInstallPath}/${worldname}/steamapps/appmanifest_896660.acf
   if [[ -e $localValheimAppmanifest ]]; then
    localValheimBuild=$(grep buildid ${localValheimAppmanifest} | cut -d'"' -f4)
        echo $localValheimBuild
    else
        echo "$NO_DATA";
  fi
}

# Check the upstream menu release reported by GitHub.
function check_menu_script_repo() {
latestScript=$(curl --connect-timeout 5 -s https://api.github.com/repos/Nimdy/Dedicated_Valheim_Server_Script/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
echo $latestScript
}

# Display whether the selected server is publicly listed.
function display_public_status_on_or_off() {
    currentPublicStatus=$(perl -n -e '/\-public "([0-1])"? \-savedir/ && print "$1\n"' ${valheimInstallPath}/${worldname}/start_valheim_${worldname}.sh)
    if [[ $currentPublicStatus == 1 ]]; then
      echo "$ECHO_ON"
    else
      echo "$ECHO_OFF"
  fi
}

# Display the current Crossplay state.
function display_crossplay_status() {
	currentCrossplayStatus=$(perl -n -e '/\-crossplay "?([^"]+)"?$/ && print "$1\n"' ${valheimInstallPath}/${worldname}/start_valheim_${worldname}.sh)
	if [ "$currentCrossplayStatus" == "1" ]; then
	  echo  $(ColorGreen ''"Enabled"'')
	else
	  echo  $(ColorRed ''"Disabled"'')
  fi
}

# Read the most recent Crossplay join code from the server log.
function display_last_join_code() {
    local currentGameCode joinCode
    local logFile="/home/steam/.config/unity3d/IronGate/Valheim/${worldname}/valheim_server.log"

    # Search for the pattern and store the result in 'currentGameCode'
    currentGameCode=$(tac "$logFile" | grep -m1 -E " registered with join code [0-9]{6}")

    # Check if 'currentGameCode' is not empty before extracting the join code
    if [ -n "$currentGameCode" ]; then
        # Extract the last six digits and store them in 'joinCode'
        joinCode=$(echo "$currentGameCode" | grep -oP '(?<=join code )[0-9]{6}')
        echo "$joinCode"
    else
        echo "No join code found."
    fi
}

# Count recent peer-connection entries from the server log.
function current_player_count() {
    local connectedPeers playerCount
    local logFile="/home/steam/.config/unity3d/IronGate/Valheim/${worldname}/valheim_server.log"
    local timeLimit=$(date -d "30 minutes ago" '+%Y-%m-%dT%H:%M:%S')

    # Search for the pattern within the time limit and store the result in 'connectedPeers'
    connectedPeers=$(awk -v timeLimit="$timeLimit" -F'[][]' '$1 > timeLimit' "$logFile" | grep -E "Server: New peer connected,sending global keys")

    # Check if 'connectedPeers' is not empty before counting the occurrences
    if [ -n "$connectedPeers" ]; then
        # Count the occurrences of "Server: New peer connected,sending global keys" in the last 30 minutes
        playerCount=$(echo "$connectedPeers" | wc -l)
        echo "Players connected in the last 30 minutes: $playerCount"
    else
        echo "No players connected in the last 30 minutes."
    fi
}

# Display the external IP address.
function display_public_IP() {
    local externalip
    externalip=$(curl -s ipecho.net/plain)
    echo "$EXTERNAL_IP $whateverzerowantstocalthis $(ColorGreen "$externalip")"
    tput setaf 9
}

# Display the local host IP address.
function display_local_IP() {
    local internalip
    internalip=$(hostname -I)
    echo "$INTERNAL_IP $mymommyboughtmeaputerforchristmas $(ColorGreen "$internalip")"
    tput setaf 9
}

# Display the systemd service state.
function server_status() {
    local server_status
    server_status=$(systemctl is-active valheimserver_${worldname}.service)
    echo -e '\E[32m'"$server_status"
}

# Display the systemd service substate.
function server_substate() {
    local server_substate
    server_substate=$(systemctl show -p SubState valheimserver_${worldname}.service | cut -d'=' -f2)
    echo -e '\E[32m'"$server_substate"
}

# Check whether the host can reach the internet.
function are_you_connected() {
    local status
    if ping -c 1 google.com &> /dev/null; then
        status=$(ColorGreen "$INTERNET_MSG_CONNECTED")
    else
        status=$(ColorRed "$INTERNET_MSG_DISCONNECTED")
    fi
    echo "$INTERNET_MSG $tecreset $status"
}

# Identify whether BepInEx is active for the selected world.
function are_mods_enabled() {
    local modstrue var2 var3
    modstrue=$(grep -F "ExecStart=${valheimInstallPath}/${worldname}/start" /lib/systemd/system/valheimserver_${worldname}.service)
    var2="ExecStart=${valheimInstallPath}/${worldname}/start_server_bepinex.sh"
    var3="ExecStart=${valheimInstallPath}/${worldname}/start_valw_bepinex.sh"

    if [[ $modstrue == *"$var2"* ]]; then
        echo "Enabled with ValheimPlus"
    elif [[ $modstrue == *"$var3"* ]]; then
        echo "Enabled with BepInEx"
    else
        echo "Disabled"
    fi
}

# Select the SteamCMD executable for the detected Linux family.
function set_steamexe() {
	if [ "$debugmsg" == "y" ] ; then
		tput setaf 1; echo -ne "$FUNCTION_SET_STEAMEXE_INFO" ; tput setaf 9;
	fi

	if command -v apt-get >/dev/null; then
		# Ubuntu packages deployment location
		steamexe="/usr/games/steamcmd"
	elif command -v dnf >/dev/null || command -v yum >/dev/null; then
		# FIXED: Forces Fedora 44 and RHEL to map directly to your working /home paths
		steamexe="/home/steam/steamcmd/steamcmd.sh"
	else
		echo "Mapping error encountered."
	fi

	if [ "$debugmsg" == "y" ] ; then
		tput setaf 2; echo -ne "$ECHO_DONE" ; tput setaf 9;
	fi
	sleep 1
}


# Select the active world from the tracked world list.
function set_world_server() {
    if [ -z "$worldname" ] && [ -n "$worldlistarray" ] && [ "$request99" != "y" ]; then
        worldname="${worldlistarray[0]}"
    elif [ -n "$worldlistarray" ] && [ "$request99" = "y" ]; then
        echo "$FUNCTION_SET_WORLD_SERVER_INFO"
        select world in "${worldlistarray[@]}"; do
            if [ -n "$REPLY" ]; then
                worldname="$world"
                echo "You selected $world ($REPLY)"
                echo "World name is ${world}"
                echo "World menu selection: ${world}"
                break
            else
                echo "Invalid selection"
            fi
        done
    elif [ -z "$worldname" ] && [ -n "$worldlistarray" ]; then
        worldname="Default"
        echo ""
    else
        echo ""
    fi
    request99="n"
}


# Recommend an available port for an additional server.
function validateUsedValheimPorts() {
    local starting_port=2459
    local ending_port=2600
    local port_in_use

    for (( i=$starting_port; i<=$ending_port; i++ )); do
        port_in_use=$(sudo netstat -plnt | grep ":$i")
        if [[ -z "$port_in_use" ]]; then
            echo "$i not in use, Recommend choosing this one"
            return
        elif [[ "$i" -eq "$ending_port" ]]; then
            echo "No ports to use"
        fi
    done
}

# Return the host name.
function currentHostName(){
var="$(hostname)"
echo $var
}
########################################################################
##########################MENUS STATUS VARIBLES END#####################
##########################=========================#####################
##########################   MENU SECTION START    #####################
########################################################################
# NJORD Headers
# Display the legacy ValheimPlus-style information header.
function menu_header_vplus_enable() {
clear
get_current_config
echo -ne "
$(ColorPurple '╔════════════════════')$(ColorOrange 'Valheim+')$(ColorPurple '═══════════════════╗')
$(ColorPurple '║~~~~~~~~~~~~~~~~~~')$(ColorLightGreen '-Njord Menu-')$(ColorPurple '~~~~~~~~~~~~~~~~~║')
$(ColorPurple '╠═══════════════════════════════════════════════╝')
$(ColorPurple '║')$(ColorLightGreen ' Welcome to Valheim+ Intergrated Menu System')
$(ColorPurple '║')$(ColorLightGreen ' Valheim+ Support: https://discord.gg/WU69A2JTcn')
$(ColorPurple '║ '"$FUNCTION_HEADER_MENU_INFO_2"'')
$(ColorPurple '╠═══════════════════════════════════════════════')
$(ColorPurple '║ Mods:') $(are_mods_enabled)
$(ColorPurple '╠═══════════════════════════════════════════════')
$(ColorPurple '║') ValheimPlus Official Build:" $(check_valheim_plus_repo)
echo -ne "
$(ColorPurple '║') ValheimPlus Server Build:" $(check_local_valheim_plus_build)
echo -ne "
$(ColorPurple '╠═══════════════════════════════════════════════')
$(ColorPurple '║ '"$FUNCTION_HEADER_MENU_INFO_VALHEIM_OFFICIAL_BUILD"'')" $(check_official_valheim_release_build)
echo -ne "
$(ColorPurple '║ '"$FUNCTION_HEADER_MENU_INFO_VALHEIM_LOCAL_BUILD"' ')"        $(check_local_valheim_build)
echo -ne "
$(ColorPurple '╠═══════════════════════════════════════════════')"
echo -ne "
$(ColorPurple '║') $FUNCTION_HEADER_MENU_INFO_SERVER_NAME " ${currentDisplayName}
echo -ne "
$(ColorPurple '║')" $FUNCTION_HEADER_MENU_INFO_LD_SEVER_SESSION $(ColorGreen ''"${worldname}"'')
echo -ne "
$(ColorPurple '║') $(are_you_connected)
$(ColorPurple '║')" $(display_public_IP)
echo -ne "
$(ColorPurple '║')" $(display_local_IP)
echo -ne "
$(ColorPurple '║') $FUNCTION_HEADER_MENU_INFO_SERVER_PORT " $(ColorGreen ''"${currentPort}"'')
echo -ne "
$(ColorPurple '║') $FUNCTION_HEADER_MENU_INFO_PUBLIC_LIST " $(display_public_status_on_or_off)
echo -ne "
$(ColorPurple '╠═══════════════════════════════════════════════')
$(ColorPurple '║') $FUNCTION_HEADER_MENU_INFO_CURRENT_NJORD_RELEASE $(check_menu_script_repo)
$(ColorPurple '║') $FUNCTION_HEADER_MENU_INFO_LOCAL_NJORD_VERSION $(ColorGreen ''"${mversion}"'')
$(ColorPurple '║') $FUNCTION_HEADER_MENU_INFO_GG_ZEROBANDWIDTH
$(ColorPurple '║') $FUNCTION_HEADER_MENU_INFO_1
$(ColorPurple '╚═══════════════════════════════════════════════')"
}

# Display the BepInEx information header.
function menu_header_bepinex_enable() {
clear
get_current_config
echo -ne "
$(ColorCyan '╔═════════════════════')$(ColorOrange 'BepInEx')$(ColorCyan '═══════════════════╗')
$(ColorCyan '║~~~~~~~~~~~~~~~~~~')$(ColorLightGreen '-Njord Menu-')$(ColorCyan '~~~~~~~~~~~~~~~~~║')
$(ColorCyan '╠═══════════════════════════════════════════════╝')
$(ColorCyan '║')$(ColorLightGreen ' Welcome to BepInEx Intergrated Menu System')
$(ColorCyan '║')$(ColorLightGreen ' BepInEx Support: https://discord.gg/MpFEDAg')
$(ColorCyan '║ '"$FUNCTION_HEADER_MENU_INFO_2"'')
$(ColorCyan '╠═══════════════════════════════════════════════')
$(ColorCyan '║ Mods:') $(are_mods_enabled)
$(ColorCyan '╠═══════════════════════════════════════════════')
$(ColorCyan '║') BepInEx Official Build:" $(check_bepinex_repo)
echo -ne "
$(ColorCyan '║') BepInEx Server Build:" $(check_local_bepinex_build)
echo -ne "
$(ColorCyan '╠═══════════════════════════════════════════════')
$(ColorCyan '║ '"$FUNCTION_HEADER_MENU_INFO_VALHEIM_OFFICIAL_BUILD"'')" $(check_official_valheim_release_build)
echo -ne "
$(ColorCyan '║ '"$FUNCTION_HEADER_MENU_INFO_VALHEIM_LOCAL_BUILD"' ')"        $(check_local_valheim_build)
echo -ne "
$(ColorCyan '╠═══════════════════════════════════════════════')"
echo -ne "
$(ColorCyan '║') $FUNCTION_HEADER_MENU_INFO_SERVER_NAME" ${currentDisplayName}
echo -ne "
$(ColorCyan '║') $FUNCTION_HEADER_MENU_INFO_LD_SEVER_SESSION" ${worldname}
echo -ne "
$(ColorCyan '║') $(are_you_connected)
$(ColorCyan '║')" $(display_public_IP)
echo -ne "
$(ColorCyan '║')" $(display_local_IP)
echo -ne "
$(ColorCyan '║') $FUNCTION_HEADER_MENU_INFO_SERVER_PORT " $(ColorGreen ''"${currentPort}"'')
echo -ne "
$(ColorCyan '║') $FUNCTION_HEADER_MENU_INFO_PUBLIC_LIST " $(display_public_status_on_or_off)
echo -ne "
$(ColorCyan '╠═══════════════════════════════════════════════')
$(ColorCyan '║') $FUNCTION_HEADER_MENU_INFO_CURRENT_NJORD_RELEASE $(check_menu_script_repo)
$(ColorCyan '║') $FUNCTION_HEADER_MENU_INFO_LOCAL_NJORD_VERSION $(ColorGreen ''"${mversion}"'')
$(ColorCyan '║') $FUNCTION_HEADER_MENU_INFO_GG_ZEROBANDWIDTH
$(ColorCyan '║') $FUNCTION_HEADER_MENU_INFO_1
$(ColorCyan '╚═══════════════════════════════════════════════')"
}

# Display the main server information header.
function menu_header() {
# Display service, Crossplay, player, firewall, and release status.
clear
get_current_config
echo -ne "
$(ColorOrange '╔══════════════════════════════════════════════════════════╗')
$(ColorOrange '║~~~~~~~~~~*****~~~~~~~~-Njord Menu-~~~~~~~~~*****~~~~~~~~~║')
$(ColorOrange '╠══════════════════════════════════════════════════════════╝')
$(ColorOrange '║'" $FUNCTION_HEADER_MENU_INFO_VALHEIM_OFFICIAL_BUILD"'')" $(check_official_valheim_release_build)
	echo -ne "
$(ColorOrange '║'" $FUNCTION_HEADER_MENU_INFO_VALHEIM_LOCAL_BUILD"' ') $(check_local_valheim_build)
$(ColorOrange '║')" $FUNCTION_HEADER_MENU_INFO_LD_SEVER_SESSION $(ColorGreen ''"${worldname}"'')
	echo -ne "
$(ColorOrange '║')" $FUNCTION_HEADER_MENU_INFO_SERVER_NAME $(ColorGreen ''"${currentDisplayName}"'')
	echo -ne "
$(ColorOrange '║') $(are_you_connected)
$(ColorOrange '║')" $(display_public_IP)
	echo -ne "
$(ColorOrange '║')" $(display_local_IP)
	echo -ne "
$(ColorOrange '║') $FUNCTION_HEADER_MENU_INFO_SERVER_PORT" $(ColorGreen ''"${currentPort}"'')
	echo -ne "
$(ColorOrange '║') $FUNCTION_HEADER_MENU_INFO_PUBLIC_LIST" $(ColorGreen ''"$(display_public_status_on_or_off)"'')
	echo -ne "
$(ColorOrange '║') $FUNCTION_HEADER_MENU_INFO_SERVER_AT_GLANCE" $(server_status) and $(server_substate)
	echo -ne "
$(ColorOrange '║') Crossplay status:" $(display_crossplay_status)
echo -ne "
$(ColorOrange '║') Crossplay Game Code:" $(display_last_join_code)
echo -ne "
$(ColorOrange '╠═══════════════════════════════════════════════════════════')"
echo -ne "
$(ColorOrange '║') Current Players Online:" $(current_player_count)
echo -ne "
$(ColorOrange '╠═══════════════════════════════════════════════════════════')"
	echo -ne "
$(ColorOrange '║') $FUNCTION_HEADER_MENU_INFO_SERVER_UFW" $(get_firewall_status)
	echo -ne "
$(ColorOrange '║') $FUNCTION_HEADER_MENU_INFO_SERVER_UFW_SUBSTATE -- substatus" $(get_firewall_substate)
	echo -ne "
$(ColorOrange '╠═══════════════════════════════════════════════════════════')"
	echo -ne "
$(ColorOrange '║') $FUNCTION_HEADER_MENU_INFO_CURRENT_NJORD_RELEASE $(ColorGreen ''"$(check_menu_script_repo)"'')
$(ColorOrange '║') $FUNCTION_HEADER_MENU_INFO_LOCAL_NJORD_VERSION $(ColorGreen ''"${mversion}"'')
$(ColorOrange '║') LD Version: $(ColorGreen ''"${ldversion}"'')
$(ColorOrange '║ '"$FUNCTION_HEADER_MENU_INFO"'')
$(ColorOrange '║ '"$FUNCTION_HEADER_MENU_INFO_1"'')
$(ColorOrange '║ '"$FUNCTION_HEADER_MENU_INFO_2"'')
$(ColorOrange '╚═══════════════════════════════════════════════════════════')"
}

# Select between the initial install and an additional world install.
function server_install_menu() {
	echo ""
	echo -ne "
$(ColorOrange ''"$FUNCTION_SERVER_INSTALL_MENU_HEADER"'')
$(ColorOrange '-')$(ColorGreen '1)') "$FUNCTION_SERVER_INSTALL_MENU_OPT_1."
$(ColorOrange '-')$(ColorGreen '2)') "Setup another Valheim server on diff port."
$(ColorOrange '-')$(ColorGreen '0)') "$RETURN_MAIN_MENU."
$(ColorOrange ''"$DRAW60"'')
$(ColorPurple ''"$CHOOSE_MENU_OPTION"'') "
    read a
    case $a in
	    1) newinstall="y"
	       valheim_server_install ;
		   server_install_menu ;;
		2) newinstall="n"
		   valheim_server_install ;
		   server_install_menu ;;
        0) menu ; menu ;;
		*)  echo -ne " $(ColorRed ''"$WRONG_MENU_OPTION"'')" ; server_install_menu ;;
    esac
}

# Display and process firewall administration options.
function firewall_admin_menu() {
	menu_header
	if [ "${usefw}" == "n" ] ; then
	    # Return to the main menu when firewall management is disabled. 
		echo ""
		echo "The firewall admin system is not enabled."
		echo "Please open the njordmenu.sh file and modify the header parameters to enable."
		echo "Returning to main menu."
		echo ""
		sleep 2
		menu
	else
	    # Process firewall status, port, service, and cleanup actions.
		echo -ne "
$(ColorOrange '"╔══Valheim Server Firewall Infomation and control Center═══╗"'')
$(ColorOrange '║~~~~~~~~~~~~~~~~~~')$(ColorLightGreen '-Njord Menu-')$(ColorCyan '~~~~~~~~~~~~~~~~~║')
$(ColorOrange '╠═══════════════════════════════════════════════╝')"
is_admin_firewall_installed
is_admin_firewall_enabled
is_any_firewall_installed
is_any_firewall_enabled
		echo -ne "
$(ColorOrange '╠═══════════════════════════════════════════════')
$(ColorOrange '║ "FireWallD actions for this Valheim server"'')
$(ColorOrange '╠═══════════════════════════════════════════════')
$(ColorOrange '║ ')$(ColorGreen '1)') Show system status
$(ColorOrange '║ ')$(ColorGreen '2)') Show system substate
$(ColorOrange '║ ')$(ColorGreen '3)') Dump all information on the firewall
$(ColorOrange '║ ')$(ColorGreen '4)') Add the Steam ports to the firewall
$(ColorOrange '║ ')$(ColorGreen '5)') Remove the Steam ports from the firewall
$(ColorOrange '║ ')$(ColorGreen '6)') Add this Valheim service port to the firewall
$(ColorOrange '║ ')$(ColorGreen '7)') Remove this Valheim service port from the firewall "
		if [ "${fwbeingused}" == "firewalld" ] ; then
		echo -ne "
$(ColorOrange '╠═══════════════════════════════════════════════')
$(ColorOrange ''"Specifc to FireWallD for this Valheim world."'')
$(ColorOrange '╠═══════════════════════════════════════════════')
$(ColorOrange '║ ')$(ColorGreen '50)') Create the service file
$(ColorOrange '║ ')$(ColorGreen '51)') Delete the service file
$(ColorOrange '║ ')$(ColorGreen '52)') Add the public service
$(ColorOrange '║ ')$(ColorGreen '53)') Remove the public service for Valheim server "
		fi
		echo -ne "
$(ColorOrange '╠═══════════════════════════════════════════════')
$(ColorOrange '║ "To help verify/install perfered firewall system"'')
$(ColorOrange '╠═══════════════════════════════════════════════')
$(ColorOrange '║ ')$(ColorGreen '100)') Verify/install the perfered firewall system.
$(ColorOrange '║ ')$(ColorGreen '101)') Verify/enable the prefered firewall system.
$(ColorOrange '║ ')$(ColorGreen '102)') Stop all known firewall systems.
$(ColorOrange '╠═══════════════════════════════════════════════')
$(ColorOrange '║ ')$(ColorGreen '0)') "$RETURN_MAIN_MENU."
$(ColorOrange '╠═══════════════════════════════════════════════')
$(ColorOrange '║ "$DRAW60"'')
$(ColorPurple '║ "$CHOOSE_MENU_OPTION"'')
$(ColorPurple '╚═══════════════════════════════════════════════')"
		read a
		case $a in
	    1) get_firewall_status ; firewall_admin_menu ;;
		2) get_firewall_substate ; firewall_admin_menu ;;
		3) get_firewall_moreinfo ; firewall_admin_menu ;;
		4) sftc="ste" ; add_Valheim_server_public_ports ; firewall_admin_menu ;;
		5) sftc="ste" ; remove_Valheim_server_public_ports ; firewall_admin_menu ;;
		6) sftc="val" ; add_Valheim_server_public_ports ; firewall_admin_menu ;;
		7) sftc="val" ; remove_Valheim_server_public_ports ; firewall_admin_menu ;;
		50) create_firewalld_service_file ; firewall_admin_menu ;;
		51) delete_firewalld_service_file ; firewall_admin_menu ;;
		52) add_firewalld_public_service ; firewall_admin_menu ;;
		53) remove_firewalld_public_service ; firewall_admin_menu ;;
		100) is_admin_firewall_installed ; firewall_admin_menu ;;
		101) is_admin_firewall_enabled ; firewall_admin_menu ;;
		102) disable_all_firewalls ; firewall_admin_menu ;;
        0) menu ; menu ;;
		*)  echo -ne " $(ColorRed ''"$WRONG_MENU_OPTION"'')" ; firewall_admin_menu ;;
		esac
	fi
}



# Display diagnostic and troubleshooting options.
function tech_support(){
	menu_header
	echo ""
	echo -ne "
$(ColorOrange ''"$FUNCTION_VALHEIM_TECH_SUPPORT_HEADER"'')
$(ColorOrange '-')$(ColorGreen ' 1)') $FUNCTION_VALHEIM_TECH_SUPPORT_DISPLAY_CONFIG
$(ColorOrange '-')$(ColorGreen ' 2)') $FUNCTION_VALHEIM_TECH_SUPPORT_DISPLAY_VALHEIM_SERVICE
$(ColorOrange '-')$(ColorGreen ' 3)') $FUNCTION_VALHEIM_TECH_SUPPORT_DISPLAY_WORLD_DATA
$(ColorOrange '-')$(ColorGreen ' 4)') $FUNCTION_VALHEIM_TECH_SUPPORT_DISPLAY_SYSTEM_INFO
$(ColorOrange '-')$(ColorGreen ' 5)') $FUNCTION_VALHEIM_TECH_SUPPORT_DISPLAY_NETWORK_INFO
$(ColorOrange '-')$(ColorGreen ' 6)') $FUNCTION_VALHEIM_TECH_SUPPORT_DISPLAY_CONNECTED_PLAYER_HISTORY
$(ColorOrange '-')$(ColorGreen ' 7)') Show World Seed
$(ColorOrange '-')$(ColorGreen ' 8)') System preformance (TOP)
$(ColorOrange '------------------------------------------------------------')
$(ColorOrange '-')$(ColorGreen ' 0)') "$RETURN_MAIN_MENU"
$(ColorOrange '------------------------------------------------------------')
$(ColorPurple ''"$CHOOSE_MENU_OPTION"'') "
        read a
		# Process the selected diagnostic action.
        case $a in
			1) display_start_valheim ; tech_support ;;
			2) display_valheim_server_status ; tech_support ;;
	        3) display_world_data_folder ; tech_support ;;
			4) display_system_info ; tech_support ;;
			5) display_network_info ; tech_support ;;
	        6) display_player_history ; tech_support ;;
			7) get_worldseed ; tech_support ;;
			8) top -u steam ; tech_support ;;
			0) menu ; menu ;;
		    *)  echo -ne " $(ColorRed ''"$WRONG_MENU_OPTION"'')" ; tech_support ;;
        esac
}

# Display and process the main Njord administration menu.
menu(){
    # Select a default world before displaying the menu.
	if [ "${worldname}" = "" ] ; then  set_world_server ; fi
	menu_header
	echo -ne "
$(ColorOrange '-'"$FUNCTION_MAIN_MENU_CHECK_SCRIPT_UPDATES_HEADER"' ')
$(ColorOrange '-')$(ColorGreen ' 1)') $FUNCTION_MAIN_MENU_UPDATE_NJORD_MENU
$(ColorOrange ''"$FUNCTION_MAIN_MENU_SERVER_COMMANDS_HEADER"'')
$(ColorOrange '-')$(ColorGreen ' 2)') $FUNCTION_MAIN_MENU_TECH_MENU
$(ColorOrange '-')$(ColorGreen ' 3)') $FUNCTION_MAIN_MENU_INSTALL_VALHEIM
$(ColorOrange ''"$FUNCTION_MAIN_MENU_FIREWALL_VALHEIM_HEADER"'')
$(ColorOrange '-')$(ColorGreen ' 4)') $FUNCTION_MAIN_MENU_FIREWALL_VALHEIM
$(ColorOrange ''"$FUNCTION_MAIN_MENU_OFFICAL_VALHEIM_HEADER"'')
$(ColorOrange '-')$(ColorGreen ' 5)') $FUNCTION_MAIN_MENU_CHECK_APPLY_VALHEIM_UPDATES
$(ColorOrange ''"$FUNCTION_MAIN_MENU_EDIT_VALHEIM_CONFIG_HEADER"'')
$(ColorOrange '-')$(ColorGreen ' 6)') $FUNCTION_MAIN_MENU_EDIT_VALHEIM_DISPLAY_CONFIG
$(ColorOrange '-')$(ColorGreen ' 7)') $FUNCTION_MAIN_MENU_EDIT_VALHEIM_CHANGE_WORLD_NAME
$(ColorOrange '-')$(ColorGreen ' 8)') $FUNCTION_MAIN_MENU_EDIT_VALHEIM_CHANGE_PUBLIC_NAME
$(ColorOrange '-')$(ColorGreen ' 9)') $FUNCTION_MAIN_MENU_EDIT_VALHEIM_CHANGE_SERVER_PORT
$(ColorOrange '-')$(ColorGreen ' 10)') $FUNCTION_MAIN_MENU_EDIT_VALHEIM_CHANGE_ACCESS_PASS
$(ColorOrange '-')$(ColorGreen ' 11)') $FUNCTION_MAIN_MENU_EDIT_VALHEIM_ENABLE_PUBLIC_LISTING
$(ColorOrange '-')$(ColorGreen ' 12)') $FUNCTION_MAIN_MENU_EDIT_VALHEIM_DISABLE_PUBLIC_LISTING
$(ColorOrange '-')$(ColorGreen ' 13)') Set Crossplay options
$(ColorOrange ''"$DRAW60"'')
$(ColorOrange '-')$(ColorGreen ' 14)') $FUNCTION_ADMIN_TOOLS_MENU_STOP_SERVICE
$(ColorOrange '-')$(ColorGreen ' 15)') $FUNCTION_ADMIN_TOOLS_MENU_START_SERVICE
$(ColorOrange '-')$(ColorGreen ' 16)') $FUNCTION_ADMIN_TOOLS_MENU_RESTART_SERVICE
$(ColorOrange '-')$(ColorGreen ' 17)') $FUNCTION_ADMIN_TOOLS_MENU_STATUS_SERVICE
$(ColorOrange ''"$DRAW60"'')
$(ColorOrange '-')$(ColorGreen ' 18)') $FUNCTION_MAIN_MENU_EDIT_VALHEIM_BACKUP_WORLD_DATA
$(ColorOrange '-')$(ColorGreen ' 19)') $FUNCTION_MAIN_MENU_EDIT_VALHEIM_RESTORE_WORLD_DATA
$(ColorOrange ''"$FUNCTION_MAIN_MENU_EDIT_VALHEIM_MODS_HEADER"'')
$(ColorOrange '-')$(ColorGreen ' 20)') $FUNCTION_MAIN_MENU_EDIT_VALHEIM_MODS_MSG_YES_BEP
$(ColorOrange ''"$DRAW60"'')
$(ColorOrange '-')$(ColorGreen ' 99)') " $FUNCTION_MAIN_MENU_LD_CHANGE_SESSION_CURRENT_WORLD
[ -f "$worldfilelist" ] || echo -ne "
$(ColorOrange '-')$(ColorGreen ' 0000)') " Upgrade Old Menu to New Njord Menu
echo -ne "
$(ColorOrange ''"$DRAW60"'')
$(ColorGreen ' 0)') $FUNCTION_MAIN_MENU_EDIT_VALHEIM_EXIT
$(ColorOrange ''"$DRAW60"'')
$(ColorPurple ''"$CHOOSE_MENU_OPTION"'') "
        read a
		# Route the selected option to the requested administration function.
        case $a in
			1) script_check_update ; menu ;;
			2) tech_support ; menu ;;
			3) server_install_menu ; menu ;;
			4) firewall_admin_menu ; menu ;;
			5) confirm_check_apply_server_updates ; menu ;;
			6) display_full_config ; echo "BACK TO MENU IN 5 SECONDS" ; sleep 5 ; menu ;;
			7) change_local_world_name ; menu ;;
			8) change_public_display_name ; menu ;;
			9) change_default_server_port ; menu ;;
			10) change_server_access_password ; menu ;;
			11) write_public_on_config_and_restart ; menu ;;
			12) write_public_off_config_and_restart ; menu ;;
			13) change_crossplay_status ; menu ;;
			14) stop_valheim_server ; menu ;;
			15) start_valheim_server ; menu ;;
			16) restart_valheim_server ; menu ;;
			17) display_valheim_server_status ; menu ;;
			18) backup_world_data ; menu ;;
			19) restore_world_data ; menu ;;
			20) bepinex_menu ; bepinex_menu ;;
			99) request99="y" ; set_world_server ; menu ;;
			0000) get_current_config_upgrade_menu ; menu ;;
			0) exit 0 ;;
			*)  echo -ne " $(ColorRed 'Wrong option.')" ; menu ;;
        esac
}
# Run the interactive menu or execute a supported command shortcut.
if [ $# = 0 ]; then
    menu
else
    case "$1" in
    start)   start_valheim_server ;;
    stop)    stop_valheim_server  ;;
    restart) restart_valheim_server ;;
    update)  check_apply_server_updates_beta ;;
    backup)  backup_world_data ;;
    status)  display_valheim_server_status ;;
    *)
        menu
        ;;
    esac
fi
########################################################################
############################MENU SECTION END############################
########################################################################
