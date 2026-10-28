
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# --------------------------------------------------
# 1. AWS provider
# --------------------------------------------------

provider "aws" {
  region = "us-east-1"
}

# --------------------------------------------------
# 2. Input variables
# --------------------------------------------------

variable "key_name" {
  description = "Name of an existing AWS EC2 key pair"
  type        = string
}

variable "ssh_allowed_cidr" {
  description = "Your public IP address in CIDR format, for example 203.0.113.10/32"
  type        = string

  validation {
    condition     = can(cidrhost(var.ssh_allowed_cidr, 0))
    error_message = "Provide a valid CIDR range, preferably your public IP followed by /32."
  }
}

# --------------------------------------------------
# 3. VPC
# --------------------------------------------------

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "jubril-cloud-vpc"
    Environment = "development"
    Project     = "Jubril Cloud World"
  }
}

# --------------------------------------------------
# 4. Public subnet
# --------------------------------------------------

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "jubril-public-subnet"
  }
}

# --------------------------------------------------
# 5. Internet Gateway
# --------------------------------------------------

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "jubril-internet-gateway"
  }
}

# --------------------------------------------------
# 6. Public route table
# --------------------------------------------------

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "jubril-public-route-table"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# --------------------------------------------------
# 7. Security group
# --------------------------------------------------

resource "aws_security_group" "web" {
  name        = "jubril-web-security-group"
  description = "Allow SSH, HTTP and Java application traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH access from the approved IP range"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_allowed_cidr]
  }

  ingress {
    description = "Portfolio website HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Java application HTTP"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jubril-web-security-group"
  }
}

# --------------------------------------------------
# 8. EC2 instance using Amazon Linux 2023
# --------------------------------------------------

resource "aws_instance" "app_server" {
  ami                         = "resolve:ssm:/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
  instance_type               = "t3.small"
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.web.id]
  key_name                    = var.key_name
  associate_public_ip_address = true

  root_block_device {
    volume_size           = 12
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
  }

  tags = {
    Name        = "jubril-cloud-app-server"
    Environment = "development"
    Project     = "Jubril Cloud World"
  }

  depends_on = [
    aws_route_table_association.public,
    aws_internet_gateway.main
  ]
}

# --------------------------------------------------
# 9. Outputs for GitHub Actions and Ansible
# --------------------------------------------------

output "instance_id" {
  description = "ID of the EC2 application server"
  value       = aws_instance.app_server.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 server"
  value       = aws_instance.app_server.public_ip
}

output "instance_public_dns" {
  description = "Public DNS name of the EC2 server"
  value       = aws_instance.app_server.public_dns
}

output "portfolio_url" {
  description = "Portfolio website URL"
  value       = "http://${aws_instance.app_server.public_ip}"
}

output "java_application_url" {
  description = "Java application base URL"
  value       = "http://${aws_instance.app_server.public_ip}:8080"
}
