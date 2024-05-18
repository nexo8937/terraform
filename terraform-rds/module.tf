#Database Module
module "rds" {
    source                             = "github.com/nexo8937/terraform-modules//rds"
    vpc                                = data.terraform_remote_state.backend.outputs.vpc
    db-subnets                         = data.terraform_remote_state.backend.outputs.db_subnets
    db-name                            = ""
    username                           = ""
    password                           = ""
    instance-class                     = "db.t3.micro"
    allocated-storage                  = "200"
    engine                             = "mysql"
    app                                = "Brain-Scale"
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

