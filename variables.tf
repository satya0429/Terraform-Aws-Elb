variable "AWS_REGION" {    
    default = "us-east-2"
}

variable "ACCESS_KEY" {    
    default = "**********************"
}

variable "SECRET_KEY" {    
    default = "************************"
}

variable "AMI_Inst" {
  default = "ami-015323f53302adbb4"
}

#variable "KEY" {
#  default = "ror"
#}

variable "PATH_TO_PRIVATE_KEY" {
    default = "mykey"
}

variable "PATH_TO_PUBLIC_KEY" {
    default = "mykey.pub"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "EC2_USER" {
  default = "ubuntu"
}