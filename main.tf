# create vpc
resource "aws_vpc" "cust-vpc" {
  
  cidr_block = "10.0.0.0/16"
  tags = {
    Name="custvpc"
  }
}

#create subnet
resource "aws_subnet" "cust-subnet" {
    vpc_id = aws_vpc.cust-vpc.id
    cidr_block = "10.0.128.0/18"
    tags = {
      Name="custsubnet"
    }
}

#create internet gateway
resource "aws_internet_gateway" "cust-ig" {
  vpc_id = aws_vpc.cust-vpc.id
  tags = {
    Name="custIG"
  }
}

#create route table
resource "aws_route_table" "cust-rt" {
    vpc_id = aws_vpc.cust-vpc.id
    tags = {
      Name = "custRT"
    }
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.cust-ig.id
    }
  
}

#create subnet association
resource "aws_route_table_association" "custsunetassociation" {
    subnet_id = aws_subnet.cust-subnet.id
    route_table_id = aws_route_table.cust-rt.id
}


#create security group
resource "aws_security_group" "cust-SG" {
  vpc_id = aws_vpc.cust-vpc.id
  description = "allow all traffic"
  tags = {
    Name="custSG"
  }

  ingress{
    description = "allow ssh inbound traffic"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "allow all outbound traffic"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#create server
resource "aws_instance" "name" {
  ami = "ami-05c179eced2eb9b5b"
  instance_type = "t2.micro"
  key_name = "multicloudkeypair-2"
  subnet_id = aws_subnet.cust-subnet.id
  associate_public_ip_address = true
  security_groups = [aws_security_group.cust-SG.id]
  
  tags= {
    Name="cust-server"
  }
}