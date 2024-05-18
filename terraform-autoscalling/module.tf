module "autoscalling" {
    source                   = "github.com/nexo8937/terraform-modules//autoscalling"
    app                      = "Brain-Scale"
    #launch-template
    image_id                 = "ami-080e1f13689e07408"
    instance_type            = "t2.micro"
    aws_iam_instance_profile = data.terraform_remote_state.ecr.outputs.instance_profile
    user-data-file           = "user_data.sh"
    #network
    private_subnets          = data.terraform_remote_state.network.outputs.private_subnets
    vpc                      = data.terraform_remote_state.network.outputs.vpc
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
    target_group              = data.terraform_remote_state.loadbalancer.outputs.load-balancer-target-group
    database-sg               = data.terraform_remote_state.rds.outputs.database_sg
}

#remote-state-data-network
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "tfstate-brainscale"
    key    = "network"
    region = "us-east-1"
  }
}

#remote-state-data-ecr
data "terraform_remote_state" "ecr" {
  backend = "s3"
  config = {
    bucket = "tfstate-brainscale"
    key    = "ecr"
    region = "us-east-1"
  }
}

#remote-state-data-loadbalancer
data "terraform_remote_state" "loadbalancer" {
  backend = "s3"
  config = {
    bucket = "tfstate-brainscale"
    key    = "loadbalancer"
    region = "us-east-1"
   }
 }

#remote-state-rds
data "terraform_remote_state" "rds" {
  backend = "s3"
  config = {
    bucket = "tfstate-brainscale"
    key    = "rds"
    region = "us-east-1"
  }
}
