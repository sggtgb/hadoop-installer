#!/bin/bash

# written by Scott G Gavin 
# Oct 8 2014

#This code is designed to work with the Amazon AWS EC2 Ubuntu instance to 
#create a hadoop cluster using Pig and Hive, as desired.  It is version specific,
#and only designed to work with Ubuntu ________, and as such is not tested in other
#distributions or instances.
#All rights reserved

cd $HOME
clear
#these are here to make the link locations easy to change if desired
hadoop_link="http://www.interior-dsgn.com/apache/hadoop/common/hadoop-1.2.1/hadoop-1.2.1.tar.gz"
pig_link="http://apache.petsads.us/pig/pig-0.13.0/pig-0.13.0.tar.gz"
hive_link="http://apache.spinellicreations.com/hive/hive-0.12.0/hive-0.12.0.tar.gz"

#arrays
link[0]=$hadoop_link
link[1]=$pig_link
link[2]=$hive_link
name[0]="hadoop-1.2.1"
name[1]="pig-0.13.0"
name[2]="hive-0.12.0"
tarName[0]="hadoop-1.2.1.tar.gz"
tarName[1]="pig-0.13.0.tar.gz"
tarName[2]="hive-0.12.0.tar.gz"
#variables
num=3
flag=0

bashrc="export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64/"
sedPath=$bashrc
echo $sedPath
#make sure the user is running as root for the installations
if [ $EUID -eq 0 ]; then
{
	SUDO=''
}
else
{
	SUDO="sudo"
}
fi

sudo echo ""
#commands.  Makes it easy to make the commands verbose or quite. and ensure sudo
update="$SUDO apt-get -y update"
java="$SUDO apt-get -y install openjdk-7-jre-headless"
ssh="$SUDO apt-get -y install openssh-server"
wget="wget -q"
tar="tar -xzf"

while [ $flag -ne 1 ]
do
	printf "Install Hadoop? [Y/n] "
	read Hadoop
	if [ "$Hadoop" == 'Y' ] || [ "$Hadoop" == 'y' ]; then
	{
		Hadoop=1
		bashrc=$bashrc"\nexport HADOOP_INSTALL=\"$HOME/${name[0]}\"\n"
		bashrc=$bashrc'export PATH=$PATH:$HADOOP_INSTALL/bin:$HADOOP_INSTALL/sbin\n'
		flag=1
	}
	elif [ "$Hadoop" == 'N' ] || [ "$Hadoop" == 'n' ]; then
	{
		Hadoop=0
		printf "Hadoop must be installed for Pig and Hive to function. Continue anyways? [Y/n] "
		read confirm
		if [ "$confirm" == 'Y' ] || [ "$confirm" == 'y' ]; then
		{
			flag=1
		}
		fi
	}
	else
	{
		printf "Unexpected Input\n"
	}
	fi
done
flag=0
while [ $flag -ne 1 ]
do
        printf "Install Pig? [Y/n] "
        read Pig
        if [ "$Pig" == 'Y' ] || [ "$Pig" == 'y' ]; then
        {
                Pig=1
		bashrc=$bashrc"export PIG_INSTALL=$HOME/${name[1]}\n"
		bashrc=$bashrc'export PATH=$PATH:$PIG_INSTALL/bin\n'
                flag=1
        }
        elif [ "$Pig" == 'N' ] || [ "$Pig" == 'n' ]; then
        {
                Pig=0
                flag=1
        }
        else
        {
                printf "Unexpected Input\n"
        }
        fi
done
flag=0
while [ $flag -ne 1 ]
do
        printf "Install Hive? [Y/n] "
        read Hive
	#comment this out after HW 7 is done
	#Hive='n'
        if [ "$Hive" == 'Y' ] || [ "$Hive" == 'y' ]; then
        {
                Hive=1
		bashrc=$bashrc"export HIVE_INSTALL=$HOME/${name[2]}\n"
		bashrc=$bashrc'export PATH=$PATH:$HIVE_INSTALL/bin\n'
                flag=1
        }
        elif [ "$Hive" == 'N' ] || [ "$Hive" == 'n' ]; then
        {
                Hive=0
                flag=1
        }
        else
        {
                printf "Unexpected Input\n"
        }
        fi
done
flag=0

#this could be more efficient but im lazy
install[0]=$Hadoop
install[1]=$Pig
install[2]=$Hive

#update and install java
printf "\nUpdating the system..."
$update > /dev/null
printf "\t\t\tDone\nInstalling Java..."
$java > /dev/null
printf "\t\t\tDone\n"

#download the tar.gz files needed
for ((flag=0; flag<num; flag++)) {
	if [ ${install[$flag]} -eq 1 ]; then
	{
		printf "Downloading ${tarName[$flag]}..."
		$wget ${link[$flag]}
		printf "\tDone\nUn-tarring ${tarName[$flag]}... "
		$tar ${tarName[$flag]}	
		printf "\tDone\nCleaning ${tarName[$flag]}..."
		rm ${tarName[$flag]}
		printf "\t\tDone\n"
	}
	fi
}
#install and configure ssh keys
printf "Setting up SSH..."
$ssh > /dev/null 
ssh-keygen -q -t rsa -P "" -f ~/.ssh/id_rsa
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
printf "\t\t\tDone\n"
printf "Editing config files for:\n\t"
if [ ${install[0]} -eq 1 ]; then 
{
	printf "Hadoop:\n\t\t"
	printf "hadoop-env.sh"
		cd $HOME/${name[0]}/conf/
		printf "\n$sedPath\n" >> hadoop-env.sh
	printf "\tDone\n\t\t"
	printf "core-site.xml"
		cp core-site.xml core-site.xml.bak
		head -4 core-site.xml.bak > core-site.xml
		printf "\n<configuration>\n\t<property>\n\t\t<name>fs.default.name</name>\n\t\t<value>hdfs://localhost</value>\n\t</property>\n</configuration>" >> core-site.xml
	printf "\tDone\n\t\thdfs-site.xml"
		cp hdfs-site.xml hdfs-site.xml.bak
		head -4 hdfs-site.xml.bak > hdfs-site.xml
		printf "\n<configuration>\n\t<property>\n\t\t<name>dfs.replication</name>\n\t\t<value>1</value>\n\t</property>\n</configuration>" >> hdfs-site.xml
	printf "\tDone\n\t\tmapred-site.xml"
		cp mapred-site.xml mapred-site.xml.bak
		head -4 mapred-site.xml.bak > mapred-site.xml
		printf "\n<configuration>\n\t<property>\n\t\t<name>mapred.job.tracker</name>\n\t\t<value>localhost:8021</value>\n\t</property>\n</configuration>" >> mapred-site.xml
	printf "\tDone\n\tDone\n\t"
}
fi

if [ ${install[2]} -eq 1 ]; then
{
	printf "Hive:\n\t\t"
	printf "Hive configs will be implemented after I do lab 7.1\n\tDone\n"
}
fi

printf "Done\n"


#remember to >> this to the ~/.bashrc
printf "Editing bashrc file...\t\t\t"
printf "$bashrc" >> ~/.bashrc
printf "Done\n"
source ~/.bashrc
printf "\nInstallations complete\n"
exit

