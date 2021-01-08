#!/bin/bash

red_color='\e[0;31m'
rest_color='\e[0m'

echo -e "${red_color}Deprecated! This shell script has been deprecated. Please use notifier.php instead!${rest_color}"
exit 1;

source "$HOME/.bashrc"

which curl 2>&1 > /dev/null

if [[ $api_key == "" ]]; then
    echo "Please set api_key environment variable"
    exit 1;
fi;

if [[ $api_secret == "" ]]; then
    echo "Please set api_secret environment variable"
    exit 1;
fi;

if [[ $? != 0 ]]; then
    echo 'Please install curl package!'
    exit 1;
fi;

curl --silent https://emask.taiwan.gov.tw/msk/index.jsp > index.html

if [[ $? = 1 ]]; then
    echo "Store index.html is failed"
    exit 1;
fi;

sed -i -e 's/<div class="col "><p style="margin-top: 10px; margin-bottom: 10px; font-size: 14px; font-weight: 400; color: #D00000;">//g' index.html
sed -i -e 's/<div class="col "><p style="margin-top: 10px; margin-bottom: 10px; font-size: 14px; font-weight: 400;">//g' index.html
sed -i -e 's/<\/p><\/div>//g' index.html

emask_maintain_message=$(cat index.html | grep "維護" | sed -e "s/ //g")
emask_notification_message=$(cat index.html | grep "請多加利用")
emask_timeline_message=$(cat index.html | grep "領取口罩" | sed -e "s/ //g")

rm -f index.html

today_date=$(date '+%F')
emask_start_date=$(echo $emask_notification_message | awk '{print $2}')
emask_start_date=$(date --date="${emask_start_date}" "+%F")
emask_next_date=$(date --date="${emask_start_date} +1 day" "+%F")

emask_end_date=$(echo $emask_notification_message | awk '{print $5}')
emask_end_date=$(date --date="${emask_end_date}" "+%F")

if [[ $emask_start_date == $today_date ]]; then
    times="第1次"
    echo "Do Start Date SMS API Call!";
elif [[ $emask_next_date == $today_date ]]; then
    times="第2次"
    echo "Do Second Date SMS API Call!";
elif [[ $emask_end_date == $today_date ]]; then
    times="最後一次"
    echo "Do End Date SMS API Call!";
else
    echo "Do nothing!"
    exit 0;
fi;

phone_file_path="${PWD}/phone.csv"

if [[ ! -f ${phone_file_path} ]]; then
    echo "Please create phone.csv on $PWD folder"
    echo "The format is as follows:"
    echo "User_name,phone_number"
    exit 1;
fi;

phone_template="Hi %s, 你好，這裡是口罩通知(%s通知)，提醒你："

for phone_list in $(cat ${phone_file_path});
do
    user_name=$(echo ${phone_list} | awk '{split($1,a,","); print a[1]}')
    user_phone=$(echo ${phone_list} | awk '{split($1,a,","); print a[2]}')

    sms_template=$(printf "${phone_template}" ${user_name} ${times})
    sms_template=$(echo ${sms_template}${emask_notification_message}${emask_timeline_message}${emask_maintain_message})

    curl -X "POST" "https://rest.nexmo.com/sms/json" \
      -d "from=Emask-Notifier" \
      -d "text=${sms_template}" \
      -d "to=${user_phone}" \
      -d "api_key=${api_key}" \
      -d "api_secret=${api_secret}"

    if [[ $? == 0 ]]; then
        echo "Send ${user_phone} is successful" >> "${today_date}.txt"
    else
        echo "Send ${user_phone} is failed" >> "${today_date}.txt"
    fi;
done;
