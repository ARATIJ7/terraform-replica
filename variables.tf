variable "region" {
  description = "The AWS region to deploy the resources."
  default     = "us-west-2"
}

variable "instance_type" {
  description = "The type of instance to create."
  default     = "t2.micro"
}

variable "key_name" {
  description = "The key pair name to access the EC2 instances."
  type        = string
}

variable "replica_count" {
  description = "The number of MongoDB replica set members."
  default     = 3
}
