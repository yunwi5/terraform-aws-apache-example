variable "vpc_id" {
  type = string
  default = "vpc-04939ebf7a0e41ae8"
}

variable "my_ip_with_cidr" {
  type = string
  description = "Provide IP e.g. 101.100.140.10/32"
}

variable "public_key" {
  type = string
  description = "public key" 
}

variable "instance_type" {
  type = string
  default = "t2.micro"
}

variable "server_name" {
  type = string
  default = "Apache Example Server"
}
