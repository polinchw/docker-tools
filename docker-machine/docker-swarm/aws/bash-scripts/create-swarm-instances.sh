#!/bin/bash
AWS_ACCESS_KEY_ID=$1
AWS_SECRET_ACCESS_KEY=$2
AWS_VPC_ID=$3
APP_NAME=$4
NODES=$5
APP_REG=$6
SUB_NET=$7

if [ -z "$AWS_ACCESS_KEY_ID"  ] || [ -z "$AWS_SECRET_ACCESS_KEY" ] || [ -z "$AWS_VPC_ID" ] || [ -z "$APP_NAME" ] || [ -z "$APP_REG" ] || [ -z "$SUB_NET" ]; then
  echo "usage: ./create-swarm-instances.sh <AWS_ACCESS_KEY_ID> <AWS_SECRET_ACCESS_KEY> <AWS_VPC_ID> <APP_NAME> <NODES> <APP_REG> <SUB_NET>"
  exit 1;
fi

echo '$AWS_ACCESS_KEY_ID = ' $1
echo '$AWS_SECRET_ACCESS_KEY = ' $2
echo '$AWS_VPC_ID = ' $3
echo '$APP_NAME = ' $4
echo '$NODES = ' $5
echo '$APP_REG = ' $6
echo '$SUB_NET = ' $7

echo "Creating Swarm Master...."
docker-machine create --driver amazonec2 --amazonec2-vpc-id $AWS_VPC_ID --amazonec2-subnet-id $SUB_NET $APP_NAME-swarm-master


echo "Creating Swarm Instances..."
COUNTER=0
while [  $COUNTER -lt $NODES ]; do
       docker-machine create --driver amazonec2 --amazonec2-vpc-id $AWS_VPC_ID $APP_NAME-node-$COUNTER
       let COUNTER=COUNTER+1
done

#Figure out the ports then init the Swarm...
MASTER_IPS=$(docker-machine ssh $APP_NAME-swarm-master 'hostname -I')
IFS=', ' read -r -a array <<< "$MASTER_IPS"
MASTER_INTERNAL_IP=${array[0]}
echo "IPs:"
echo ${MASTER_IPS}
echo "$APP_NAME-swarm-master internal ip:"
echo "$MASTER_INTERNAL_IP"
#init the swarm...
echo "Init the swarm:"
INIT_COMMAND="docker-machine ssh $APP_NAME-swarm-master 'sudo docker swarm init --advertise-addr $MASTER_INTERNAL_IP'"
echo "Init command: $INIT_COMMAND"
INIT_COMMAND_RESULTS=$(eval $INIT_COMMAND)
echo "swarm init results:"
echo "$INIT_COMMAND_RESULTS"
echo "Run this command to add instances to the swarm:"
echo "docker-machine ssh $APP_NAME-node-0 'sudo docker swarm join --token TOKEN_FROM_THE_MASTER_SECTION $MASTER_INTERNAL_IP:2377'"
echo "Run this command to add a Docker Service to the swarm:"
echo "docker-machine ssh $APP_NAME-swarm-master 'sudo docker service create --replicas 2 --name $APP_NAME -p:8080:8080 $APP_REG/$APP_NAME'"