provider "aws" {
  region = var.region
}

###############
##  NETWORK  ##
###############

#data
data "aws_availability_zones" "working" {}

#VPC
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "${var.app} vpc"
  }
}

#Public Subnets
resource "aws_subnet" "pub-sub-A" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.pub_sub_A_cidr_block
  availability_zone       = data.aws_availability_zones.working.names[0]
  map_public_ip_on_launch = true
  tags = {
    "Name" = "${var.app} Public Subnet A"
  }
}

resource "aws_subnet" "pub-sub-B" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.pub_sub_B_cidr_block
  availability_zone       = data.aws_availability_zones.working.names[1]
  map_public_ip_on_launch = true
  tags = {
    "Name" = "${var.app} Public Subnet B"
  }
}

#Private Subnets
resource "aws_subnet" "priv-sub-A" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.priv_sub_A_cidr_block
  availability_zone = data.aws_availability_zones.working.names[0]
  tags = {
    Name = "${var.app} Private Subnet A"
  }
}

resource "aws_subnet" "priv-sub-B" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.priv_sub_B_cidr_block
  availability_zone = data.aws_availability_zones.working.names[1]
  tags = {
    Name = "${var.app} Private Subnet B"
  }
}

#Elastic Ip for Nat
resource "aws_eip" "elastic-ip" {
  tags = {
    Name = "${var.app} Elastic Ip"
  }
}


#Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.app} Intenet Gateway"
  }
}

#NAT gateway
resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.elastic-ip.id
  subnet_id     = aws_subnet.pub-sub-A.id
  tags = {
    Name = "${var.app} Nat Gateway"
  }
}

#Route table for Public Subnets
resource "aws_route_table" "pub-route" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${var.app} Public Route"
  }
}

#Add Public Subnets to Route
resource "aws_route_table_association" "pub-1" {
  subnet_id      = aws_subnet.pub-sub-A.id
  route_table_id = aws_route_table.pub-route.id
}

resource "aws_route_table_association" "pub-2" {
  subnet_id      = aws_subnet.pub-sub-B.id
  route_table_id = aws_route_table.pub-route.id
}

#Route table for Private Subnets
resource "aws_route_table" "priv-route" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gw.id
  }
  tags = {
    Name = "${var.app} Private Route"
  }
}

#Add Private Subnets to Route
resource "aws_route_table_association" "priv-1" {
  subnet_id      = aws_subnet.priv-sub-A.id
  route_table_id = aws_route_table.priv-route.id
}

resource "aws_route_table_association" "priv-2" {
  subnet_id      = aws_subnet.priv-sub-B.id
  route_table_id = aws_route_table.priv-route.id
}




###################
##  Autoscaling  ##
###################

#Launch Tamplate
resource "aws_launch_template" "launch-template" {
  name                   = "${var.app}-Launch-Template"
  image_id               = var.image_id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.autoscaling-sg.id]
  user_data              = base64encode(file("user_data.sh")) 
  
  iam_instance_profile {
    name = aws_iam_instance_profile.ecr_instance_profile.name
  }
  
  lifecycle {
    create_before_destroy = true
  }
}



#Autoscaling Group
resource "aws_autoscaling_group" "autoscaling-group" {
  name                      = "${var.app}-Autoscaling-Group-${aws_launch_template.launch-template.latest_version}"
  desired_capacity          = var.desired_capacity
  max_size                  = var.max_size
  min_size                  = var.min_size
  health_check_type         = var.healthy_check_type
  vpc_zone_identifier       = [aws_subnet.priv-sub-A.id , aws_subnet.priv-sub-B.id]
  target_group_arns         = [aws_lb_target_group.target-group.arn]
  launch_template {
    id      = aws_launch_template.launch-template.id
    version = aws_launch_template.launch-template.latest_version
  }
  lifecycle {
    create_before_destroy = true
  }
}

#Autoscaling SECURITY GROUP
resource "aws_security_group" "autoscaling-sg" {
  name        = "autoscaling security group"
  vpc_id      = aws_vpc.vpc.id
  description = "Allow http"

  dynamic "ingress" {
    for_each = var.app_port_sg
    content {
    from_port   = ingress.value
    to_port     = ingress.value
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
   }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.app} Autoscaling Security Group"
  }
}

