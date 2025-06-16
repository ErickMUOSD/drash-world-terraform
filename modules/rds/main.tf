resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = "${var.subnet_ids}"

  tags = {
    Name = "RDS subnet group"
  }
}
resource "aws_db_instance" "rds" {
  identifier             = var.db_name
  engine                 = "postgres"
  engine_version         = "11"
  instance_class         = var.instance_class
  allocated_storage      = 20
  max_allocated_storage  = 100
  db_name                = var.db_name
  username               = var.db_user
  password               = var.db_password
  skip_final_snapshot    = true
  publicly_accessible    = true
  vpc_security_group_ids = var.sg_rds
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name

  tags = {
    Name = var.db_name
  }
}