module "autoscalling" {
    source                   = "github.com/nexo8937/terraform-modules//autoscalling"
    app                      = var.app
    #launch-template
    image_id                 = "ami-080e1f13689e07408"
    instance_type            = "t2.micro"
    aws_iam_instance_profile = data.terraform_remote_state.backend.outputs.instance_profile
    user-data-file           = "user_data.sh"
    #network
    private_subnets          = data.terraform_remote_state.backend.outputs.private_subnets
    vpc                      = data.terraform_remote_state.backend.outputs.vpc
    #autoscalling-group
    desired_capacity          = 2
    max_size                  = 2
    min_size                  = 1
    healthy_check_type        = "ELB"
    app_port_sg               = ["3000"]
    #autoscalling-policy
    policy_adjustment_type    = "ChangeInCapacity"
    policy_scaling_adjustment = "1"
    policy_cooldown           = "300"
    down_scaling_adjustment   = -1
    #CloudWatch Metrics
    scale_up_threshold        = "80"
    scale_down_threshold      = "20"
    scale_up_period           = "120"
    scale_down_period         = "120"
    evaluation_periods        = "2"
    target_group              = module.loadbalancer.load-balancer-target-group 
}

module "loadbalancer" {
    source                             = "github.com/nexo8937/terraform-modules//loadbalancer"
    app                                = var.app
    #network
    vpc                                = data.terraform_remote_state.backend.outputs.vpc
    public_subnets                     = data.terraform_remote_state.backend.outputs.public_subnets
    #load-balancer
    app_lb_port_sg                     = ["80"]
    lb_listner_port                    = "80"
    load_balancer_type                 = "application"
    #target-group
    target_port                        = "3000"
    protocol                           = "HTTP"
    health_check_path                  = "/login"
    health_check_port                  = 3000
    health_check_healthy_threshold     = 5
    health_check_unhealthy_threshold   = 2
    health_check_timeout               = 10
    health_check_interval              = 150
    health_check_matcher               = "200"
}



#remote-state-data
data "terraform_remote_state" "backend" {
  backend = "s3"
  config = {
    bucket = "tfstate-brainscale"
    key    = "network-ecr"
    region = "us-east-1"
  }
}
