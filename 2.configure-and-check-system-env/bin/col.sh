#!/bin/bash

# Text color variables
# Text color variables
txtund=$(tput sgr 0 1)          # Underline
txtbld=$(tput bold)             # Bold
bldred=${txtbld}$(tput setaf 1)    # Red
bldgrn=${txtbld}$(tput setaf 2)    # Green
bldylw=${txtbld}$(tput setaf 3)    # Yellow
bldblu=${txtbld}$(tput setaf 4)    # Blue
bldpur=${txtbld}$(tput setaf 5)    # Purple
bldcyn=${txtbld}$(tput setaf 6)    # Cyan
bldwht=${txtbld}$(tput setaf 7)    # White
txtrst=${txtbld}$(tput sgr0)       # Text reset

#info=${bldwht}white${txtrst}        # Feedback
#pass=${bldblu}pass${txtrst}
#warn=${bldred}warn${txtrst}

white=${bldwht}bldwhite${txtrst}        # Feedback
blue=${bldblu}bldblue${txtrst}
red=${bldred}bldred${txtrst}
green=${bldgrn}green${txtrst}        
yellow=${bldylw}yellow${txtrst}
purple=${bldpur}Purple${txtrst}
cyan=${bldcyn}cyan${txtrst}


# Successful command, Information, Alert
#echo -e "${white} "
#echo -e "${blue}"
#echo -e "${red}"
#echo -e "${green} "
#echo -e "${yellow}"
#echo -e "${purple}"
#echo -e "${cyan} "
