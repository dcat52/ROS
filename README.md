# Base ROS install folder

## Pre-Setup

Follow ROS Kinetic Kame install instructions from here:
http://wiki.ros.org/ROS/Installation

Other dependencies:
TBD

## Setup

Create a directory for the custom ros install
Clone the ROS-base repo to the directory
```
mkdir -p ./path-for-custom-ros-folder
cd ./path-for-custom-ros-folder
git clone http://github.com/dcat52/ROS.git .
```

Run install script which will pull from chris_scripts*
```
./install.sh
```

Add the setup.bash to be sourced in the .bashrc
Then resource the .bashrc
```
echo "source $PWD/setup.bash" >> ~/.bashrc
source ~/.bashrc
```

Try to build the packages
```
catkin build
```

## Test

Verify custom ROS directory is setup correctly
```
roscd
```
You should now be located within ./path-for-custom-ros-folder/src
(Note addition of "/src" to the directory)

Congrats!

## Notes and Credits

*chris_scripts was developed as a part of CNU CHRISLab
