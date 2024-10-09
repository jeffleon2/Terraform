resource "random_password" "password" {
  length = 16
  special = true
  override_special = "_%@/'\""
}

resource "aws_db_instance" "database" {
  allocated_storage = 10
  name = "pets"
  engine = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.micro"
  identifier = "${var.namespace}-db-instance"
  username = "admin"
  password = random_password.password.result
  db_subnet_group_name =  var.vpc.database_subnet_group
  vpc_security_group_ids = [var.sg.db]
  skip_final_snapshot = true
}