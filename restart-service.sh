#!/bin/bash

name=$1

if [ -z "$name" ]
then
    echo -e "\033[31m======> \033[1;31;47m[Error]\033[0;31m Usage: $0 <container-name>\033[0m"
    exit 1
fi

if [ ! "$(docker ps -q -f name=$name)" ]
then
    echo -e "\033[31m======> \033[1;31;47m[Error]\033[0;31m Container $name does not exist\033[0m"
    exit 1
fi

echo -e "\033[34m======> \033[1;34;47m[Info]\033[0;34m Stopping container $name\033[0m"
docker-compose stop $name

echo -e "\033[34m======> \033[1;34;47m[Info]\033[0;34m Removing container $name\033[0m"
docker-compose rm -f $name

echo -e "\033[34m======> \033[1;34;47m[Info]\033[0;34m Starting container $name\033[0m"
docker-compose up -d $name
