# DemoECS
## Description
Run a [nodejs app](https://hub.docker.com/r/vpommier/fake-app/) in ECS cluster.
The cluster is composed of:
* 1 VPC
* 1 Subnet
* 3 t2.micro ECS instances, max 5
* 1 ELB

Feel free to modify the cloudformation template.

## Prerequisite and dependencies
* bash
* awscli
* curl

You can use my [docker image](https://hub.docker.com/r/vpommier/ide_aws/) that embed aws tools and other stuff that we need.

If you are new with aws cli, please read the [documentation](https://aws.amazon.com/fr/documentation/cli/).

And finally, configure your aws cli by running the following command:
```bash
aws configure
```

## Consideration
If you don't use a root access key, you will probably not be able to create the cluster properly.
An easy inelegant solution is to ask to your AWS administrator, a temporary administrator access,
by attaching the IAM "AdministratorAccess" policy on your user account. 

## Bootstrap the cluster
```bash
bash ./cluster.sh create
```
A key pair will be created, the location will be printed on stdout.
The creation take a while, so check the status regularly.
	
## Check the cluster creation status:
```bash
bash ./cluster.sh status
```
Once the cluster is ready, the output of the status command looks something like this:
```
Cluster Ready to use.
Execute the following command to request on your app:
curl http://<DNS of ELB cluster>
```

## Destroy the cluster:
```bash
bash ./cluster.sh destroy
```
