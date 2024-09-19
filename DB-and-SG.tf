# Create a Security Group
resource "aws_security_group" "mysql_sg" {
  name        = "mysql-sg"
  description = "Security group for MySQL RDS instance"
  vpc_id      = aws_vpc.new-vpc.id

  # Inbound Rules
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    
  }

  # Outbound Rules
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "mysql-sg"
    Terraform = "True"
  }
}

# Create a DB Subnet Group
resource "aws_db_subnet_group" "mysql" {
  name       = "mysql-db-subnet-group"
  subnet_ids = [aws_subnet.private[0].id, aws_subnet.private[1].id]

  tags = {
    Name = "mysql-db-subnet-group"
    Terraform = "True"
  }
}

# Create an RDS Instance
resource "aws_db_instance" "mysql" {
  identifier              = "mydbinstance"
  allocated_storage       = 15
  # storage_type            = "gp2"
  engine                  = "mysql"
  engine_version          = "8.0.35"
  instance_class          = "db.t3.micro"
  username                = "admin"
  password                = "password123"
  db_name                 = "rdsmysql"
  publicly_accessible     = false
  vpc_security_group_ids  = [aws_security_group.mysql_sg.id]  # Attach security group
  multi_az                = false
  skip_final_snapshot     = true

  db_subnet_group_name    = aws_db_subnet_group.mysql.id
#   backup_retention_period = 7

  tags = {
    Name = "dbmysql"
    Terraform = "True"

  }
}



