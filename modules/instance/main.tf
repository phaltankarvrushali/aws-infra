#Rds configuration
#database security group
resource "aws_security_group" "database" {
  name        = "RDS Security Group"
  description = "Security group for RDS instance"
  vpc_id      = var.vpc_id
  ingress {
    protocol        = "tcp"
    from_port       = "3306"
    to_port         = "3306"
    security_groups = [aws_security_group.webapp_sg.id]
    description = "Allow webapp to connect to database"
  }

  tags = {
    "Name" = "database"
  }
}

#Rds subnet group
resource "aws_db_subnet_group" "db_subnet_group" {

  name        = "db_subnet_group"
  description = "RDS subnet group for database"
  subnet_ids = var.private_subnet_id
  tags = {
    Name = "db_subnet_group"
  }
}

#Rds parameter group
resource "aws_db_parameter_group" "db_parameter_group" {
  name        = "dbparametergroup"
  family      = "mysql8.0"
  description = "RDS parameter group for database"
  parameter {
    name  = "character_set_server"
    value = "utf8"
  }
}

#Rds instance
resource "aws_db_instance" "db_instance" {
  identifier                = "csye6225"
  engine                    = "mysql"
  engine_version            = "8.0.28"
  instance_class            = "db.t3.micro"
  db_name                   = var.database_name
  username                  = var.database_username
  password                  = var.database_password
  parameter_group_name      = aws_db_parameter_group.db_parameter_group.name
  vpc_security_group_ids    = [aws_security_group.database.id]
  allocated_storage         = 20
  storage_type              = "gp2"
  multi_az                  = false
  skip_final_snapshot       = true
  final_snapshot_identifier = "final-snapshot"
  publicly_accessible       = false
  db_subnet_group_name      = aws_db_subnet_group.db_subnet_group.name
  storage_encrypted = true
  kms_key_id        = aws_kms_key.encryption_key_rds.arn
  tags = {
    Name = "db_instance"
  }
}


#output database name
output "database_name" {
  value = aws_db_instance.db_instance.db_name
}
#output database username
output "database_username" {
  value = aws_db_instance.db_instance.username
}

#output database password
output "database_password" {
  value = aws_db_instance.db_instance.password
}

output "database_endpoint" {
  value = aws_db_instance.db_instance.endpoint
}


data "aws_route53_zone" "hosted_zone" {
  name         = "${var.profile}.${var.domain_root}"

}

resource "aws_route53_record" "route53_record" {
  zone_id = data.aws_route53_zone.hosted_zone.zone_id
  name    = "${var.profile}.${var.domain_root}"
  type    = "A"
  alias {
    name                   = aws_lb.application_loadbalancer.dns_name
    zone_id                = aws_lb.application_loadbalancer.zone_id
    evaluate_target_health = true

  }
}


resource "aws_security_group" "webapp_sg" {

    name = "Webapp Security Group"
    description = "Security group for webapp"
    vpc_id = var.vpc_id


    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        # cidr_blocks = ["0.0.0.0/0"]
        security_groups = [aws_security_group.loadbalancer_sg.id]
    
    }
    
    # ingress {
    #     from_port = 80
    #     to_port = 80
    #     protocol = "tcp"
    #     cidr_blocks = ["0.0.0.0/0"]
    # }

    # ingress {
    #     from_port = 443
    #     to_port = 443
    #     protocol = "tcp"
    #     cidr_blocks = ["0.0.0.0/0"]
    # }

    ingress {
        from_port = 8089
        to_port = 8089
        protocol = "tcp"
        # cidr_blocks = ["0.0.0.0/0"]
        security_groups = [aws_security_group.loadbalancer_sg.id]

    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "application"
    }

}
# resource "aws_instance" "ec2-instance" {

#     ami = var.ami_id
#     instance_type = "t2.micro"
#     key_name = var.key_pair
#     subnet_id = var.public_subnet_id[0]
#     vpc_security_group_ids = [aws_security_group.webapp_sg.id]
#     associate_public_ip_address = true
#     disable_api_termination = false
#     iam_instance_profile       = aws_iam_instance_profile.app_instance_profile.name

