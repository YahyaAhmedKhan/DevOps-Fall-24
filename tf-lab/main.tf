# main.tf

# Defining the provider and region
provider "aws" {
  region = "us-east-1"
}

#Default VPC


data "aws_vpc" "default" {
  default = true
}