#Autoscaling Policie up
resource "aws_autoscaling_policy" "atoscaling-policy-up" {
  name                   = "${var.app}-Policy-Up"
  autoscaling_group_name = aws_autoscaling_group.autoscaling-group.name
  adjustment_type        = var.policy_adjustment_type
  scaling_adjustment     = var.policy_scaling_adjustment
  cooldown               = var.policy_cooldown
  policy_type            = "SimpleScaling"
}

#Scale UP Alarm
resource "aws_cloudwatch_metric_alarm" "scale-up-alarm" {
  alarm_name          = "${var.app}-Scale-Up-Alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = var.scale_up_period
  statistic           = "Average"
  threshold           = var.scale_up_threshold
  dimensions = {
    "autoscalinggroupname" = aws_autoscaling_group.autoscaling-group.name
  }
  alarm_actions     = [aws_autoscaling_policy.atoscaling-policy-up.arn]
}


#Autoscaling Policie down
resource "aws_autoscaling_policy" "atoscaling-policy-down" {
  name                   = "${var.app}-policy-down"
  scaling_adjustment     = -1
  adjustment_type        = var.policy_adjustment_type
  cooldown               = var.policy_cooldown
  autoscaling_group_name = aws_autoscaling_group.autoscaling-group.name
  policy_type            = "SimpleScaling"
}

#Scale DOWN Alarm
resource "aws_cloudwatch_metric_alarm" "scale-down-alarm" {
  alarm_name          = "scale-down-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = var.evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = var.scale_down_period
  statistic           = "Average"
  threshold           = var.scale_down_threshold
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.autoscaling-group.name
  }
  alarm_actions     = [aws_autoscaling_policy.atoscaling-policy-down.arn]
}





###################
## Load Balancer ##
###################

resource "aws_lb" "load-balancer" {
  name                 = "${var.app}-LB"
  load_balancer_type   = var.load_balancer_type
  security_groups      = [aws_security_group.lb-sg.id]
  subnets              = [aws_subnet.pub-sub-A.id, aws_subnet.pub-sub-B.id]
}

resource "aws_lb_target_group" "target-group" {
 name             =  "${var.app}-TG"
 vpc_id           =  aws_vpc.vpc.id
 port             =  var.target_port
 protocol         =  "HTTP"
 
health_check {
    protocol              = var.health_check_protocol
    path                  = var.health_check_path
    port                  = var.health_check_port
    healthy_threshold     = var.health_check_healthy_threshold
    unhealthy_threshold   = var.health_check_unhealthy_threshold
    timeout               = var.health_check_timeout
    interval              = var.health_check_interval
    matcher               = var.health_check_matcher
 }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn   =  aws_lb.load-balancer.arn
  port                =  var.lb_listner_port
  protocol            =  "HTTP"

  default_action {
    type             =   "forward"
    target_group_arn =   aws_lb_target_group.target-group.arn
  }
}

#Load Balancer security group
resource "aws_security_group" "lb-sg" {
  name        = "load balancer security group"
  vpc_id      = aws_vpc.vpc.id
  description = "Allow HTTP Traffic"

  dynamic "ingress" {
    for_each = var.app_lb_port_sg
    content {
    from_port   = ingress.value
    to_port     = ingress.value
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
   }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.app} Load Balancer Security Group"
  }
}


#########
## IAM ##
#########

#EC2 Role
resource "aws_iam_role" "ecr_role" {
  name = "ecr-role"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action    = "sts:AssumeRole"
    }]
  })
}

#Attach Policy to Role
resource "aws_iam_policy_attachment" "ecr_policy_attachment" {
  name       = "AmazonEC2ContainerRegistryFullAccess"
  roles      = [aws_iam_role.ecr_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}

#EC2 Instance Profile
resource "aws_iam_instance_profile" "ecr_instance_profile" {
  name = "ecr-instance-profile"
  role = aws_iam_role.ecr_role.name
}