#     root_block_device {
#         volume_type = "gp2"
#         volume_size = 50
#         delete_on_termination = true
#     }

#   user_data = <<EOF

# #!/bin/bash
# mkdir /home/ec2-user/tomcat
# cd /home/ec2-user/tomcat || exit
# touch setenv.sh
# echo '#!/bin/sh' > setenv.sh
# echo 'export JAVA_OPTS="-Dspring.datasource.url=jdbc:mysql://${aws_db_instance.db_instance.endpoint}/${var.database_name}?createDatabaseIfNotExist=true -Dspring.datasource.username=${var.database_username} -Dspring.datasource.password=${var.database_password} -Daws.region=${var.region} -Ds3.bucketName=${var.bucket_name} -Dserver.port=${var.application_port} -Dlogging.level.io.swagger=DEBUG -Dlogging.path=/home/ec2-user"' >> setenv.sh
# sudo chown tomcat:tomcat setenv.sh
# sudo chmod +x setenv.sh
# cd ..
# sudo chmod 755 -R /home/ec2-user/tomcat
# sudo systemctl restart tomcat.service
# sudo systemctl restart webapp.service
# source /home/ec2-user/tomcat/setenv.sh


# sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/home/ec2-user/cloudwatch-config.json -s

# java $JAVA_OPTS -jar neu.cloud.assignment-1.0-SNAPSHOT.jar

#  EOF
#     tags = {
#         Name = "webapp"
#     }

# }

resource "aws_iam_policy_attachment" "cloudwatch_policy" {
  name       = "cloudwatch_policy"
  roles      = [var.ec2_iam_role]
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}


resource "aws_iam_instance_profile" "app_instance_profile" {
  name = "app_instance_profile"
  role = var.ec2_iam_role
}

output "app_security_group_id" {
  value = aws_security_group.webapp_sg.id
}

# Load balancer security group
resource "aws_security_group" "loadbalancer_sg" {
  name        = "loadbalancer-sg"
  description = "Security group for load balancer"
  vpc_id      = var.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "loadbalancer-sg"
  }
}

output "load_balancer_sg_id" {
  value = aws_security_group.loadbalancer_sg.id
}


# Load balancer
resource "aws_lb" "application_loadbalancer" {
  name               = "application-loadbalancer"
  load_balancer_type = "application"
  ip_address_type    = "ipv4"
  internal           = false
  subnets            = var.public_subnet_id
  security_groups    = [aws_security_group.loadbalancer_sg.id]

  tags = {
    "Name" = "application-loadbalancer"
  }
}

# Load balancer target group
resource "aws_lb_target_group" "loadbalancer_target_group" {
  name                 = "application-target-group"
  port                 = 8089
  protocol             = "HTTP"
  target_type          = "instance"
  vpc_id               = var.vpc_id
  deregistration_delay = 20

  health_check {
    path                = "/healthz"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 10
    healthy_threshold   = 3
    unhealthy_threshold = 5
  }
}


# // Load balancer listener
# resource "aws_lb_listener" "loadbalancer_listener" {
#   load_balancer_arn = aws_lb.application_loadbalancer.arn
#   port              = 80
#   protocol          = "HTTP"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.loadbalancer_target_group.arn
#   }
# }

