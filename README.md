# docker-tools
Provision Docker containers on Docker Swarm with the help of Docker Machine.  These tools will initially be for running a Docker Swarm on AWS.  Later I'll add more generic ways of running a swarm.

## Outline
- Docker Machine
- Subnet setup 
- Create a Docker Swarm master and instances
- Run a Docker Service on your new swarm
- Add a load balancer

## Diagram
![alt text](https://github.com/polinchw/docker-tools/blob/master/diagrams/docker-machine.png)


## Docker Machine
You can use Docker Machine to control all of your Docker Swarms.  
- Create a Linux VM/EC2 Instance that has the Docker runtime installed.
- Run this command on your Linux VM to install Docker Machine:

  curl -L https://github.com/docker/machine/releases/download/v0.10.0/docker-machine-`uname -s`-`uname -m` >/tmp/docker-machine &&
  chmod +x /tmp/docker-machine &&
  sudo cp /tmp/docker-machine /usr/local/bin/docker-machine
 
## Subnet setup
- You'll want to run your Docker Swarm for an app (aka Docker Service) on its own subnet. 
  To do this on AWS create a new VPC for your swarm and write down its VPC id.
  
  http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_Scenarios.html  
  
- Open the following ports:
  
    TCP port 2377 for cluster management communications
    
    TCP and UDP port 7946 for communication among nodes
    
    UDP port 4789 for overlay network traffic

  
## Create a Docker Swarm master and instances
- ssh into your Docker Machine VM and clone this repo:

  https://github.com/polinchw/docker-tools  

- Run the following script on the Docker Machine:  
  
chmod u+x docker-tools/docker-machine/docker-swarm/aws/bash-scripts/create-swarm-instances.sh 

/docker-tools/docker-machine/docker-swarm/aws/bash-scripts/create-swarm-instances.sh AKIAIPU52SG4FYHX5BKA xxxx vpc-9dc174e4 subnet-8102b5ad polinchw run-helloworld 1 ami-f413208f AppSecurityGroup


## Run a Docker Service on your new swarm
- ssh into the swarm master:

  docker-machine ssh SWARM-MASTER
  
- Run a Docker Service on the swarm with this (example) command:

  sudo docker service create --replicas 2 --name helloworld -p:8080:8080 polinchw/run-helloworld
  
- You can also run all the commands from the Docker Machine.  This could be very useful if you want script the whole deployment:

  docker-machine ssh docker-test-swarm-master 'sudo docker service create --replicas 2 --name docker-test p:8080:8080   
  polinchw/run-helloworld'

## Add a load balancer
- Front your new Docker Swarm with a load balancer.  Here is an example on how to set up an https load balancer.  
  Point the load balancer to the swarm worker(s), port 8080. 
  
  http://docs.aws.amazon.com/elasticloadbalancing/latest/classic/elb-create-https-ssl-load-balancer.html
  
