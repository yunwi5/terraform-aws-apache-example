Terraform Module to provision an EC2 instance that is running Apache.

Not intended for production use. Just showcasing a custom module on Terraform Registry.

```hcl
terraform {
}

provider "aws" {
  region = "ap-southeast-2"
}

module "apache" {
  source = ".//terraform-aws-apache-example"

  vpc_id          = "vpc-00000000"
  my_ip_with_cidr = "IP_ADDRESS/32"
  public_key      = "ssh-rsa ..."
  instance_type   = "t2.micro"
  server_name     = "Apache Example Server"
}

output "public_ip" {
  value = module.apache.public_ip
}
```# terraform-aws-apache-example
