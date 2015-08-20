# If no ECSDemoSubnet exist create it.
subnetName=ECSDemoSubnet
if [ "$(aws ec2 describe-subnets --filters Name=tag:Name,Values="$subnetName" | jq --raw-output '.Subnets | length')" -eq 0 ]
then
	cidrBlock="192.168.3.0/24"
	vpcID="$(aws ec2 create-vpc --cidr-block "$cidrBlock" | jq --raw-output '.Vpc.VpcId')"
	aws ec2 create-tags \
		--resources "$vpcID" \
		--tags Key=Name,Value=ECSDemoVPC

	subnetID="$(aws ec2 create-subnet --vpc-id "$vpcID" --cidr-block "$cidrBlock" | jq --raw-output '.Subnet.SubnetId')"
	aws ec2 create-tags \
		--resources "$subnetID" \
		--tags Key=Name,Value="$subnetName"
fi
