# A small dedicated network, instead of relying on the account's default VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.20.0.0/16"
  enable_dns_hostnames = true
  tags                 = { Name = "${var.project}-vpc" }
}
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.20.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]
  tags                    = { Name = "${var.project}-public" }
}
data "aws_availability_zones" "available" { state = "available" }
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.project}-igw" }
}
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = { Name = "${var.project}-routes" }
}
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}
resource "aws_security_group" "web" {
  name_prefix = "${var.project}-web-"
  description = "Only HTTP to nginx; no SSH or database access"
  vpc_id      = aws_vpc.main.id
  ingress {
    description = "Demo website"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${var.project}-sg" }
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
resource "aws_instance" "web" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.web.id]
  user_data = templatefile("${path.module}/user_data.sh.tftpl", {
    compose               = filebase64("${path.module}/../compose.yaml")
    backend_dockerfile    = filebase64("${path.module}/../backend/Dockerfile")
    backend_main          = filebase64("${path.module}/../backend/main.py")
    backend_requirements  = filebase64("${path.module}/../backend/requirements.txt")
    backend_dockerignore  = filebase64("${path.module}/../backend/.dockerignore")
    frontend_dockerfile   = filebase64("${path.module}/../frontend/Dockerfile")
    frontend_html         = filebase64("${path.module}/../frontend/index.html")
    frontend_nginx        = filebase64("${path.module}/../frontend/nginx.conf")
    frontend_dockerignore = filebase64("${path.module}/../frontend/.dockerignore")
  })
  user_data_replace_on_change = true
  root_block_device {
    volume_size = 16
    volume_type = "gp3"
    encrypted   = true
  }
  depends_on = [aws_route_table_association.public]
  tags       = { Name = "${var.project}-ec2" }
}
