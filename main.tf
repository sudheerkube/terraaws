# Root Main


module "network" {
  source           = "./network"
  vpc_cidr         = local.vpc_cidr
  access_ip        = var.access_ip
  security_groups  = local.security_groups
  private_sn_count = 2
  public_sn_count  = 2
  max_subnets      = 10
  db_subnet_group  = true
  public_cidrs     = [for i in range(2, 25, 2) : cidrsubnet("10.0.0.0/16", 8, i)]
  private_cidrs    = [for i in range(1, 25, 2) : cidrsubnet("10.0.0.0/16", 8, i)]
}

module "database" {
  source                 = "./database"
  db_storage             = 10
  db_engine_version      = "5.7.22"
  db_instance_class      = "db.t2.micro"
  db_name                = var.dbname
  db_user                = var.dbuser
  db_password            = var.dbpassword
  db_subnet_group_name   = module.network.db_subnet_group_name[0]
  vpc_security_group_ids = module.network.db_security_group
  db_identifier          = "auto-db"
  skip_final_snapshot    = true
}

module "loadbalancer" {
  source                 = "./loadbalancer"
  public_sg              = module.network.public_sg
  public_subnet          = module.network.public_subnet
  tg_port                = 80
  tg_protocol            = "HTTP"
  vpc_id                 = module.network.vpc_id
  lb_healthy_threshold   = 2
  lb_unhealthy_threshold = 2
  lb_timeout             = 3
  lb_interval            = 30
  listener_port          = 8000
  listener_protocol      = "HTTP"
}

module "compute" {
  source              = "./compute"
  public_sg           = module.network.public_sg
  public_subnets      = module.network.public_subnet
  instance_count      = 1
  instance_type       = "t3.micro"
  vol_size            = 10
  key_name            = "autokey"
  public_key_path     = "/home/ubuntu/.ssh/autokey.pub"
  user_data_path      = "${path.root}/userdata.tpl"
  dbname              = var.dbname
  dbuser              = var.dbuser
  dbpassword          = var.dbpassword
  db_endpoint         = module.database.db_endpoint
  lb_target_group_arn = module.loadbalancer.lb_target_group_arn
  tg_port             = 8000
  private_key_path = "/home/ubuntu/.ssh/autokey"
}
