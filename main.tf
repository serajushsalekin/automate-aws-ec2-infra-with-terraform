terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# Variables
variable "aws_region" {}
variable "aws_access_key" {}
variable "aws_secret_key" {}


data "aws_vpc" "default-vpc" {
  default = true
}

resource "aws_default_security_group" "default-sg" {
  vpc_id = data.aws_vpc.default-vpc.id

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "my-default-sg"
  }
}


resource "aws_instance" "MyAmazonEC2" {
  ami                    = "ami-007855ac798b5175e"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_default_security_group.default-sg.id]

  associate_public_ip_address = true

  user_data = file("user-data.sh")

  tags = {
    "Name" = "My-Ubuntu-EC2"
  }
}

output "ec2-ip" {
  value = aws_instance.MyAmazonEC2.public_ip
}


output "vpc" {
  value = data.aws_vpc.default-vpc.id
}
