# Application Deployment to AWS with Terraform Modules

Before getting started, ensure you have installed the following tools:
- Terraform
- AWS CLI
- Docker

Before start set Your s3 bucket informatin for terraform remote_state file and dynamodb file forl lock in terraform-network-ecr/main.tf and terraform-autoscalling-loadbalancer/main.tf

## Configure AWS Credentials

Make sure you have your AWS credentials configured using the AWS CLI:

Deploying network(vpc, subnets), ECR and creating ecr-role.

             cd terraform-network-ecr
             terraform init
             terraform apply

Push Docker image to already created ECR

             cd ../
             git cone https://github.com/nexo8937/brainscale.git
             sudo docker build -t brain-scale-simple-app .
             sudo docker login -u AWS -p $(aws ecr get-login-password --region <Youre-region>) <Youre-account-id>.dkr.ecr.us-east-1.amazonaws.com
             sudo docker tag brain-scale-simple-app:latest <Youre-account-id>.dkr.ecr.us-east-1.amazonaws.com/<Youre repo name>:latest
             sudo docker push <Youre-account-id>.dkr.ecr.us-east-1.amazonaws.com/<Youre repository name>:latest

Deploying autoscaling and application loadbalancer

             cd terraform-autoscalling-loadbalancer
             terraform init
             terraform apply

After deploying the autoscaling group and load balancer, you will see the load balancer DNS name in the output.
