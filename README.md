# Deploy EC2 instances with terraform
- Set up the architecture below using terraform

## The architecture
[<img src="./asset/architecture.png" width="480"/>](architecture.png)

### Terraform setup
#### Backend
- To store state file
- To configure a remote backend with s3 and Dynamodb, use the snippet below
```sh
terraform {
  backend "s3" {
    bucket         = "bucket-name"
    key            = "tfstate/terraform.tfstate"
    region         = "aws-region"
    encrypt        = true
    dynamodb_table = "dynamodb-table"
  }
}
```

#### The following resources will be created
- VPC
- 2 Subnets (public & private)
- Internet gateway
- NAT gateway
- Route tables
- Route table associations
- Security groups
- 2 EC2 instances
- Ability to SSH into these instances

#### Running the service
- Obtain your account access key and secret key from aws
- Navigate to terminal and configure the cli
```sh
    export AWS_ACCESS_KEY_ID="access-key-id"
    export AWS_SECRET_ACCESS_KEY="access-key-secret"
```