# Root var file
variable "aws_region" {

  default = "ap-south-1"

}

variable "access_ip" {}

# database variables

variable "dbname" {
  type = string
}

variable "dbuser" {
  type      = string
  sensitive = true
}

variable "dbpassword" {
  type      = string
  sensitive = true
}