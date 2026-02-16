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
MYSQL_HOST=mysql.daws88s.store
DB_NAME="backend"


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

dnf module enable nodejs:20 -y
validate $? "enable nodejs:20"

dnf install nodejs -y
validate $? "install nodejs"

dnf update -y openssh openssh-server openssh-clients
validate $? "updating ssh clients"

id expense
if [ $? -ne 0 ]; then
    useradd expense
    validate $? "adding user"
else
    echo -e "user already existed.....$Y SKIPPING $N"
fi

mkdir -p /app
validate $? "Creating app directory"

curl -o /tmp/backend.zip https://expense-joindevops.s3.us-east-1.amazonaws.com/expense-backend-v2.zip
validate $? "Downloading backend file"

cd /app
validate $? "moving to app directory"

rm -rf /app/*
validate $? "removing existing code"

unzip /tmp/backend.zip
validate $? "unzipping backend file"

npm install
validate $? "Installing dependencies"

cp $SCRIPT_DIR/backend.service /etc/systemd/system/backend.service
validate $? "Copying systemctl file"

systemctl daemon-reload
systemctl start backend
systemctl enable backend
validate $? "start and enable"

dnf install mysql -y
validate $? " install mysql"

DB_CHECK=$(mysql -h $MYSQL_HOST -uroot -pExpenseApp@1 -se "SHOW DATABASES LIKE '$DB_NAME';")

if [ "$DB_CHECK" == "$DB_NAME" ]; then
    echo $? "Database already exists. Skipping schema load."
else
    echo "Database does not exist. Loading schema..."
    mysql -h $MYSQL_HOST -uroot -pExpenseApp@1 < /app/schema/backend.sql
    validate $? "Schema loaded"
fi

systemctl restart backend
validate $? "restarted"




