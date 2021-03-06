#!/bin/bash

if [ -z "$WORKSPACE_ROOT" ]; then
    WORKSPACE_ROOT=$(cd `dirname $0`; pwd)
fi
echo "Using workspace root of $WORKSPACE_ROOT"

# delete old files
echo Cleaning up old workspace files...
for f in .rosinstall* devel build; do
    [ -f $f ] && echo "rm -iv $f" && rm -i $f
    [ -d $f ] && echo "rm -Irv $f" && rm -Ir $f
done
echo

# find an installation of ROS
ROS_DISTRO="kinetic"

# Check to see if this distro actually exists
if [ ! -r /opt/ros/$ROS_DISTRO/setup.sh ]; then
    echo "Directory /opt/ros/$ROS_DISTRO does not exists!"
    exit 1
fi

echo " Source the base $ROS_DISTRO setup for clean install ..."
source /opt/ros/$ROS_DISTRO/setup.sh
echo

# make sure package dependencies are installed
source $WORKSPACE_ROOT/rosinstall/install_scripts/install_package_dependencies.sh

# initialize workspace
if [ ! -f ".rosinstall" ]; then
    wstool init .
fi

# merge rosinstall files from rosinstall/*.rosinstall
for file in $WORKSPACE_ROOT/rosinstall/*.rosinstall; do
    filename=$(basename ${file%.*})
    if [ -n "$WORKSPACE_CHRIS_NO_SIM" ] && [ $filename == "chris_simulation" ]; then
        continue;
    else
        echo "Merging to workspace: '$filename'.rosinstall"
        wstool merge $file -y
    fi
done
echo


# update workspace
wstool update
echo

# install dependencies
rosdep update
rosdep install -r --from-path . --ignore-src

echo

# generate top-level setup.bash
cat >setup.bash <<EOF
#!/bin/bash
# automated generated file
#export ROS_HOSTNAME=$HOSTNAME
export ROS_HOSTNAME=localhost
export ROS_MASTER_URI=http://localhost:11311
. $WORKSPACE_ROOT/devel/setup.bash
echo "Set up ROS workspace for \$WORKSPACE_ROOT@\$ROS_HOSTNAME"
EOF

. $WORKSPACE_ROOT/setup.bash

# invoke make for the initial setup
catkin build
echo

echo "Create a folder to hold log files ..."
mkdir -p $WORKSPACE_ROOT/logs

# Initialization successful. Print message and exit.
cat <<EOF

===================================================================

Workspace initialization completed.
You can setup your current shell's environment by entering

    source $WORKSPACE_ROOT/setup.bash

or by executing the below command to add the workspace setup to your
.bashrc file for automatic setup on each invocation of an interactive shell:

    echo "source $WORKSPACE_ROOT/setup.bash" >> ~/.bashrc

ROS Networking Note:
This setup.bash script sets the ROS_HOSTNAME and ROS_MASTER_URI of this machine to "localhost",
which assumes single computer usage.

For multiple machine use, you may need to change the ROS_HOSTNAME to the
HOSTNAME of this machine, and specify the ROS_MASTER_URI properly by
editing $WORKSPACE_ROOT/setup.bash

You can modify your workspace config (e.g. for adding additional repositories or
packages) by using the wstool command (http://wiki.ros.org/wstool).
See the system install scripts in $WORKSPACE_ROOT/rosinstall/install_scripts and
example rosinstall files in $WORKSPACE_ROOT/rosinstall/optional for example usage.

===================================================================

EOF

