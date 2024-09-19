resource "aws_security_group" "my_alb" {
  name        = "allow End User"
  description = "Allow Enduser inbound traffic"
  vpc_id      = aws_vpc.new-vpc.id

  ingress {
    description = "End Users"
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

  tags = {
    Name      = "alb-sg"
    Terraform = "True"
  }
}


# Create the Application Load Balancer
resource "aws_lb" "my_alb" {
  name               = "my-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.public[0].id, aws_subnet.public[1].id, aws_subnet.public[2].id] 
  enable_deletion_protection = false  
  security_groups    = [aws_security_group.my_alb.id]
}

# Define the target group for the ALB
resource "aws_lb_target_group" "my_target_group" {
  name        = "my-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.new-vpc.id
  target_type = "instance"

#   health_check {
#     path     = "/health-check" 
#     port     = "80"
#     protocol = "HTTP"
#   }
}

# Target Group attachment
resource "aws_lb_target_group_attachment" "attach1" {
  target_group_arn = aws_lb_target_group.my_target_group.arn
  target_id        = aws_instance.ec2-instance1.id
  port             = 80
  depends_on       = [ aws_instance.ec2-instance1 ]
}

resource "aws_lb_target_group_attachment" "attach2" {
  target_group_arn = aws_lb_target_group.my_target_group.arn
  target_id        = aws_instance.ec2-instance2.id
  port             = 80
  depends_on       = [ aws_instance.ec2-instance2 ]
}

# ALB Listner

resource "aws_lb_listener" "myalb-listner" {
  load_balancer_arn = aws_lb.my_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_target_group.arn
  }
}