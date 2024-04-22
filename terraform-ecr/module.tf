module "ecr" {
    source                = "github.com/nexo8937/terraform-modules//ecr"
    app                   = "Brain-Scale"
    ecr_repo_name         = "brain-scale-simple-app"
}
