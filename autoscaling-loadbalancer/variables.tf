
variable "region" {
    description = "AWS region"
    default = "us-east-1"
}

variable "app" {
    description = "Application Name"
    default = "Brain-Scale"
}

#Launch Template
variable "image_id" {
    default = "ami-080e1f13689e07408"
}

variable "instance_type" {
    default = "t2.micro"
}

#Autoscaling
variable "desired_capacity" {
    description = "Desired capacity of the autoscaling group"
    default = 1
}

variable "max_size" {
    description = "Maximum size of the autoscaling group"
    default = 2
}

variable "min_size" {
    description = "Minimum size of the autoscaling group"
    default = 1
}

variable "app_port_sg" {
    description = "Autoscaling security group ports"
    type = list
    default = ["3000"]
}

variable "healthy_check_type" {
  description = "The type of healty check"
  default = "ELB"
}

#Autoscaling Policie
variable "policy_adjustment_type" {
  description = "The adjustment type for the autoscaling policy"
  default     = "ChangeInCapacity"
}

variable "policy_scaling_adjustment" {
  description = "The scaling adjustment for the autoscaling policy when scaling up"
  default     = "1"
}

variable "policy_cooldown" {
  description = "The cooldown period for the autoscaling policy "
  default     = "300"
}

variable "down_scaling_adjustment" {
  description = "The scaling adjustment for the autoscaling policy when scaling down"
  default     = -1
}

#CloudWatch Metrics
variable "scale_up_threshold" {
  description = "CPU utilization threshold for triggering scale-up actions"
  default = "80"
}

variable "scale_down_threshold" {
  description = "CPU utilization threshold for triggering scale-down actions"
  default = "20"
}

variable "scale_up_period" {
  description = "The period (in seconds) for evaluating CPU utilization during scale-up"
  default = "120"
}

variable "scale_down_period" {
  description = "The period (in seconds) for evaluating CPU utilization during scale-down"
  default = "120"
}

variable "evaluation_periods" {
  description = "The number of periods for applying the alarm's statistic"
  default = "2"
}

#LoadBalancer
variable "app_lb_port_sg" {
    description = "Loadbalancer security group ports"
    type = list
    default = ["80"]
}

variable "lb_listner_port" {
    description = "The port for the load balancer listener"
    default = "80"
}

variable "target_port" {
  description = "The port for the target group"
  default = "3000"
}

variable "health_check_protocol" {
  description = "Protocol used for health checks"
  default     = "HTTP"
}

variable "health_check_path" {
  description = "Endpoint path for health checks"
  default     = "/login"
}

variable "health_check_port" {
  description = "Port on which health checks are performed"
  default     = 3000
}

variable "health_check_healthy_threshold" {
  description = "Number of consecutive successful health checks to consider an instance healthy"
  default     = 5
}

variable "health_check_unhealthy_threshold" {
  description = "Number of consecutive failed health checks to consider an instance unhealthy"
  default     = 2
}

variable "health_check_timeout" {
  description = "Time, in seconds, that the health check waits for a response"
  default     = 5
}

variable "health_check_interval" {
  description = "Interval, in seconds, between health checks"
  default     = 150
}

variable "health_check_matcher" {
  description = "String to match against the response to determine if the health check is successful"
  default     = "200"
}

variable "load_balancer_type" {
  description = "Type of the load balancer"
  default     = "application"
}
