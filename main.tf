resource "aws_vpc" "my_vpc" {
  cidr_block = var.cidr
}

resource "aws_subnet" "subnet1" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = var.sub1_cidr
  availability_zone       = var.sub1_availability
  map_public_ip_on_launch = true
}
resource "aws_subnet" "subnet2" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = var.sub2_cidr
  availability_zone       = var.sub2_availability
  map_public_ip_on_launch = true
}
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.my_vpc.id
}
resource "aws_route_table" "route" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
}
resource "aws_route_table_association" "sub1_rt" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.route.id
}
resource "aws_route_table_association" "sub2_rt" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.route.id
}
resource "aws_security_group" "sg" {
  name   = "pro-sg"
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    description = "http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "outbouns - all"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "web"
  }
}
resource "aws_s3_bucket" "s3" {
  bucket = "techoclouds-shiva123shiva"

}
resource "aws_instance" "server1" {
  ami             = "ami-04b4f1a9cf54c11d0"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.sg.id]
  subnet_id       = aws_subnet.subnet1.id
  user_data       = file("userdata1.sh")
}
resource "aws_instance" "server2" {
  ami             = "ami-04b4f1a9cf54c11d0"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.sg.id]
  subnet_id       = aws_subnet.subnet2.id
  user_data       = file("userdata2.sh")
}
resource "aws_lb" "alb" {
  name               = "alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg.id]
  subnets            = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]

  tags = {
    Name = "pro"
  }
}
resource "aws_lb_target_group" "target_group" {
  name     = "target-group"
  port     = "80"
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_vpc.id

  health_check {
    path = "/"
    port = "traffic-port"
  }

}
resource "aws_lb_target_group_attachment" "attach-server1" {
  target_group_arn = aws_lb_target_group.target_group.arn
  target_id        = aws_instance.server1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "attach-server2" {
  target_group_arn = aws_lb_target_group.target_group.arn
  target_id        = aws_instance.server2.id
  port             = 80
}
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.target_group.arn
    type             = "forward"
  }

}
output "load_balancer_dns" {
  value = aws_lb.alb.dns_name

}
