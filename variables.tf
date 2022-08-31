variable "ami_id" {
  description = "AMI ID for base system installation"
  type        = string
  # NixOS x86-64 22.05 HVM EBS
  default = "ami-034946f0c47088751"
}

variable "instance_type" {
  description = "Instance type for host"
  type        = string
  default     = "c5.xlarge"
}

variable "ssh_pubkey" {
  description = "Path to ssh pubkey"
  type        = string
}
