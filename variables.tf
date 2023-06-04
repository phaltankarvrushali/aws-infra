variable "region" {
  description = "Region"
}

variable "profile" {
  description = "The Deployment profile"
}

variable "public_internet_gateway_cidr" {
  description = "The CIDR block for the public subnet"

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

variable "public_subnets_cidr" {
  type        = list(any)
  description = "The CIDR block for the public subnet"
}

variable "private_subnets_cidr" {
  type        = list(any)
  description = "The CIDR block for the private subnet"
}

//Instance module

variable "ami_id" {
  description = "AMI ID"

}

variable "key_pair" {
  description = "Key Pair"

}

variable "application_port" {
  description = "Application Port"

}

# variable "instance_type" {
#   description = "Instance Type"

# }

variable "database_username" {
  description = "The username of the database"
  default     = "testdb"
}

variable "database_name" {
  description = "The name of the database"
  default     = "testdb"
}

variable "database_password" {
  description = "The password of the database"
  default     = "Vrushali@28"
}

variable "domain_root" {
  description = "The domain root"
}

variable "log_group_name" {
  description = "Log Group Name"
}
