module "network" {
    source = "github.com/nexo8937/terraform-modules//network"
    app                   = var.app
    vpc_cidr_block        = "10.0.0.0/16"
    public_subnet_ciders  = ["10.0.11.0/24", "10.0.12.0/24"]    
    private_subnet_ciders = ["10.0.21.0/24", "10.0.22.0/24"]
 }

module "ecr" {
    source                = "github.com/nexo8937/terraform-modules//ecr"
    app                   = var.app
    ecr_repo_name         = "brain-scale-simple-app"
}
