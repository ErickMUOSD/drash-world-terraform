
provider "aws" {
  # shared_config_files      = [".aws/confing"]
  # shared_credentials_files = [".aws/credentials"]
  profile                  = "erick-personal"
  region = "us-east-1"

}
module "vpc" {
  source   = "./modules/network/vpc"
  name     = "my-vpc"
  vpc_cidr = "10.0.0.0/16"
}


module "public_subnets" {
  source              = "./modules/network/public_subnets"
  name                = "public-subnet"
  vpc_id              = module.vpc.vpc_id
  igw_id              = module.vpc.igw_id
  public_subnet_cidrs = ["10.0.1.0/24", "10.0.3.0/24"]
  azs                 = ["us-east-1a", "us-east-1b"]
  depends_on = [module.vpc]
}


module "private_subnets" {
  source                  = "./modules/network/private_subnets"
  vpc_id                  = module.vpc.vpc_id
  private_subnet_cidrs    = ["10.0.2.0/24"]
  azs                     = ["us-east-1a", "us-east-1b"]
  public_subnet_id_for_nat = module.public_subnets.subnet_ids[0]
  name                    = "private-subnet"
  depends_on = [module.vpc]
}

module "ec2_sg" {
  source     = "./modules/ec2/sg"
  name       = "ec2-sg"
  description = "Allow SSH and HTTP"
  vpc_id     = module.vpc.vpc_id

  ingress_rules = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  tags = {
    Name = "ec2-sg"
  }
}

resource "aws_key_pair" "my_key_pair" {
  key_name   = "my-key-pair"

  public_key = file("~/.ssh/id_rsa.pub")
}
module "web_application"{
  source = "./modules/ec2/vm"
  ami_id = "ami-0a7d80731ae1b2435"
  instance_type = "t2.micro"
  key_name = aws_key_pair.my_key_pair.key_name
  sg_id = module.ec2_sg.security_group_id
  subnet_id = module.public_subnets.subnet_ids[0]
  depends_on = [module.ec2_sg]
  name = "Web APplication"
}
module "ec2_rds" {
  source     = "./modules/ec2/sg"
  name       = "ec2-sg"
  description = "Allow default pg port"
  vpc_id     = module.vpc.vpc_id

  ingress_rules = [
    {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Use a specific CIDR in production!
  }
  ]

  egress_rules = [
    {

    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ]

  tags = {
    Name = "ec2-sg"
  }
}

module "rds" {
  source = "./modules/rds"
  db_name = "drash-world"
  db_password = "drash_world"
  db_user = "erick-drash"
instance_class = "t3.micro"
  sg_rds = [  module.ec2_sg.security_group_id]
  subnet_ids = module.public_subnets.subnet_ids
}