provider "aws" {
  region = "us-east-1"
}
//Creating VPC
resource "aws_vpc" "sashukla-vpc" {
       cidr_block = "10.1.0.0/16"
       tags = {
        Name = "sashukla-vpc"
     }
   }

//Creating subnet 1
resource "aws_subnet" "sashukla-public_subnet_01" {
    vpc_id = aws_vpc.sashukla-vpc.id
    cidr_block = "10.1.1.0/24"
    map_public_ip_on_launch = "true"
    availability_zone = "us-east-1a"
    tags = {
      Name = "sashukla-public_subnet_01"
    }
}


//Creating subnet 2
resource "aws_subnet" "sashukla-public_subnet_02" {
    vpc_id = aws_vpc.sashukla-vpc.id
    cidr_block = "10.1.2.0/24"
    map_public_ip_on_launch = "true"
    availability_zone = "us-east-1b"
    tags = {
      Name = "sashukla-public_subnet_02"
    }
}

//Creating database subnet group
resource "aws_db_subnet_group" "sashukla_db_subnet_group" {
  name       = "example"
  subnet_ids = [
    aws_subnet.sashukla-public_subnet_01.id,
    aws_subnet.sashukla-public_subnet_02.id
  ]
}

//Creating an Internet Gateway
resource "aws_internet_gateway" "sashukla-igw" {
    vpc_id = aws_vpc.sashukla-vpc.id
    tags = {
      Name = "sashukla-igw"
    }
}

// Create a route table
resource "aws_route_table" "sashukla-public-rt" {
    vpc_id = aws_vpc.sashukla-vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.sashukla-igw.id
    }
    tags = {
      Name = "sashukla-public-rt"
    }
}

// Associating subnet-01 with route table
resource "aws_route_table_association" "sashukla-rta-public-subnet-1" {
    subnet_id = aws_subnet.sashukla-public_subnet_01.id
    route_table_id = aws_route_table.sashukla-public-rt.id
}

// Associating subnet-02 with route table
resource "aws_route_table_association" "sashukla-rta-public-subnet-2" {
    subnet_id = aws_subnet.sashukla-public_subnet_02.id
    route_table_id = aws_route_table.sashukla-public-rt.id
}

//Security group for database to allow IPs from the subnet CIDR block
resource "aws_security_group" "sashukla-db-security-group" {
  name        = "database security group"
  description = "database security group"
  vpc_id      =  aws_vpc.sashukla-vpc.id

  // Define inbound rule allowing traffic from a specific subnet
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.sashukla-public_subnet_01.cidr_block,aws_subnet.sashukla-public_subnet_02.cidr_block]  // Reference the subnet's CIDR block
  }
}

//Creating RDS instance to use for mediawiki
resource "aws_db_instance" "sashukla-rds" {
  identifier            = "my-db-instance"
  instance_class       = "db.t2.micro"
  engine               = "mysql"
  engine_version       = "8.0"
  allocated_storage    = 20
  storage_type         = "gp2"
  #publicly_accessible  = false
  db_name              = "mediawikidb"
  username             = var.db_username
  password             = var.db_password
  db_subnet_group_name  = aws_db_subnet_group.sashukla_db_subnet_group.name
  # Free tier settings
  #db_subnet_group_name = aws_db_subnet_group.sashukla-db-subnet-group.name
  backup_retention_period = 0
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.sashukla-db-security-group.id]

  tags = {
    Name = "MediaWikiDBInstance"
  }
}

module "securitygroupeks" {
  source = "../sg_eks"
  vpc_id     =     aws_vpc.sashukla-vpc.id
}
//module to create eks cluster
module "elatickubernetesservice" {
    source = "../eks"
    vpc_id     =     aws_vpc.sashukla-vpc.id
    subnet_ids = [aws_subnet.sashukla-public_subnet_01.id,aws_subnet.sashukla-public_subnet_02.id]
    sg_ids = module.sgs.security_group_public
}