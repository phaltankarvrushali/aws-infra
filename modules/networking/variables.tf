variable "region" {
  description = "Region"
}

variable "profile" {
  description = "The Deployment profile"
}

variable "vpc_cidr" {
  description = "The CIDR block of the vpc"
}

variable "public_route_table_id" {
  description = "The CIDR block of the vpc"
}

# variable "vpc_cidr_count" {
#   description = "The CIDR block of the vpc"
# }

variable "public_internet_gateway_cidr" {
  description = "The CIDR block for the public subnet"

}


variable "public_subnets_cidr" {
  type        = list(any)
  description = "The CIDR block for the public subnet"
}

variable "private_subnets_cidr" {
  type        = list(any)
  description = "The CIDR block for the private subnet"
}

variable "availability_zones" {
  description = "The az that the resources will be launched"
}

variable "public_subnet_id" {
  description = "Public Subnet ID"
  type = list(any)
}