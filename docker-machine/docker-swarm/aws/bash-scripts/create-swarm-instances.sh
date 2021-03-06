#!/bin/bash
AWS_ACCESS_KEY_ID=$1
AWS_SECRET_ACCESS_KEY=$2
AWS_VPC_ID=$3
SUB_NET=$4
APP_REG=$5
APP_NAME=$6
NODES=$7
AMI_ID=$8
SEC_GROUP_ID=$9

if [ -z "$AWS_ACCESS_KEY_ID"  ] || [ -z "$AWS_SECRET_ACCESS_KEY" ] || [ -z "$AWS_VPC_ID" ] || [ -z "$APP_NAME" ] || [ -z "$APP_REG" ] || [ -z "$SUB_NET" ]; then
  echo "usage: ./create-swarm-instances.sh <AWS_ACCESS_KEY_ID> <AWS_SECRET_ACCESS_KEY> <AWS_VPC_ID> <SUB_NET> <APP_REG> <APP_NAME> <NODES> <AMI_ID> <SEC_GROUP_ID>  "
  eche "example: ./create-swarm-instances.sh AKIAJB7DZD4I6QA2XBRA xxx vpc-9dc174e4 subnet-5501b679 polinchw monitor-frontend 1 ami-8887be9e WebServerSecurityGroup"
  exit 1;
fi

#echo '$AWS_ACCESS_KEY_ID = ' $1
#echo '$AWS_SECRET_ACCESS_KEY = ' $2
#echo '$AWS_VPC_ID = ' $3
#echo '$APP_NAME = ' $4
#echo '$NODES = ' $5
#echo '$APP_REG = ' $6
#echo '$SUB_NET = ' $7

echo "Creating Swarm Master...."
docker-machine create --driver amazonec2 --amazonec2-access-key $AWS_ACCESS_KEY_ID --amazonec2-secret-key $AWS_SECRET_ACCESS_KEY --amazonec2-vpc-id $AWS_VPC_ID -amazonec2-subnet-id $SUB_NET --amazonec2-ami $AMI_ID --amazonec2-security-group $SEC_GROUP_ID --amazonec2-ssh-user ubuntu $APP_NAME-swarm-master
sleep 20
#Create Swarm Instances

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
INIT_COMMAND="docker-machine ssh $APP_NAME-swarm-master 'docker swarm init --listen-addr $MASTER_INTERNAL_IP:2377'"
echo "Init command: $INIT_COMMAND"
sleep 30
INIT_COMMAND_RESULTS=$(eval $INIT_COMMAND)
echo " "
echo "swarm init results:"
echo $INIT_COMMAND_RESULTS
echo " "
echo "Creating Swarm Instances..."
COUNTER=0
while [  $COUNTER -lt $NODES ]; do
       docker-machine create --driver amazonec2 --amazonec2-access-key $AWS_ACCESS_KEY_ID --amazonec2-secret-key $AWS_SECRET_ACCESS_KEY --amazonec2-vpc-id $AWS_VPC_ID -amazonec2-subnet-id $SUB_NET --amazonec2-ami $AMI_ID --amazonec2-security-group $SEC_GROUP_ID --amazonec2-ssh-user ubuntu $APP_NAME-node-$COUNTER
       sleep 20
       #Get the tocken
       GET_TOKEN_COMMAND="docker-machine ssh $APP_NAME-swarm-master 'docker swarm join-token -q worker'"
       GET_TOKEN_COMMAND_RESULTS=$(eval $GET_TOKEN_COMMAND)
       echo "Join token:" $GET_TOKEN_COMMAND_RESULTS
       JOIN_COMMAND="docker-machine ssh $APP_NAME-node-$COUNTER 'docker swarm join --token $GET_TOKEN_COMMAND_RESULTS $MASTER_INTERNAL_IP:2377'"
       echo $JOIN_COMMAND
       JOIN_COMMAND_RESULTS=$(eval $JOIN_COMMAND)
       echo "Join command resuls: $JOIN_COMMAND_RESULTS"
       let COUNTER=COUNTER+1
done
echo " "
echo "Run this command to add a Docker Service to the swarm:"
echo "docker-machine ssh $APP_NAME-swarm-master 'docker service create --replicas 2 --name $APP_NAME -p 8080:8080 $APP_REG/$APP_NAME'"
