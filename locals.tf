# Main local

locals {
  vpc_cidr = "10.0.0.0/16"
}

locals {
  security_groups = {
    public = {
      name        = "public_sg"
      description = "SG for public"
      ingress = {
        ssh = {
          from        = 0
          to          = 0
          protocol    = -1
          cidr_blocks = ["0.0.0.0/0"]
        }
        http = {
          from        = 8000
          to          = 8000
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
        # nginx = {
        #   from        = 8000
        #   to          = 8000
        #   protocol    = "tcp"
        #   cidr_blocks = ["0.0.0.0/0"]
        # }
      }
    }
    rds = {
      name        = "rds_sg"
      description = "SG for rds"
      ingress = {
        ssh = {
          from        = 3306
          to          = 3306
          protocol    = "tcp"
          cidr_blocks = [local.vpc_cidr]

        }
      }
    }
  }
}

