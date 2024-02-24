resource "aws_instance" "sql_execution_instance" {
  ami           = "ami-0230bd60aa48260c6"
  instance_type = "t2.micro"
  #key_name      = "your-key-pair"
  subnet_id = element(module.vpc.private_subnets, 0)

  security_groups = [aws_security_group.ec2.id]

  # User data to execute the SQL script on instance launch
  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install awscli -y

              export AWS_ACCESS_KEY_ID=${var.AWS_ACCESS_KEY_ID}
              export AWS_SECRET_ACCESS_KEY=${var.AWS_SECRET_ACCESS_KEY}
              export AWS_SESSION_TOKEN=${var.AWS_SESSION_TOKEN}
              export AWS_DEFAULT_REGION="us-east-1"
              export AWS_DEFAULT_OUTPUT="json"
              
              sudo wget https://dev.mysql.com/get/mysql80-community-release-el9-1.noarch.rpm 
              sudo dnf install mysql80-community-release-el9-1.noarch.rpm -y
              sudo dnf install mysql-community-server -y
              sudo systemctl start mysqld

              # Copy .sql file from S3-bucket and put in RDS.
              echo '#!/bin/bash' > dump_script.sh
              echo 'databases=$(mysql -u ${var.db_username} -p${var.db_password} -h ${aws_db_instance.flask_db.address} -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema|performance_schema|mysql)")' >> dump_script.sh

              echo 'echo "List of databases:"' >> dump_script.sh
              echo 'echo "$databases"' >> dump_script.sh

              echo 'lms_exists=false' >> dump_script.sh
              echo 'while IFS= read -r db; do' >> dump_script.sh
              echo '    if [ "$db" == "flask" ]; then' >> dump_script.sh
              echo '        lms_exists=true' >> dump_script.sh
              echo '        break' >> dump_script.sh
              echo '    fi' >> dump_script.sh
              echo 'done <<< "$databases"' >> dump_script.sh

              echo 'if [ "$lms_exists" == true ]; then' >> dump_script.sh
              echo '    echo "The 'lms' database exists. Do nothing!!!"' >> dump_script.sh
              echo 'else' >> dump_script.sh
              echo '    echo "The 'lms' database does not exist."' >> dump_script.sh
              echo '    aws s3 cp s3://${aws_s3_bucket.my_s3_bucket.bucket}/lms.sql .' >> dump_script.sh
              echo '    echo head -n 5 lms.sql' >> dump_script.sh
              echo '    mysql -u ${var.db_username} -p${var.db_password} -h ${aws_db_instance.flask_db.address} < lms.sql' >> dump_script.sh
              echo 'fi' >> dump_script.sh

              # Execute the script
              chmod +x dump_script.sh
              ./dump_script.sh
              EOF

  tags = {
    Name = "SqlExecutionInstance"
  }

  depends_on = [aws_db_instance.flask_db]
}

variable "sql_script_path" {
  type    = string
  default = "./library-management-system/db/lms.sql" # Adjust the path as needed
}

resource "aws_security_group" "ec2" {
  name        = "EC2SecurityGroup"
  description = "Security group for the EC2 instance"

  vpc_id = module.vpc.vpc_id # Replace with your VPC ID

  # Egress rule for outgoing MySQL traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
