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
echo "Manager=$Manager"

username=`$basedir/conf/config.py "username"`
echo "username=$username"

password=`$basedir/conf/config.py "password"`
# echo "password=$password"

LocalIp=`ip addr | grep "inet " | cut -b 10-| cut -f 1 -d "/"| grep -v '^127.0.0.1'`
echo "LocalIp=$LocalIp"
if [ "$username" == '' ]; then
    username=`eval echo "$USER"`
fi
localpath=`eval echo ~$username`
#pubkeyfile=`ls $localpath/.ssh/*.pub`

#echo "localpath=$localpath"
source $basedir/bin/col.sh
if [ "$Manager" == "" ]; then
    Manager=$LocalIp
fi
while [ 1 -eq 1 ]
do
    echo "==== DEBUG MODE ===="
    echo "1. sync host file"
    echo "2. sync repostory file"
    echo "3. limits check and update"
    echo "4. selinux check and update"
    echo "5. firewall check and update"
    echo "6. ntpd check and update"
    echo "7. swappiness check and update"
    echo "8. transparent_hugepage check and update"
    echo "9. optimize tcp connection setup"
    echo "10. copy files"
    echo "11. exit"
    echo -n "${bldblu}Please choose [1, 2, 3, 4, 5, 6, 7, 8, 9, 10 or 11]:${txtrst}"
    read choice
    if [ "$LocalIp" != "$Manager" ]; then
        echo "${bldred} please run this script on manager server ${txtrst}"
        exit
    else
        # 1. sync host file
        if [ "$choice" == "1" ]; then
            echo "${bldwht}Do you want syn host file from $Manager to${txtrst}"
            # print host list
            for h in $hosts
            do
                echo   "     * $h"
            done
            # foreach hosts, and copy the host file to the host 
            for ((i = 1; i <= 5; i ++))
            do
                echo -n "${bldblu}Pls type [y|n]${txtrst}:"
                read userchoice
                if [ "$userchoice" == "y" ] || [ "$userchoice" == "Y" ]; then
                    for h in $hosts
                    do
                        echo "${bldcyn}********************* $h *********************${txtrst}"
                        echo "$ scp -q /etc/hosts $h:/tmp/;"
                        echo "$ ssh $h \"sudo cp /etc/hosts /etc/hosts_bak;sudo mv /tmp/hosts /etc/\""
                    done
                    echo "${bldcyn}--------------------- finished! ---------------------${txtrst}"
                    break
                elif [ "$userchoice" == "n" ] || [ "$userchoice" == "N" ]
                then break
                fi
            done
            continue;
        # 2. syn repostory file
        elif [ "$choice" == "2" ]; then
            echo "${bldwht}Do you want syn repostory file from $Manager to${txtrst}"
            # print host list
            for h in $hosts
            do
                echo   "     * $h"
            done
            # foreach hosts, and copy the Cloudera.repo file to the host 
            for ((i = 1; i <= 5; i ++))
            do
                echo -n "${bldblu}Pls type [y|n]${txtrst}:"
                read userchoice
                if [ "$userchoice" == "y" ] || [ "$userchoice" == "Y" ]; then
                    for h in $hosts
                    do
                        echo "${bldcyn}********************* $h *********************${txtrst}"
                        echo "$ scp -q $basedir/conf/Cloudera.repo $h:/tmp/;"
                        echo "$ ssh $h \"sudo mv /tmp/Cloudera.repo /etc/yum.repos.d/; sudo chown root.root /etc/yum.repos.d/Cloudera.repo\";"
                        #scp -q $basedir/conf/CentOS-Base.repo $h:/tmp/;
                        #ssh $h "sudo rm -f /etc/yum.repos.d/Cloudera.repo;sudo mv /tmp/CentOS-Base.repo /etc/yum.repos.d/; sudo chown root.root /etc/yum.repos.d/CentOS-Base.repo";
                    done
                    echo "${bldcyn}--------------------- finished! ---------------------${txtrst}"
                    break
                elif [ "$userchoice" == "n" ] || [ "$userchoice" == "N" ]
                then break
                fi
            done
            continue;
        # 3. limits check
        elif [ "$choice" == "3" ]; then
            echo "${bldwht}Do you want check limits${txtrst}"
            # print host list
            for h in $hosts
            do
                echo   "     * $h"
            done
            # foreach hosts, and set the maximum number of open file handles (change limits.conf)
            for ((i = 1; i <= 5; i ++))
            do
                echo -n "${bldblu}Pls type [y|n]${txtrst}:"
                read userchoice
                if [ "$userchoice" == "y" ] || [ "$userchoice" == "Y" ]; then
                    for h in $hosts
                    do
                        echo "${bldcyn}********************* $h *********************${txtrst}"
                        echo "$ ssh $h \"grep -q '*    -    nofile    32768' /etc/security/limits.conf\";"
                        if [ "$?"  != "0"  ]; then
                            echo "$ ssh $h \"echo  '*    -    nofile    32768' | sudo tee -a /etc/security/limits.conf \""
                        fi
                    done
                    echo "${bldcyn}--------------------- finished! ---------------------${txtrst}"
                    break
                elif [ "$userchoice" == "n" ] || [ "$userchoice" == "N" ]
                then break
                fi
            done
            continue;
        # 4. selinux check
        elif [ "$choice" == "4" ]; then
            echo "${bldwht}Do you want check selinux${txtrst}"
            # print host list
            for h in $hosts
            do
                echo   "     * $h"
            done
            # foreach hosts, and set the SElinux=disabled
            for ((i = 1; i <= 5; i ++))
            do
                echo -n "${bldblu}Pls type [y|n]${txtrst}:"
                read userchoice
                if [ "$userchoice" == "y" ] || [ "$userchoice" == "Y" ]; then
                    for h in $hosts
                    do
                        echo "${bldcyn}********************* $h *********************${txtrst}"
                        echo "$ ssh $h \"sudo sestatus| sed -n '1p';sudo sestatus|sed -n '5p';grep -q 'SELINUX=disabled' /etc/sysconfig/selinux\""
                        if [ "$?" != "0"  ]; then
                            echo "$ ssh $h \"sudo sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/sysconfig/selinux;sudo sed -i 's/SELINUX=permissive/SELINUX=disabled/' /etc/sysconfig/selinux;\""
                            echo "${bldred} $h selinux not be disabled,so must restart because of selinux!${txtrst}"
                        else
                            echo "$ ssh $h \" sudo sestatus| sed -n '1p' | grep 'SELinux status:                 disabled'\""
                            if [ "$?" != "0"  ]; then
                                echo "${bldred} $h selinux not be disabled,so must restart because of selinux!${txtrst}"
                            fi
                        fi
                    done
                    echo "${bldcyn}--------------------- finished! ---------------------${txtrst}"
                    break
                elif [ "$userchoice" == "n" ] || [ "$userchoice" == "N" ]
                then break
                fi
            done
            continue;
        # 5. firewall check
        elif [ "$choice" == "5" ]; then
            echo "${bldwht}Do you want check firewall${txtrst}"
            # print host list
            for h in $hosts
            do
                echo   "     * $h"
            done
            # foreach hosts, and disable firewalld
            for ((i = 1; i <= 5; i ++))
            do
                echo -n "${bldblu}Pls type [y|n]${txtrst}:"
                read userchoice
                if [ "$userchoice" == "y" ] || [ "$userchoice" == "Y" ]; then
                    for h in $hosts
                    do
                        echo "${bldcyn}********************* $h *********************${txtrst}"
                        echo "$ ssh $h \"sudo systemctl disable firewalld;sudo systemctl stop firewalld;sudo systemctl status firewalld | sed -n '2,3p'\""
                    done
                    echo "${bldcyn}--------------------- finished! ---------------------${txtrst}"
                    break
                elif [ "$userchoice" == "n" ] || [ "$userchoice" == "N" ]
                then break
                fi
            done
            continue;
        # 6. ntpd check
        elif [ "$choice" == "6" ]; then
            echo "${bldwht}Do you want check ntpd${txtrst}"
            # print host list
            for h in $hosts
            do
                echo   "     * $h"
            done
            # foreach hosts, and set ntpd service
            for ((i = 1; i <= 5; i ++))
            do
                echo -n "${bldblu}Pls type [y|n]${txtrst}:"
                read userchoice
                if [ "$userchoice" == "y" ] || [ "$userchoice" == "Y" ]; then
                    for h in $hosts
                    do
                        echo "${bldcyn}********************* $h *********************${txtrst}"
                        echo "$ ssh $h \"sudo systemctl status ntpd.service | sed -n '2,3p';sudo systemctl enable ntpd.service;sudo systemctl start ntpd.service\""
                    done
                    echo "${bldcyn}--------------------- finished! ---------------------${txtrst}"
                    break
                elif [ "$userchoice" == "n" ] || [ "$userchoice" == "N" ]
                then break
                fi
            done
            continue;
        # 7. swappiness check
        elif   [ "$choice" == "7" ]; then
            echo "${bldwht}Do you want check swappiness${txtrst}"
            # print host list
            for h in $hosts
            do
                echo   "     * $h"
            done
            # foreach hosts, and set ntpd service
            for ((i = 1; i <= 5; i ++))
            do
                echo -n "${bldblu}Pls type [y|n]${txtrst}:"
                read userchoice
                if [ "$userchoice" == "y" ] || [ "$userchoice" == "Y" ]; then
                    for h in $hosts
                    do
                        echo "${bldcyn}********************* $h *********************${txtrst}"
                        echo "$ ssh $h \"sudo /sbin/sysctl vm.swappiness | grep 'vm.swappiness = 0'\"";
                        if [ "$?"  != "0"  ]; then
                            echo "${bldpur}config swappiness${txtrst}"
                            echo "$ ssh $h \"sudo sysctl vm.swappiness=0;\""
                            echo "$ ssh $h \"grep -q 'vm.swappiness = 0' /etc/sysctl.conf\""
                            if [ "$?"  != "0"  ]; then
                                echo "$ ssh $h \"echo 'vm.swappiness = 0'| sudo tee -a /etc/sysctl.conf\""
                            fi
                            # echo "${bldred} $h config vm.swappiness failed!${txtrst}"
                        fi
                    done
                    echo "${bldcyn}--------------------- finished! ---------------------${txtrst}"
                    break
                elif [ "$userchoice" == "n" ] || [ "$userchoice" == "N" ]
                then break
                fi
            done
            continue;
        # 8. transparent_hugepage check
        elif   [ "$choice" == "8" ]; then
            echo "${bldwht}Do you want check transparent_hugepage${txtrst}"
            # print host list
            for h in $hosts
            do
                echo   "     * $h"
            done
            # foreach hosts, and disable THP
            for ((i = 1; i <= 5; i ++))
            do
                echo -n "${bldblu}Pls type [y|n]${txtrst}:"
                read userchoice
                if [ "$userchoice" == "y" ] || [ "$userchoice" == "Y" ]; then
                    for h in $hosts
                    do
                        echo "${bldcyn}********************* $h *********************${txtrst}"
                        echo "$ ssh $h \"cat /sys/kernel/mm/transparent_hugepage/enabled\" | awk -F ' ' '{print \$3}'"
                        echo "$ ssh $h \"cat /sys/kernel/mm/transparent_hugepage/defrag\" | awk -F ' ' '{print \$3}'"
						hugepage1="never"
						hugepage2="never"
                        echo "hugepage1=$hugepage1 hugepage2=$hugepage2"
                        if [ "$hugepage1" != "\[never\]" ]; then
                            # ssh $h "sudo -i sh -c 'echo never > /sys/kernel/mm/transparent_hugepage/enabled'"
                            echo "$ scp -q ./conf/rc.local $h:/tmp/;"
                            echo "$ ssh $h \"sudo cp /etc/rc.d/rc.local /etc/rc.d/rc.local.bak; sudo cp /tmp/rc.local /etc/rc.d/; sudo chown root /etc/rc.d/rc.local\""
                            echo "$ ssh $h \"sudo chmod u+x /etc/rc.d/rc.local;sudo sysctl -p; sudo systemctl start rc-local\""
                        fi
                        #if [ "$hugepage2" != "\[never\]" ]; then
                        #       #ssh $h "sudo sh -c 'echo never > /sys/kernel/mm/transparent_hugepage/defrag'"
                        #fi
                    done
                    echo "${bldcyn}--------------------- finished! ---------------------${txtrst}"
                    break
                elif [ "$userchoice" == "n" ] || [ "$userchoice" == "N" ]
                then break
                fi
            done
            continue;
        # 9. optimize tcp connection setup
        elif [ "$choice" == "9" ]; then
            echo "${bldwht}Do you optimize tcp setup${txtrst}"
            # print host list
            for h in $hosts
            do
                echo   "     * $h"
            done
            # foreach hosts, and ptimize tcp connection setup
            for ((i = 1; i <= 5; i ++))
            do
                echo -n "${bldblu}Pls type [y|n]${txtrst}:"
                read userchoice
                if [ "$userchoice" == "y" ] || [ "$userchoice" == "Y" ]; then
                    for h in $hosts
                    do
                        echo "${bldcyn}********************* $h *********************${txtrst}"
                        echo "$ ssh $h \"sudo sed -i 's/net.ipv4.tcp_timestamps = 0/net.ipv4.tcp_timestamps = 1/' /etc/sysctl.conf;sudo sed -i 's/net.ipv4.tcp_sack = 0/net.ipv4.tcp_sack = 1/' /etc/sysctl.conf ;sudo sed -i '43a\net.ipv4.tcp_tw_recycle= 1' /etc/sysctl.conf ;sudo sed  -i '44a\net.ipv4.tcp_tw_reuse= 1' /etc/sysctl.conf ;sudo sed -i 's/net.ipv4.tcp_rmem = 536870912 536870912 536870912/net.ipv4.tcp_rmem = 4096        87380   4194304/' /etc/sysctl.conf ;sudo sed -i 's/net.ipv4.tcp_wmem = 536870912 536870912 536870912/net.ipv4.tcp_wmem = 4096        16384   4194304/' /etc/sysctl.conf ;sudo sed -i 's/net.ipv4.tcp_mem = 536870912 536870912 536870912/net.ipv4.tcp_mem = 6181020      8241361 12362040/' /etc/sysctl.conf ;sudo sed -i 's/net.core.rmem_max = 536870912/net.core.rmem_max = 212992/' /etc/sysctl.conf ;sudo sed -i 's/net.core.wmem_max = 536870912/net.core.wmem_max = 212992/' /etc/sysctl.conf ;sudo sed -i 's/net.core.rmem_default = 536870912/net.core.rmem_default = 212992/' /etc/sysctl.conf;sudo sed -i 's/net.core.wmem_default = 536870912/net.core.wmem_default = 212992/' /etc/sysctl.conf ;sudo sed -i '55a\net.ipv4.udp_mem=6183732      8244979 12367464' /etc/sysctl.conf ;sudo sysctl -p\""
                    done
                    echo "${bldcyn}--------------------- finished! ---------------------${txtrst}"
                    break
                elif [ "$userchoice" == "n" ] || [ "$userchoice" == "N" ]
                then break
                fi
            done
            continue;
        # 10. copy files
        elif [ "$choice" == "10" ]; then
            echo "${bldwht}Do you want to copy files${txtrst}"
            # print host list
            for h in $hosts
            do
                echo   "     * $h"
            done
            # foreach hosts, and copy cache files
            for ((i = 1; i <= 5; i ++))
            do
                echo -n "${bldblu}Pls type [y|n]${txtrst}:"
                read userchoice
                if [ "$userchoice" == "y" ] || [ "$userchoice" == "Y" ]; then
                    for h in $hosts
                    do
                        echo "${bldcyn}********************* $h *********************${txtrst}"
                        echo "$ ssh $h \"sudo rm -r /cache/yarn/;sudo chown hbase:hbase /cache;ls -al /cache\""
                    done
                    echo "${bldcyn}--------------------- finished! ---------------------${txtrst}"
                    break
                elif [ "$userchoice" == "n" ] || [ "$userchoice" == "N" ]
                then break
                fi
            done
            continue;
        # 11. exit
        elif [ "$choice" == "11" ]; then
            exit;
        else
            echo "${bldred}your choice is invalid${txtrst}"
            exit
        fi
    fi
done

