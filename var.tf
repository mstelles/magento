variable "region" {
  default = "eu-central-1"
}

variable "vpc_cidr" {
  default = "10.10.0.0/16"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "ami" {
  default = "ami-0e342d72b12109f91"
}

variable "public_subnet_cidr" {
  type    = "list"
  default = ["10.10.1.0/24", "10.10.2.0/24"]
}

variable "availability_zone" {
  type    = "list"
  default = ["eu-central-1a", "eu-central-1b"]
}

variable "public_subnet_names" {
  type    = "list"
  default = ["public_subnet_1a", "public_subnet_1b"]
}
