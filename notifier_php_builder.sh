#!/bin/bash

green_color='\e[0;32m'
red_color='\e[0;31m'
rest_color='\e[0m'

if [ ${USER} != "root" ]; then
    sudo_prefix='sudo '
fi;

if [ ! -f phone.csv ]; then
    echo -e "${red_color}phone.csv file is not found...${rest_color}"
    exit 1;
fi;

if [ ! -f .env ]; then
    echo -e "${red_color}.env file is not found...${rest_color}"
    exit 1;
fi;

echo -e "${green_color}Creating a supervisor confiuration for notifier.php....${rest_color}"
supervisor_path='/etc/supervisor/conf.d/notifier-php.conf'
${sudo_prefix}touch ${supervisor_path}

echo '[program:notifier-php]' | ${sudo_prefix}tee ${supervisor_path}
echo "command=/bin/bash -c \"cd $PWD && /usr/bin/php.default notifier.php\"" | ${sudo_prefix}tee -a ${supervisor_path}
echo 'autostart=true' | ${sudo_prefix}tee -a ${supervisor_path}
echo 'autorestart=true' | ${sudo_prefix}tee -a ${supervisor_path}
echo "user=$USER" | ${sudo_prefix}tee -a ${supervisor_path}
echo 'redirect_stderr=true' | ${sudo_prefix}tee -a ${supervisor_path}
echo "stdout_logfile=$PWD/notifier-php.log" | ${sudo_prefix}tee -a ${supervisor_path}

${sudo_prefix}systemctl restart supervisor

if [[ $? != 0 ]]; then
    ${sudo_prefix}rm -f ${supervisor_path}
    echo -e "${red_color}The supervisor service is not found. Do you install it?${rest_color}"
    exit 1;
fi;

echo -e "${green_color}Building PHP Notifier has been done!${rest_color}"