# Autoscaling launch configuration
resource "aws_launch_template" "autoscaling_launch_configuration" {
  name                        = "autoscaling-launch-configuration"
  image_id                    = var.ami_id
  instance_type               = "t2.micro"
  key_name                    = var.key_pair
  
  iam_instance_profile{
    name = aws_iam_instance_profile.app_instance_profile.name
  }        
  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.webapp_sg.id]
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_type = "gp2"
      delete_on_termination = true
      volume_size              = 20
      encrypted         = true
      kms_key_id        = aws_kms_key.encryption_key_ebs.arn
      
    }
  }

  user_data = base64encode(
    <<EOF

#!/bin/bash
mkdir /home/ec2-user/tomcat
cd /home/ec2-user/tomcat || exit
touch setenv.sh
echo '#!/bin/sh' > setenv.sh
echo 'export JAVA_OPTS="-Dspring.datasource.url=jdbc:mysql://${aws_db_instance.db_instance.endpoint}/${var.database_name}?createDatabaseIfNotExist=true -Dspring.datasource.username=${var.database_username} -Dspring.datasource.password=${var.database_password} -Daws.region=${var.region} -Ds3.bucketName=${var.bucket_name} -Dserver.port=${var.application_port} -Dlogging.level.io.swagger=DEBUG -Dlogging.path=/home/ec2-user"' >> setenv.sh
sudo chown tomcat:tomcat setenv.sh
sudo chmod +x setenv.sh
cd ..
sudo chmod 755 -R /home/ec2-user/tomcat
sudo systemctl restart tomcat.service
sudo systemctl restart webapp.service
source /home/ec2-user/tomcat/setenv.sh
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/home/ec2-user/cloudwatch-config.json -s

java $JAVA_OPTS -jar neu.cloud.assignment-1.0-SNAPSHOT.jar

 EOF
 )

}

# Autoscaling group
resource "aws_autoscaling_group" "autoscaling_group" {
  name                 = "autoscaling-group"
  launch_template {
    id      = aws_launch_template.autoscaling_launch_configuration.id
    version = "$Latest"
  }

  vpc_zone_identifier  = var.public_subnet_id
  target_group_arns    = [aws_lb_target_group.loadbalancer_target_group.arn]
  default_cooldown     = 60
  desired_capacity     = 1
  min_size             = 1
  max_size             = 3
  health_check_type    = "ELB"
  health_check_grace_period = 300

  tag {
    key                 = "Name"
    value               = "csye6225-ec2"
    propagate_at_launch = true
  }
}

# Autoscaling scale up policy
resource "aws_autoscaling_policy" "autoscaling_scale_up_policy" {
  name                   = "autoscaling_scale_up_policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.autoscaling_group.name
}

# Autoscaling scale down policy
resource "aws_autoscaling_policy" "autoscaling_scale_down_policy" {
  name                   = "autoscaling_scale_down_policy"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.autoscaling_group.name
}

# cloudwatch metric for scaling up
resource "aws_cloudwatch_metric_alarm" "cpu_cloudwatch_alarm_high" {
  alarm_name          = "cpu-alarm-high"
  alarm_description   = "Scale up if CPU is > 30% for 1 minute"
  comparison_operator = "GreaterThanThreshold"
  threshold           = "30"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  alarm_actions       = [aws_autoscaling_policy.autoscaling_scale_up_policy.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.autoscaling_group.name
  }
}

# cloudwatch metric for scaling down
resource "aws_cloudwatch_metric_alarm" "cpu_cloudwatch_alarm_low" {
  alarm_name          = "cpu-alarm-low"
  alarm_description   = "Scale down if CPU is < 5% for 1 minute"
  comparison_operator = "LessThanThreshold"
  threshold           = "5"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  alarm_actions       = [aws_autoscaling_policy.autoscaling_scale_down_policy.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.autoscaling_group.name
  }
}

// Delete log group
resource "aws_cloudwatch_log_group" "log_group_name" {
  name = var.log_group_name
}


data "aws_acm_certificate" "ssl_certificate_https" {
  domain            = "${var.profile}.${var.domain_root}"
  types             = ["IMPORTED"]
  statuses          = ["ISSUED"]
}

//Load balancer listener
resource "aws_lb_listener" "loadbalancer_listener" {
  load_balancer_arn = aws_lb.application_loadbalancer.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = data.aws_acm_certificate.ssl_certificate_https.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.loadbalancer_target_group.arn

  }
}


