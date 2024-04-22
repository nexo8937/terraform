module "network" {
    source = "github.com/nexo8937/terraform-modules//network"
    app                   = "Brain-Scale"
    vpc_cidr_block        = "10.0.0.0/16"
    public_subnet_ciders  = ["10.0.11.0/24", "10.0.12.0/24"]    
    private_subnet_ciders = ["10.0.21.0/24", "10.0.22.0/24"]
 }
