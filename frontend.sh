#!/bin/bash

USERID=$(id -u)

LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
B="\e[34m"
N="\e[0m"
SCRIPT_DIR=$PWD
#MONGO_HOST=mongodb.daws88s.store


if [ $USERID -ne 0 ]; then
    echo "Please use root access" | tee -a $LOGS_FILE
    exit 12
fi

mkdir -p $LOGS_FOLDER

validate(){
    if [ $1 -ne 0 ]; then
        echo "$2... Failed" | tee -a $LOGS_FILE
        exit 30
    else
        echo "$2.. Success" | tee -a $LOGS_FILE
    fi
}

dnf install nginx -y &>> $LOGS_FILE
validate $? "Installing nginx"
systemctl enable nginx 
systemctl start nginx 
validate $? "Enabling & Starting nginx"
rm -rf /usr/share/nginx/html/* 
validate $? "removing content from the file"
curl -o /tmp/frontend.zip https://expense-joindevops.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip
validate $? "Downloading code"
cd /usr/share/nginx/html 
validate $? "moving to html directory"
unzip /tmp/frontend.zip
validate $? "unzipping frontend code"
rm -rf /etc/nginx/nginx.conf
cp $SCRIPT_DIR/expense.config /etc/nginx/default.d/expense.conf
validate $? "copying nginx content"
systemctl daemon-reload
validate $? "reloaded nginx"

