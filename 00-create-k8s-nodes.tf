##Setup variables

variable "ami" {
  default = "ami-0a313d6098716f372"
}
variable "image-flavor" {
  default="t2.micro"
}
variable "key-pair" {
  default="aws-key-1"
}

variable "aws-region" {
  default="us-east-1"
}
variable "tag-name" {
  default="a-tag"
}
variable "tag-cpaccount" {
  default="another-tag"
}
variable "master-count" {
  default="1"
}
variable "node-count" {
  default="3"
}
variable vpc_cidr {
  default = "172.32.0.0/16"
}
variable owner {
  default = "Kubernetes"
}
variable vpc_name {
  description = "Name of the VPC"
  default = "kubernetes"
}

##Define AWS provider
provider "aws" {
  region            = "${var.aws-region}"
}

##Create a security group for deployment.
resource "aws_security_group" "dep-k8s-sg" {
  #vpc_id            = "${aws_vpc.kubernetes.id}"
  name              = "deployment-k8s-sg"
  description       = "Allow incoming ssh from anywhere, and any outgoing connexion to anywhere"
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

##VPC
/*resource "aws_vpc" "kubernetes" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_hostnames = true

  tags = {
    Name = "${var.vpc_name}"
    Owner = "${var.owner}"
  }
}

# Subnet (public)
resource "aws_subnet" "kubernetes" {
  vpc_id = "${aws_vpc.kubernetes.id}"
  cidr_block = "${var.vpc_cidr}"
  #availability_zone = "${var.aws-region}"

  tags = {
    Name = "kubernetes"
    Owner = "${var.owner}"
  }
}*/


##Create masters instances
resource "aws_instance" "k8s-master" {
  count             = "${var.master-count}"
  ami               = "${var.ami}"
  instance_type     = "${var.image-flavor}"
  key_name          = "${var.key-pair}"
  #subnet_id = "${aws_subnet.kubernetes.id}"
  #private_ip = "${cidrhost(var.vpc_cidr, 20 + count.index)}"
  vpc_security_group_ids = ["${aws_security_group.dep-k8s-sg.id}"]
  associate_public_ip_address = true

  tags = {
    Name            = "${var.tag-name}-k8s-master-${count.index}"
  }
}

##Create masters instances
resource "aws_instance" "k8s-node" {
  count             = "${var.node-count}"
  ami               = "${var.ami}"
  instance_type     = "${var.image-flavor}"
  key_name          = "${var.key-pair}"
  #subnet_id = "${aws_subnet.kubernetes.id}"
  #private_ip = "${cidrhost(var.vpc_cidr, 20 + count.index)}"
  vpc_security_group_ids = ["${aws_security_group.dep-k8s-sg.id}"]
  associate_public_ip_address = true

  tags = {
    Name  = "${var.tag-name}-k8s-node-${count.index}"
  }
}
