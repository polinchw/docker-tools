# docker-tools
Provision Docker containers on Docker Swarm with the help of Docker Machine.  These tools will initially be for running a Docker Swarm on AWS.  Later I'll add more generic ways of run a Swarm.

## Outline
- Docker Machine
- Subnet Setup 
- Create a Docker Swarm Manager and Instances
- Join Swarm Worker Instances to the Swarm Manager
- Run a Docker Service on your new Swarm
- Add a load balancer

## Docker Machine
You can use Docker Machine to control all of your Docker Swarms.  
- Create a Linux VM that has the Docker runtime installed.
- Run this command on your Linux VM to install Docker Machine:

  curl -L https://github.com/docker/machine/releases/download/v0.10.0/docker-machine-`uname -s`-`uname -m` >/tmp/docker-machine &&
  chmod +x /tmp/docker-machine &&
  sudo cp /tmp/docker-machine /usr/local/bin/docker-machine
 
## Subnet Setup
- You'll want to run your Docker Swarm for an app (aka Docker Service) on it's own subnet. To do this on AWS create a new VPC for   
  your swarm and write down it's VPC id.
  
## Create a Docker Swarm Manager and Instances
- ssh into your Docker Machine VM and clone this repo:

  https://github.com/polinchw/docker-tools  

- Run the following script on the Docker Machine:

  https://github.com/polinchw/docker-tools/blob/master/docker-machine/docker-swarm/aws/bash-scripts/create-swarm-instances.sh
  
- ssh into the swarm mananger:

  docker-machine ssh <swarm-mananger>
  
- Run this command on the swarm mananger:   

  sudo docker swarm init --advertise-addr <IP-ADDRESS-OF-SWARM-MANANGER>
  
  Write down the token given out for the swarm to use in the next section.
  
## Join Swarm Worker Instances to the Mananger
- ssh into each worker instance of the swarm from the Docker Machine with this command:
 
  docker-machine ssh <worker-node>
  
  Once on the worker run this command:
  
  sudo docker swarm join --token TOKEN_FROM_THE_MANAGER_SECTION <IP-ADDRESS-OF-SWARM-MANANGER>:2377

## Run a Docker Service on your new Swarm
- ssh into the swarm manager:

  docker-machine ssh <swarm-manager>
  
- Run a Docker Service on the swarm with this (example) command:

  sudo docker service create --replicas 2 --name helloworld -p:8080:8080 polinchw/run-helloworld

## Add a load balancer
