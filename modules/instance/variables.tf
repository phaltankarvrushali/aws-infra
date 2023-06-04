variable "ami_id" {
    description = "AMI ID"

}

variable "key_pair" {
    description = "Key Pair"
  
}

variable "vpc_id" {
    description = "VPC ID"
  
}

variable "public_subnet_id" {
    description = "Public Subnet ID"
    type = list(any)
  
}

variable "private_subnet_id" {
    description = "Private Subnet ID"
    type = list(any)
  
}

variable "log_group_name" {
    description = "Log Group Name"
  
}

variable "application_port" {
    description = "Application Port"

}

variable "database_username" {
  description = "The username of the database"
}

variable "database_password" {
  description = "The password of the database"
}
variable "database_name" {
  description = "The name of the database"
}
variable "ec2_iam_role" {
  description = "The name of the IAM role"
}
variable "bucket_name" {
  description = "The name of the S3 bucket"
}
  
variable "region" {
  description = "The region of the database"
}
  
variable "domain_root" {
  description = "The domain root"
}

variable "profile" {
  description = "value of profile"
}
