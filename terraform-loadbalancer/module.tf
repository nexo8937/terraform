module "loadbalancer" {
    source                             = "github.com/nexo8937/terraform-modules//loadbalancer"
    app                                = "Brain-Scale"
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
    key    = "network"
    region = "us-east-1"
  }
}
