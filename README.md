# docker-tools
Provision Docker containers on Docker Swarm with the help of Docker Machine.  These tools will initially be for running a Docker Swarm on AWS.  Later I'll add more generic ways of running a swarm.

## Outline
- Docker Machine
- Subnet Setup 
- Create a Docker Swarm master and instances
- Join Swarm Worker Instances to the Swarm Master
- Run a Docker Service on your new swarm
- Add a load balancer

## Docker Machine
You can use Docker Machine to control all of your Docker Swarms.  
- Create a Linux VM/EC2 Instance that has the Docker runtime installed.
- Run this command on your Linux VM to install Docker Machine:

  curl -L https://github.com/docker/machine/releases/download/v0.10.0/docker-machine-`uname -s`-`uname -m` >/tmp/docker-machine &&
  chmod +x /tmp/docker-machine &&
  sudo cp /tmp/docker-machine /usr/local/bin/docker-machine
 
## Subnet Setup
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

  https://github.com/polinchw/docker-tools/blob/master/docker-machine/docker-swarm/aws/bash-scripts/create-swarm-instances.sh
  
- ssh into the swarm master:

  docker-machine ssh SWARM-MASTER
  
- Determine the interal IP of the swarm master.  In this case the IP is 10.0.0.99.  You can figure this out by running ifconfig:

  ubuntu@helloworld-swarm-master:~$ ifconfig
  docker0   Link encap:Ethernet  HWaddr 02:42:32:78:71:25  
          inet addr:172.17.0.1  Bcast:0.0.0.0  Mask:255.255.0.0
          inet6 addr: fe80::42:32ff:fe78:7125/64 Scope:Link
          UP BROADCAST MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:8 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:0 (0.0 B)  TX bytes:648 (648.0 B)

 docker_gwbridge Link encap:Ethernet  HWaddr 02:42:90:12:4f:32  
          inet addr:172.18.0.1  Bcast:0.0.0.0  Mask:255.255.0.0
          inet6 addr: fe80::42:90ff:fe12:4f32/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:110 errors:0 dropped:0 overruns:0 frame:0
          TX packets:116 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:7280 (7.2 KB)  TX bytes:42868 (42.8 KB)

  eth0      Link encap:Ethernet  HWaddr 12:cd:29:ae:fc:44  
          inet addr:10.0.0.99  Bcast:10.0.0.255  Mask:255.255.255.0
          inet6 addr: fe80::10cd:29ff:feae:fc44/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:9001  Metric:1
          RX packets:424905 errors:0 dropped:0 overruns:0 frame:0
          TX packets:148727 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:619607702 (619.6 MB)  TX bytes:11267795 (11.2 MB)

  
- Run this command on the swarm master:   

  sudo docker swarm init --advertise-addr IP-ADDRESS-OF-SWARM-MASTER
  
  Write down the token given out for the swarm to use in the next section.
  
## Join Swarm Worker Instances to the Master
- ssh into each worker instance of the swarm from the Docker Machine with this command:
 
  docker-machine ssh SWARM-WORKER-NODE
  
  Once on the worker run this command:
  
  sudo docker swarm join --token TOKEN_FROM_THE_MASTER_SECTION IP-ADDRESS-OF-SWARM-MASTER:2377

## Run a Docker Service on your new Swarm
- ssh into the swarm master:

  docker-machine ssh SWARM-MASTER
  
- Run a Docker Service on the swarm with this (example) command:

  sudo docker service create --replicas 2 --name helloworld -p:8080:8080 polinchw/run-helloworld

## Add a load balancer
- Front your new Docker Swarm with a load balancer.  Here is an example on how to set up an https load balancer.  
  Point the load balancer to the swarm worker(s), port 8080. 
  
  http://docs.aws.amazon.com/elasticloadbalancing/latest/classic/elb-create-https-ssl-load-balancer.html
  
