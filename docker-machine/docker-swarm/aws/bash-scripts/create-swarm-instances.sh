#!/bin/bash
AWS_ACCESS_KEY_ID=$1
AWS_SECRET_ACCESS_KEY=$2
AWS_VPC_ID=$3
APP_NAME=$4

if [ -z "$AWS_ACCESS_KEY_ID"  ] || [ -z "$AWS_SECRET_ACCESS_KEY" ] || [ -z "$AWS_VPC_ID" ] || [ -z "$APP_NAME" ]; then
  echo "set vars AWS_ACCESS_KEY_ID , AWS_SECRET_ACCESS_KEY and AWS_VPC_ID and APP_NAME"
  exit 1;
fi

echo '$AWS_ACCESS_KEY_ID = ' $1
echo '$AWS_SECRET_ACCESS_KEY = ' $2
echo '$AWS_VPC_ID = ' $3
echo '$APP_NAME = ' $4

echo "Creating Swarm Instances"
docker-machine create --driver amazonec2 --amazonec2-vpc-id $AWS_VPC_ID $APP_NAME-swarm-master
docker-machine create --driver amazonec2 --amazonec2-vpc-id $AWS_VPC_ID $APP_NAME-node-01
docker-machine create --driver amazonec2 --amazonec2-vpc-id $AWS_VPC_ID $APP_NAME-node-02