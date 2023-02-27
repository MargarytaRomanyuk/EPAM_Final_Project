//variable vpc_cidr_block {
  //  default = "0.0.0.0/0"
//}
variable env_prefix {
    default = "dev"
}
variable my_ip {
    default = "0.0.0.0/0"
}
variable jenkins_ip {
    default = "18.197.98.165/32"
}
variable instance_type {
    default = "t2.micro"
}
variable region {
    default = "eu-central-1"
}

variable vpc_cidr_block {
    default     = "10.0.0.0/16"
}
variable subnet_cidr_block {
    default     = "10.0.28.0/24"
}
variable avail_zone {
    default     = "eu-central-1a"
}
