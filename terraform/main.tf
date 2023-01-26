variable "props" {
    type = map(string)
    default = {
    region = "us-east-1"
    vpcname = "vpc-demo"
    ami = "ami-00874d747dde814fa"
    itype = "t2.micro"
    subnetname = "demo-subnet"
    publicip = true
    keyname = "demokey"
    secgroupname = "Demo-Sec-Group"
    deploytag = "Demo"
    primarynodes = 1
    secondarynodes = 2
  }
}

provider "aws" {
  region = lookup(var.props, "region")
}

resource "aws_vpc" "vpc-demo" {
  cidr_block       = "10.10.0.0/16"
  instance_tenancy = "default"

  tags = {
    Deployment = lookup(var.props, "deploytag")
    Name = lookup(var.props, "vpcname")
  }
}

resource "aws_subnet" "demo-subnet" {
  vpc_id     = "${aws_vpc.vpc-demo.id}"
  cidr_block = "10.10.1.0/24"
  tags = {
    Deployment = lookup(var.props, "deploytag")
    Name = lookup(var.props, "subnetname")
  }
  depends_on = [ aws_vpc.vpc-demo ]
}

resource "aws_internet_gateway" "demo-ig" {
  vpc_id = "${aws_vpc.vpc-demo.id}"
  tags = {
    Deployment = lookup(var.props, "deploytag")
  }
  depends_on = [ aws_vpc.vpc-demo ]
}

resource "aws_route_table" "demo-rt" {
  vpc_id = "${aws_vpc.vpc-demo.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.demo-ig.id}"
  }
  depends_on = [ aws_internet_gateway.demo-ig ]
}

resource "aws_route_table_association" "demo-rta" {
  subnet_id      = aws_subnet.demo-subnet.id
  route_table_id = aws_route_table.demo-rt.id
  depends_on = [ aws_route_table.demo-rt ]
}

resource "aws_security_group" "demo-sg" {
  name = lookup(var.props, "secgroupname")
  description = lookup(var.props, "secgroupname")
  vpc_id = "${aws_vpc.vpc-demo.id}"

  // To Allow SSH Transport
  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = [var.my_ip]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  lifecycle {
    create_before_destroy = true
  }
  tags = {
    Deployment = lookup(var.props, "deploytag")
  }
}

resource "aws_instance" "demo-primary" {
  count = lookup(var.props, "primarynodes")
  ami = lookup(var.props, "ami")
  instance_type = lookup(var.props, "itype")
  subnet_id = "${aws_subnet.demo-subnet.id}"
  associate_public_ip_address = lookup(var.props, "publicip")
  key_name = lookup(var.props, "keyname")

  vpc_security_group_ids = [
    aws_security_group.demo-sg.id
  ]
  root_block_device {
    delete_on_termination = true
    volume_size = 25
    volume_type = "gp2"
  }
  tags = {
    Deployment = lookup(var.props, "deploytag")
    Name = "Primary"
    Role = "Primary"
    UUID = var.uuid
  }
  depends_on = [ aws_security_group.demo-sg ]
}

resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "pk" {
  key_name = lookup(var.props, "keyname")
  public_key = tls_private_key.pk.public_key_openssh
  tags = {
    Deployment = lookup(var.props, "deploytag")
  }
  provisioner "local-exec" {
    command = "echo '${tls_private_key.pk.private_key_pem}' > ../access/ec2_key.pem"
  }
}

resource "aws_instance" "demo-secondary" {
  count = lookup(var.props, "secondarynodes")
  ami = lookup(var.props, "ami")
  instance_type = lookup(var.props, "itype")
  subnet_id = "${aws_subnet.demo-subnet.id}"
  associate_public_ip_address = lookup(var.props, "publicip")
  key_name = lookup(var.props, "keyname")

  vpc_security_group_ids = [
    aws_security_group.demo-sg.id
  ]
  root_block_device {
    delete_on_termination = true
    volume_size = 50
    volume_type = "gp2"
  }
  tags = {
    Deployment = lookup(var.props, "deploytag")
    Name = "Secondary"
    Role = "Secondary"
    UUID = var.uuid
  }
  depends_on = [ aws_key_pair.pk ]
}

output "ec2primaryips" {
  value = ["${aws_instance.demo-primary.*.public_ip}"]
}

output "ec2secondaryips" {
  value = ["${aws_instance.demo-secondary.*.public_ip}"]
}