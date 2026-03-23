# Random Notes

aws ec2 describe-instances Retrieve instance details filtered by tag name.

aws ec2 describe-instances \
--filters "Name=tag:Name,Values=<instance-name>" \
--query "Reservations[*].Instances[*].[InstanceId,InstanceType,PublicDnsName,PublicIpAddress,Placement.AvailabilityZone,VpcId,SecurityGroups[*].GroupId]"

aws ec2 describe-vpcs Get CIDR block for a VPC filtered by ID and tag.

aws ec2 describe-vpcs \
--vpc-ids <vpc-id> \
--filters "Name=tag:Name,Values=<vpc-name>" \
--query "Vpcs[*].CidrBlock"

aws ec2 describe-subnets List subnet IDs and CIDR blocks within a VPC.

aws ec2 describe-subnets \
--filters "Name=vpc-id,Values=<vpc-id>" \
--query "Subnets[*].[SubnetId,CidrBlock]"

aws ec2 describe-availability-zones List all availability zones in a region.

aws ec2 describe-availability-zones \
--filters "Name=region-name,Values=<region>" \
--query "AvailabilityZones[*].ZoneName"

aws ec2 create-security-group Create a named security group inside a VPC.

aws ec2 create-security-group \
--group-name <group-name> \
--description "<description>" \
--vpc-id <vpc-id>

aws ec2 authorize-security-group-ingress Add an inbound rule to a security group.

aws ec2 authorize-security-group-ingress \
--group-id <group-id> \
--protocol <protocol> \
--port <port> \
--source-group <source-group-id>

aws ec2 describe-security-groups Verify rules configured on a security group.

aws ec2 describe-security-groups \
--query "SecurityGroups[*].[GroupName,GroupId,IpPermissions]" \
--filters "Name=group-name,Values='<group-name>'"

aws ec2 create-subnet Create a subnet in a specific VPC and availability zone.

aws ec2 create-subnet \
--vpc-id <vpc-id> \
--cidr-block <cidr-block> \
--availability-zone <az>

aws rds create-db-subnet-group Create an RDS subnet group from multiple subnets.

aws rds create-db-subnet-group \
--db-subnet-group-name "<group-name>" \
--db-subnet-group-description "<description>" \
--subnet-ids <subnet-id-1> <subnet-id-2> \
--tags "Key=Name,Value=<tag-value>"

aws rds create-db-instance Provision an RDS database instance.

aws rds create-db-instance \
--db-instance-identifier <identifier> \
--engine <engine> \
--engine-version <version> \
--db-instance-class <class> \
--allocated-storage <gb> \
--availability-zone <az> \
--db-subnet-group-name "<subnet-group>" \
--vpc-security-group-ids <sg-id> \
--no-publicly-accessible \
--master-username <username> \
--master-user-password '<password>'

aws rds describe-db-instances Poll RDS instance status and retrieve endpoint address.

aws rds describe-db-instances \
--db-instance-identifier <identifier> \
--query "DBInstances[*].[Endpoint.Address,AvailabilityZone,PreferredBackupWindow,BackupRetentionPeriod,DBInstanceStatus]"

mysqldump Export a local database to a SQL backup file.

mysqldump \
--user=<username> \
--password='<password>' \
--databases <db-name> \
--add-drop-database > <output-file>.sql

mysql — Restore Restore a SQL backup file to an RDS instance.

mysql \
--user=<username> \
--password='<password>' \
--host=<rds-endpoint> \
< <backup-file>.sql

mysql — Connect Open an interactive session against a specific database on RDS.

mysql \
--user=<username> \
--password='<password>' \
--host=<rds-endpoint> \
<db-name>

