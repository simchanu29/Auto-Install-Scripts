#!/usr/bin/env bash

####
# 
#   /!\  This is an example and does not work by itself  /!\
#  
####

# Global variables
WS_ROOT=$PWD
INSTALL_CAN="0"
FLAG="$1"
ARGS="${@:2}"

function setup_can () {
    echo "[CAN INSTALL] Setting up CAN connection"
    CAN_NAME="can0"
    echo "[CAN INSTALL] Creating $CAN_NAME interface"
    ip link set $CAN_NAME up type can bitrate 1000000
    crontab install_files/crontabfile
}

function create_workspace () {
    # Recreate workspace
    rm $WS_ROOT/src/CMakeLists.txt
    cd $WS_ROOT/src/
    catkin_init_workspace
    cd $WS_ROOT
}

function import_gitmodules () {
    # Import git submodules
    git submodule init
    git submodule update
    git submodule foreach 'git checkout master' #commentez ou décommentez cetle ligne au besoin
}

function install_ros_kinetic () {
    # from http://wiki.ros.org/kinetic/Installation/Ubuntu
    sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
    sudo apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key 421C365BD9FF1F717815A3895523BAEEB01FA116
    sudo apt-get update
    sudo apt-get install -y ros-kinetic-desktop
    # sudo apt-get install -y ros-kinetic-ros-base
    sudo rosdep init
    rosdep update
    echo "source /opt/ros/kinetic/setup.bash" >> ~/.bashrc
    source ~/.bashrc
}

function install_ws_dep () {
    # Simulation for now
    rosdep install --simulate --from-paths $WS_ROOT/src --ignore-src
    echo -n "Do you want to install these packages (y/n)? "; read answer
    if [ "$answer" != "y" ]; then return 0; fi # exit
}

function help_text () {
    echo ""
    echo "xxx_install [flag [options]]"
    echo "Arguments"
    echo "-h : show help and exit"
    echo "-i : install additional feature"
    echo "    can : set up can interface"
    echo ""
    echo "example : xxx_install -i can"
    echo ""
}

function task_handler () {
    TASK=$1
    EXEC=$2
    INSTALL="install"

    # echo "$EXEC=$INSTALL"

    case $TASK in
    "create_ws")
        echo "Create CMakeLists.txt to create the ROS workspace"
        if [ "$EXEC" = "$INSTALL" ]; then echo ""; create_workspace; fi
    ;;
    "shell_init")
        if [ "$EXEC" = "$INSTALL" ]; then echo ""; xxx_init; fi
        echo "Initialize environnement variables for ROS"
    ;;
    "gitmodules_init")
        echo "Init and update git submodules"
        if [ "$EXEC" = "$INSTALL" ]; then echo ""; import_gitmodules; fi
    ;;
    "can_if_init")
        echo "Set up the network interface for can with cron at reboot"
        if [ "$EXEC" = "$INSTALL" ]; then echo ""; setup_can; fi
    ;;
    "compile")
        echo "Run catkin_make"
        if [ "$EXEC" = "$INSTALL" ]; then echo ""; catkin_make; fi
    ;;
    "install_ros_kinetic")
        echo "Install ros kinetic dekstop version (with gui tools)"
        if [ "$EXEC" = "$INSTALL" ]; then echo ""; install_ros_kinetic; fi
    ;;
    "install_ws_dep")
        echo "Install packages dependencies with rosdep"
        if [ "$EXEC" = "$INSTALL" ]; then echo ""; install_ws_dep; fi
    ;;
    *)
        echo "TASK : $TASK"
        echo "No task scheduled or task unknown"
    ;;
    esac
}

function main () {

    # base tasks
    TASKS=("create_ws" "gitmodules_init" "install_ws_dep" "compile" "shell_init")

    # Arguments handler
    if [ "$FLAG" == "-h" ] || [ "$FLAG" == "--help" ]
    then
        help_text
        return 0
    elif [ "$FLAG" == "-i" ] || [ "$FLAG" == "--install" ]
    then
        for ARG in $ARGS
        do
            if [ $ARG = "can" ]
            then
                echo "Adding can_if_setup to TASKS"
                TASKS="$TASKS can_if_setup"
            fi
        done
    fi

    # Check if inside a catkin workspace
    if [ ! -f $WS_ROOT/.catkin_workspace ]; then
        echo "[ERROR] You must run this command at the root of a ROS workspace"
        return 1
    fi

    # If ros isn't installed then add install_ros to tasks
    if [ ! "`rosversion -d`" = "kinetic" ]; then
      echo "Adding install_ros_kinetic to TASKS"
        TASKS="$TASKS install_ros_kinetic"
    fi

    # Check internet connection
    echo ""
    echo -e "\e[1m\e[32m==> \e[1m\e[37mChecking if the computer is connected to the internet:\e[0m"
    CONNECTION=$(ping -q -c 2 www.ubuntu.com > /dev/null && echo 0 || echo 1)
    if [ ${CONNECTION} -eq 0 ]; then
        echo -e "\e[1m\e[92m  --> Connected to the internet!\e[0m"
    else
        echo -e "\e[1m\e[31m  --> Not connected to the internet!\e[0m"
        echo -e "\e[1m\e[31m  --> Exiting program!\e[0m"
        return 0
    fi

    # Warning and prompt for the user
    echo ""
    echo "This script will do the following tasks : "
    NB=0
    for TASK in ${TASKS[@]}
    do
        NB=$((NB+1))
        echo " $NB. Running $TASK"
        echo "        "`task_handler $TASK` # print help by default
    done
    echo -n "Do you want to continue (y/n)? "; read answer
    if [ "$answer" != "y" ]; then return 0; fi # exit

    # Installation
    NB=0
    for TASK in ${TASKS[@]}
    do
        NB=$((NB+1))
        echo ""
        echo "###"
        echo "# $NB. $TASK"
        echo "###"
        echo ""
        task_handler $TASK install
    done
}

main
