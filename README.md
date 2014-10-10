hadoop-installer
================

A simple shell script to install hadoop on an Amazon EC2 ubuntu instance, or a fresh install of ubuntu server 14.04.1 in a VM

To use: 
1: Download the shell file (wget babbage.cs.missouri.edu/~sggtgb/hadoop-installer.sh)
2: chmod +x hadoop-installer.sh
3: ./hadoop-installer.sh

it will ask you to enter your password for sudo permissions (if in a vm, the EC2s dont do this) and then ask you which 
items you wish to install.  

The installation itself will take a few minutes, especially the Pig download.  

