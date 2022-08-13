terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  access_key = var.access_key
  secret_key = var.secret_key

}

resource "aws_key_pair" "key" {
  key_name   = "ssh_key"
  public_key = file("~/.ssh/ec2.pub")
}
resource "aws_default_vpc" "default_vpc" {

}
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow ssh inbound traffic"
  
  # using default VPC
  vpc_id      = aws_default_vpc.default_vpc.id

  ingress {
    description = "TLS from VPC"
    
    # we should allow incoming and outoging
    # TCP packets
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    
    # allow all traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

}
resource "aws_instance" "my_ec2" {
  ami             = "ami-08d4ac5b634553e16"
  instance_type   = "t2.micro"
  
  # refering key which we created earlier
  key_name        = aws_key_pair.key.key_name
  
  # refering security group created earlier
  security_groups = [aws_security_group.allow_ssh.name]

  
}
