#!/bin/bash

function createKeyPair(){
	local keyName="$1"
	local keyPairLocation="$2"

	if [ ! "$(aws ec2 describe-key-pairs --query "contains(KeyPairs[*].KeyName,\`$keyName\`)")" ]
	then
		aws ec2 create-key-pair \
			--key-name "$keyName" \
			--query 'KeyMaterial' \
			--output text > "$keyPairLocation" \
			&& chmod 0400 "$keyPairLocation" \
			&& echo Key pair created, location: "$keyPairLocation"
	fi
}

function deleteKeyPair(){
	local keyName="$1"
	local keyPairLocation="$2"
	
	aws ec2 delete-key-pair --key-name "$keyName"
	chmod 0700 "$keyPairLocation" && rm -f "$keyPairLocation"
}

function createCluster(){
	local stackName="$1"
	local keyName="$2"
	
	aws cloudformation create-stack \
		--stack-name "$stackName" \
		--template-body file://"$(dirname "$(realpath "$0")")"/cluster/demoECS.template.json \
		--parameters ParameterKey=KeyName,ParameterValue="$keyName" \
			ParameterKey=DesiredCapacity,ParameterValue=3 \
			ParameterKey=MaxSize,ParameterValue=5 \
		--capabilities "CAPABILITY_IAM"
}

function destroyCluster(){
	local stackName="$1"
	aws cloudformation delete-stack --stack-name "$stackName"
}

function clusterState(){
	local stackName="$1"
	local state="$(aws cloudformation describe-stacks --output text --query "Stacks[?StackName==\`$stackName\`].StackStatus")"

	case "$state" in
		CREATE_IN_PROGRESS)
			echo Cluster not ready.
			aws cloudformation describe-stack-events --stack-name "$stackName"
		;;
		CREATE_COMPLETE)
			echo Cluster Ready to use.
			echo Execute the following command to request on your app:
			echo curl http://"$(aws cloudformation describe-stacks --stack-name "$stackName" --output text --query "Stacks[0].Outputs[0].OutputValue")"
		;;
		DELETE_IN_PROGRESS)
			echo Cluster deletion in progress.
			aws cloudformation describe-stack-events --stack-name "$stackName"
		;;
		"")
			echo Cluster Not exists.
		;;
	esac
}

export AWS_DEFAULT_REGION="us-east-1"
keyName=ecsDemo
keyPairLocation="$(dirname "$0")"/"$keyName".pem
stackName=ECSDemo

case "$1" in
	create|creation)
		# If no key pair exist create it.
		createKeyPair "$keyName" "$keyPairLocation"

		# Create the cluster (aws stack)
		createCluster "$stackName" "$keyName"
	;;
	destroy|delete)
		# Remove key pair.
		deleteKeyPair "$keyName" "$keyPairLocation"

		# Destroy the cluster
		destroyCluster "$stackName"
	;;
	check|status)
		# Check cluster state 
		clusterState "$stackName"
	;;
	*)
		echo Usage:
		echo "$0" 'create|destroy|status|help'
	;;
esac
