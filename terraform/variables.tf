variable "distro" {
  type    = string
  default = "debian"
}

variable "user_map" {
  type = map(string)
  default = {
    debian = "admin"
    ubuntu = "ubuntu"
    redhat = "ec2-user"
  }
}

variable "ec2_type" {
  type    = string
  default = "t2.micro"
}

variable "cidr_block" {
  type    = string
  default = "10.123.0.0/16"
}

variable "subnet_ip" {
  type    = string
  default = "10.123.1.0/24"
}

variable "volume_size" {
  type    = number
  default = 10
}

