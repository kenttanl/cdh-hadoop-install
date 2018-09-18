#!/bin/bash
#shopt -s -o nounset
#set -o xtrace
set -o nounset
usage(){
    echo  "usage: ./check.sh and type your choice"
}
SCRIPT=`readlink -f $0`
basedir=`dirname $SCRIPT`
hosts=`cat $basedir/conf/hosts|grep -v '^#'`

Manager=`$basedir/conf/config.py "Manager_IP"`
username=`$basedir/conf/config.py "username"`
password=`$basedir/conf/config.py "password"`

LocalIp=`ip addr | grep "inet " | cut -b 10-| cut -f 1 -d "/"| grep -v '^127.0.0.1'`
#echo "LocalIp=$LocalIp"
if [ "$username" == '' ];then
	username=`eval echo "$USER"`
fi
localpath=`eval echo ~$username`

source $basedir/bin/col.sh
if [ "$Manager" == "" ];then
	Manager=$LocalIp
fi
while [ 1 -eq 1 ]
	do
	echo "1. Config ssh"
	echo "2. Check and config system enviroment"
	echo "3. stop cloudera agent"
	echo "4. start cloudera agent"
	echo "5. clear SSH"
	echo "6. exit"
	echo -n "${bldblu}Please choose [1,2,3,4,5 or 6]:${txtrst}" 
	read choice
	if [ "$LocalIp" != "$Manager" ];then
		echo "${bldred} please run this script on manager server ${txtrst}"
		exit
	else
		if   [ "$choice" == "1" ]; then
			echo "${bldwht}Do you want Config ssh from $Manager to${txtrst}"
			for h in $hosts
			do 
				echo   "     * $h"
			done 
			for ((i=1; i<=5 ; i++))
			do
				echo -n "${bldblu}Pls type [y|n]${txtrst}:"
				read userchoice
				if [ "$userchoice" == "y" ] || [ "$userchoice" == "Y" ];then
					if [ "$password" == '' ];then
 						echo  -n "${bldblu}please enter your password:${txtrst}"
						read -s password
					fi
					#localpath=`eval echo ~$username`
					echo " "
					echo  "${bldwht}testing user's connnectivity,please wait......${txtrst}" | tee $basedir/log/ssh_config.txt
					for h in $hosts
					do
			       		   if [ "$h" == "$Manager" ];then
				      		 continue;
				  	else
						expect $basedir/bin/usertest.exp $h $username $password >> $basedir/log/ssh_config.txt 2>&1
 																
					    if [ "$?" =  "0" ]; then
						 echo "${bldgrn}user connectivity testing passed ${txtrst}" | tee -a $basedir/log/ssh_config.txt
						 break
				            else 
						 echo "${bldred}please check whether your password is correct or your username and password is matched${txtrst}" | tee -a $basedir/log/ssh_config.txt
						 exit
				            fi
				        fi
		  			done

					#if [ "$LocalIp" == "$Manager" ];then	
	 				echo  "${bldwht}**********************Generating $Manager's key***********************${txtrst}" | tee -a $basedir/log/ssh_config.txt	
					if sudo -u $username test -e $localpath/.ssh/*.pub;then  						
						echo "${bldgrn}The key on $Manager has exist${txtrst}" | tee -a $basedir/log/ssh_config.txt
					else 
						sudo -u $username ssh-keygen -t rsa -P '' -f $localpath/.ssh/id_rsa	
						if [ "$?" != "0" ];then
							echo  "${bldred}Generate the key on $Manager failed !${txtrst}" | tee -a $basedir/log/ssh_config.txt
							exit
						else
							echo  "${bldgrn}The key on $Manager has generated${txtrst}" | tee -a $basedir/log/ssh_config.txt
						fi
					fi
                               		 pubkeyfile=`ls $localpath/.ssh/*.pub`
					#pubkeyfile='/home/ABS_CORP/sm98/.ssh/id.pub'
					echo  "${bldwht}**********************Delivering key ************************************${txtrst}"| tee -a $basedir/log/ssh_config.txt
					for h in $hosts
					do			
						echo  "${bldwht}Delivering $Manager's key to $h...... ${txtrst}" | tee -a $basedir/log/ssh_config.txt
						expect $basedir/bin/ssh_keydelivery.exp $username $password $h $pubkeyfile >> $basedir/log/ssh_config.txt 2>&1
						#result=`expect $basedir/bin/ssh_keydelivery.exp $username $password $h $localpath`
						if [ "$?" != "0" ];then
							echo  "${bldred}Deliver $Manager's key to $h failed,please check the Verify result.${txtrst}" | tee -a $basedir/log/ssh_config.txt
						else
							echo  "${bldgrn}Deliver $Manager's key to $h successfully ${txtrst}" | tee -a $basedir/log/ssh_config.txt
						fi
					done
					echo  "${bldwht}**********************Verify ssh without password login******************${txtrst}" | tee -a $basedir/log/ssh_config.txt
					for h in $hosts
					do
						echo  "${bldgrn}Verify from $Manager ssh to $h...... ${txtrst}" | tee -a $basedir/log/ssh_config.txt
						expect $basedir/bin/ssh_verify.exp $h  $username >> $basedir/log/ssh_config.txt 2>&1
						if [ "$?" != "0" ];then
							echo  "${bldred}From $Manager ssh to $h failed! details please read the ssh config log.${txtrst}" | tee -a $basedir/log/ssh_config.txt
						else
							echo  "${bldgrn}From $Manager ssh to $h successful${txtrst}" | tee -a $basedir/log/ssh_config.txt
						fi
						
					done
					echo  "${bldwht}**********************ssh configure finished ****************************${txtrst}"| tee -a $basedir/log/ssh_config.txt
					break
				elif [ "$userchoice" == "n" ] || [ "$userchoice" == "N" ] 
					then break
				fi
				done
				continue;
		elif   [ "$choice" == "2" ]; then
        		echo   "${bldwht}Do you want to Check and config system enviroment on${txtrst}"
			for h in $hosts
			do
				echo   "      * $h"
			done

			for ((i=1; i<=5 ; i++))
			do
				echo -n "${bldblu}Pls type [y|n]${txtrst}:"
				read userchoice
				if [ "$userchoice" == "y" ] || [ "$userchoice" == "Y" ];then
					for h in $hosts
					do
					echo "${bldcyn}********************* $h****************************************${txtrst}"
					echo "${bldwht}sync hosts${txtrst}"
					#synchronize hosts file
					scp -q /etc/hosts $h:/tmp/;
					ssh $h "sudo cp /etc/hosts /etc/hosts_bak"
					ssh $h "sudo mv /tmp/hosts /etc/"
					#add repository file 
					#scp -q $basedir/conf/Cloudera.repo $h:/tmp/;
					#ssh $h "sudo mv /tmp/Cloudera.repo /etc/yum.repos.d/; sudo chown root.root /etc/yum.repos.d/Cloudera.repo";
					#scp -q $basedir/conf/CentOS-Base.repo $h:/tmp/;
					#ssh $h "sudo rm -f /etc/yum.repos.d/Cloudera.repo;sudo mv /tmp/CentOS-Base.repo /etc/yum.repos.d/; sudo chown root.root /etc/yum.repos.d/CentOS-Base.repo";
					
					#config limit.conf
					echo "${bldwht}limits check${txtrst}"
					ssh $h "grep -q '*    -    nofile    32768' /etc/security/limits.conf";
						if [ "$?"  != "0"  ]; then
							ssh $h "echo  '*    -    nofile    32768' | sudo tee -a /etc/security/limits.conf "
						fi
					#config selinux
					echo "${bldwht}selinux check${txtrst}"
                                        ssh $h "sudo sestatus| sed -n '1p';sudo sestatus|sed -n '5p';grep -q 'SELINUX=disabled' /etc/selinux/config"
                		             if [ "$?" != "0"  ]; then
					       ssh $h "sudo sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config;sudo sed -i 's/SELINUX=permissive/SELINUX=disabled/' /etc/selinux/config;"
					       echo "${bldred} $h selinux not be disabled,so must restart because of selinux!${txtrst}"
                             		     else 
						 ssh $h " sudo sestatus| sed -n '1p' | grep 'SELinux status:                 disabled'"
                		                 if [ "$?" != "0"  ]; then
					         echo "${bldred} $h selinux not be disabled,so must restart because of selinux!${txtrst}"	
					         fi
                                             fi
					
					#config iptables
					echo "${bldwht}firewall check${txtrst}"
					ssh $h "sudo systemctl disable firewalld;sudo systemctl stop firewalld;sudo systemctl status firewalld | sed -n '2,3p'"
					#config ntpd
                                        echo "${bldwht}ntpd check${txtrst}"
					ssh $h "sudo systemctl status ntpd.service | sed -n '2,3p';sudo systemctl enable ntpd.service;sudo systemctl start ntpd.service"
					#config swappiness
					echo "${bldwht}swappiness check${txtrst}"
					ssh $h "sudo /sbin/sysctl vm.swappiness | grep 'vm.swappiness = 0'";
					     if [ "$?"  != "0"  ]; then
					         echo "${bldpur}config swappiness${txtrst}"
						 ssh $h "sudo sysctl vm.swappiness=0;"
					         ssh $h "grep -q 'vm.swappiness = 0' /etc/sysctl.conf"
					             if [ "$?"  != "0"  ]; then
							ssh $h "echo 'vm.swappiness = 0'| sudo tee -a /etc/sysctl.conf"
						     fi
                        		          #    echo "${bldred} $h config vm.swappiness failed!${txtrst}"
                                     	     fi
					#check hugepage
					echo "${bldwht}transparent_hugepage check${txtrst}"
					hugepage1=`ssh $h "cat /sys/kernel/mm/transparent_hugepage/enabled" | awk -F ' ' '{print $3}'`
					hugepage2=`ssh $h "cat /sys/kernel/mm/transparent_hugepage/defrag" | awk -F ' ' '{print $3}'`
					#echo "hugepage1=$hugepage1 hugepage2=$hugepage2"
					if [ "$hugepage1" != "\[never\]" ]; then
						ssh $h "sudo -i sh -c 'echo never > /sys/kernel/mm/transparent_hugepage/enabled'"
					fi	
					if [ "$hugepage2" != "\[never\]" ]; then
						 ssh $h "sudo sh -c 'echo never > /sys/kernel/mm/transparent_hugepage/defrag'"
					fi
					#check sudoers account mercury\HadoopAdmin 
					#ssh $h "sudo grep -q 'HadoopAdmin'  /etc/sudoers"
					#if [ "$?"  != "0"  ]; then
                        		        #        ssh $h "sudo echo  'HadoopAdmin     ALL=(ALL)        NOPASSWD: ALL'|sudo tee -a /etc/sudoers"                                			     #fi
					done
					echo "${bldcyn}System enviroment check and config finish.${txtrst}"
					break
				elif [ "$userchoice" == "n" ] || [ "$userchoice" == "N" ]
					then break
				fi
			done
		continue;
		elif [ "$choice" == "3" ];then
			echo "${bldwht}Do you want to stop cloudera agent?${txtrst}"
	       		for h in $hosts
			do
				echo "	     * $h"
			done
			for ((i=1; i<=5 ; i++))
			do
        			echo -n "${bldblu}Pls type [y|n]${txtrst}:"
				read userchoice
				if [ "$userchoice" == "y" ] || [ "$userchoice" == "Y" ]; then
					for h in $hosts
					do
						ssh $h "sudo -i service cloudera-scm-agent stop"
		           			if [ "$?" != "0" ];then
							echo "${bldred} $h cloudera agent stop failed !${txtrst}"
		          			fi
					done
					echo "${bldgrn}$h cloudera-scm-agent stop finish${txtrst}"
					break
	               		elif [ "$userchoice" == 'n' ] || [ "$userchoice" == "N" ]
			   	     then break
			#else
			#	continue;#echo "Pls type ${bldgrn}[y|n]${txtrst}: "
				fi
			done
		continue;	
		elif [ "$choice" == "4" ];then
			echo "${bldwht}Do you want to start cloudera agent?${txtrst}"
	       		for h in $hosts
			do
				echo "	     * $h"
			done
			for ((i=1; i<=5 ; i++))
			do
        			echo -n "${bldblu}Pls type [y|n]${txtrst}:"
				read userchoice
				if [ "$userchoice" == "y" ] || [ "$userchoice" == "Y" ]; then
					for h in $hosts
					do
		        			 ssh $h "sudo -i service cloudera-scm-agent start"
		          			 if [ "$?" != "0" ];then
							echo "${bldred} $h cloudera agent start failed !${txtrst}"
				        	 fi
					done
					echo "${bldgrn}$h cloudera-scm-agent start finish${txtrst}"
					break
               			elif [ "$userchoice" == 'n' ] || [ "$userchoice" == "N" ]
			        	then break
			#else
			#	echo "Pls type ${bldgrn}[y|n]${txtrst}: "
				fi	
			done
		continue;
	elif   [ "$choice" == "5" ]; then
		echo "${bldwht}Do you want clear ssh from $Manager to${txtrst}"
		for h in $hosts
		do 
			echo   "     * $h"
		done 
		for ((i=1; i<=5 ; i++))
		do
			echo -n "${bldblu}Pls type [y|n]${txtrst}:"
			read userchoice
			if [ "$userchoice" == "y" ] || [ "$userchoice" == "Y" ];then
				if [ "$password" == '' ];then
 					echo  -n "${bldblu}please enter your password:${txtrst}"
					read -s password
				fi
				#echo  "${bldblu}please enter your user and password and separate by spaces:${txtrst}"
				#read username password
				#echo " " 
				echo "${bldwht}begin clear ssh....${txtrst}" | tee $basedir/log/ssh_clear.txt
				for h in $hosts
				do
				        echo "${bldgrn}clear $h's ssh,it maybe take a litte time,please wait.....${txtrst}" | tee -a $basedir/log/ssh_clear.txt
						expect  $basedir/bin/ssh_clear.exp $h $username $password $localpath 
					if [ "$?" != "0" ];then
						echo  "${bldred}clear $h's ssh failed! ${txtrst}"  | tee -a $basedir/log/ssh_clear.txt
					else
						echo  "${bldgrn}clear $h's ssh successfully ${txtrst}"  | tee -a $basedir/log/ssh_clear.txt
					fi
				done
				echo "${bldcyn}SSH clear finish.${txtrst}" | tee -a $basedir/log/ssh_clear.txt	
				break
			elif [ "$userchoice" == "n" ] || [ "$userchoice" == "N" ] 
				then break
			fi
		done
		continue;
		
	elif [ "$choice" == "6" ];then
		#echo "Do you want exit?"
		#read userchoice
		#if [ "$userchoice" == "y" ] || [ "$userchoice" == "Y" ]; 
  			#then exit
               	#else
			#continue
	        #fi
		exit;
	else
		echo "${bldred}your choice is invalid${txtrst}"
        	exit
	fi
    fi
done