resource "aws_kms_key" "encryption_key_rds" {
  description             = "KMS Key"
  deletion_window_in_days = 7
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "kms-key-for-rds"

    Statement = [
      {
        Sid       = "Enable IAM User Permissions"
        Effect    = "Allow"
        Principal = {
          AWS = [
            "${join("", ["arn:aws:iam::", "${data.aws_caller_identity.current.account_id}", ":root"])}",
            "${join("", ["arn:aws:iam::", "${data.aws_caller_identity.current.account_id}", ":role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"])}"
          ]
        }
        Action    = "kms:*"
        Resource  = "*"
      },
      {
        Sid       = "Allow access for Key Administrators"
        Effect    = "Allow"
        Principal = {
          AWS = [
            "${join("", ["arn:aws:iam::", "${data.aws_caller_identity.current.account_id}", ":role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"])}"
          ]
        }
        Action    = [
          "kms:Create*",
          "kms:Describe*",
          "kms:Enable*",
          "kms:List*",
          "kms:Put*",
          "kms:Update*",
          "kms:Revoke*",
          "kms:Disable*",
          "kms:Get*",
          "kms:Delete*",
          "kms:TagResource",
          "kms:UntagResource",
          "kms:ScheduleKeyDeletion",
          "kms:CancelKeyDeletion",
        ]
        Resource  = "*"
      },
      {
        Sid       = "Allow use of the key"
        Effect    = "Allow"
        Principal = {
          AWS = [
            "${join("", ["arn:aws:iam::", "${data.aws_caller_identity.current.account_id}", ":role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"])}"
          ]
        }
        Action    = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey",
        ]
        Resource  = "*"
      },
      {
        Sid       = "Allow attachment of persistent resources"
        Effect    = "Allow"
        Principal = {
          AWS = [
            "${join("", ["arn:aws:iam::", "${data.aws_caller_identity.current.account_id}", ":role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"])}"
          ]
        }
        Action    = [
          "kms:CreateGrant",
          "kms:ListGrants",
          "kms:RevokeGrant",
        ]
        Resource  = "*"
      },
    ]
  })
}

data "aws_caller_identity" "current" {}



resource "aws_kms_key" "encryption_key_ebs" {
  description             = "KMS Key"
  deletion_window_in_days = 7
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "kms-key-for-ebs"

    Statement = [
      {
        Sid       = "Enable IAM User Permissions"
        Effect    = "Allow"
        Principal = {
          AWS = [
            "${join("", ["arn:aws:iam::", "${data.aws_caller_identity.current.account_id}", ":root"])}",
            "${join("", ["arn:aws:iam::", "${data.aws_caller_identity.current.account_id}", ":role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"])}"
          ]
        }
        Action    = "kms:*"
        Resource  = "*"
      },
      {
        Sid       = "Allow access for Key Administrators"
        Effect    = "Allow"
        Principal = {
          AWS = [
            "${join("", ["arn:aws:iam::", "${data.aws_caller_identity.current.account_id}", ":role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"])}"
          ]
        }
        Action    = [
          "kms:Create*",
          "kms:Describe*",
          "kms:Enable*",
          "kms:List*",
          "kms:Put*",
          "kms:Update*",
          "kms:Revoke*",
          "kms:Disable*",
          "kms:Get*",
          "kms:Delete*",
          "kms:TagResource",
          "kms:UntagResource",
          "kms:ScheduleKeyDeletion",
          "kms:CancelKeyDeletion",
        ]
        Resource  = "*"
      },
      {
        Sid       = "Allow use of the key"
        Effect    = "Allow"
        Principal = {
          AWS = [
            "${join("", ["arn:aws:iam::", "${data.aws_caller_identity.current.account_id}", ":role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"])}"
          ]
        }
        Action    = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey",
        ]
        Resource  = "*"
      },
      {
        Sid       = "Allow attachment of persistent resources"
        Effect    = "Allow"
        Principal = {
          AWS = [
            "${join("", ["arn:aws:iam::", "${data.aws_caller_identity.current.account_id}", ":role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"])}"
          ]
        }
        Action    = [
          "kms:CreateGrant",
          "kms:ListGrants",
          "kms:RevokeGrant",
        ]
        Resource  = "*"
      },
    ]
  })
}

