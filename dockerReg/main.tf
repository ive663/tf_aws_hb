provider "aws" {
    profile = "terraform"
    region = "eu-west-1"
    secret_key = "${var.secret_key}"
    access_key = "${var.access_key}"
}

data "aws_vpc" "default" {
    default = true
}

data "aws_subnets" "default" {
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}
resource "aws_launch_configuration" "example" {
  image_id = "ami-0f3164307ee5d695a"
  instance_type = "t2.medium"

  security_groups = [ aws_security_group.instance.id ]
  
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p ${var.server_port} &
              EOF

  # Required with an autoscaling group
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "default" {
  name        = "registry_security_group"
  description = "Allow access to Nexus dashboard & traffic on port 5000"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "registry_security_group"
  }
}


resource "aws_lb_listener" "http" {
    load_balancer_arn = aws_lb.example.arn
    port = 80
    protocol = "HTTP"

    #By default it just show a simple 404 page
    default_action {
      type = "fixed-response"

      fixed_response {
        content_type = "text/plain"
        message_body = "404 page not found"
        status_code = 404
      }
    }
}

resource "aws_security_group" "aws_lb" {
  name = "web-alb"
  # allow inbound HTTP requests
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #Allow all outbound requests
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
