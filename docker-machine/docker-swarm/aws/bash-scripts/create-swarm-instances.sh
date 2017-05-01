#!/bin/bash
AWS_ACCESS_KEY_ID=$1
AWS_SECRET_ACCESS_KEY=$2
AWS_VPC_ID=$3
APP_NAME=$4
NODES=$5

if [ -z "$AWS_ACCESS_KEY_ID"  ] || [ -z "$AWS_SECRET_ACCESS_KEY" ] || [ -z "$AWS_VPC_ID" ] || [ -z "$APP_NAME" ]; then
  echo "usage: ./create-swarm-instances.sh <AWS_ACCESS_KEY_ID> <AWS_SECRET_ACCESS_KEY> <AWS_VPC_ID> <APP_NAME> <NODES>"
  exit 1;
fi

echo '$AWS_ACCESS_KEY_ID = ' $1
echo '$AWS_SECRET_ACCESS_KEY = ' $2
echo '$AWS_VPC_ID = ' $3
echo '$APP_NAME = ' $4
echo '$NODES = ' $5

echo "Creating Swarm Master"
docker-machine create --driver amazonec2 --amazonec2-vpc-id $AWS_VPC_ID $APP_NAME-swarm-master

echo "Creating Swarm Instances"
COUNTER=0
while [  $COUNTER -lt $NODES ]; do
       docker-machine create --driver amazonec2 --amazonec2-vpc-id $AWS_VPC_ID $APP_NAME-node-$COUNTER
       echo The counter is $COUNTER
       let COUNTER=COUNTER+1
done

#docker-machine create --driver amazonec2 --amazonec2-vpc-id $AWS_VPC_ID $APP_NAME-node-01
#docker-machine create --driver amazonec2 --amazonec2-vpc-id $AWS_VPC_ID $APP_NAME-node-02