
resource "aws_security_group" "postgresql" {
  name        = "${local.name_prefix}-postgresql-sg-${var.env}"
  description = "Security group for PostgreSQL database"
  vpc_id      = var.vpc_id

  ingress {
    description     = "PostgreSQL from eks security group"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = ["${var.eks_node_security_group_id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.name_prefix}-postgresql-sg-${var.env}"
  }
}
resource "aws_db_subnet_group" "postgresql" {
    name       = "${local.name_prefix}-postgresql-subnet-group"
    subnet_ids = var.private_rds_subnet_ids

    tags = {
        Name = "PostgreSQL subnet group for ${local.name_prefix}"
        Environment = var.env
    }
}

resource "aws_db_instance" "postgresql" {
    identifier          = "${local.name_prefix}-db"
    engine              = "postgres"
    engine_version      = "16.8"
    instance_class      = "db.t3.small"
    allocated_storage   = 20
    storage_type        = "gp3"
    
    username            = "dbadmin"
    manage_master_user_password = true
    multi_az            = false
    
    vpc_security_group_ids = [aws_security_group.postgresql.id]  # Replace with your security group
    db_subnet_group_name   = aws_db_subnet_group.postgresql.name       
    
    skip_final_snapshot    = true
    
    backup_retention_period = 7

    tags = {
        Name = "PostgreSQL Database"
        Environment = "${var.env}"
    }
}
