resource "aws_instance" "proxy_1" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public_az1.id
  key_name                    = aws_key_pair.generated_key.key_name

  vpc_security_group_ids      = [aws_security_group.sg_proxy.id]
  associate_public_ip_address = true

  user_data              = <<-EOF
            #!/bin/bash
            apt update -y
            apt install nginx -y
            systemctl start nginx
            cat > /etc/nginx/sites-available/default << EOL
            server {
                listen 80;
                location / {
                    proxy_pass http://${aws_lb.internal_alb.dns_name}:80;
                    proxy_set_header Host \$host;
                    proxy_set_header X-Real-IP \$remote_addr;
                    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
                    proxy_set_header X-Forwarded-Proto \$scheme;
                }
            }
            EOL
            systemctl restart nginx
            EOF

  tags = {
    Name = "proxy-1"
  }
}

resource "aws_instance" "proxy_2" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public_az2.id
  key_name                    = aws_key_pair.generated_key.key_name
  vpc_security_group_ids      = [aws_security_group.sg_proxy.id]
  associate_public_ip_address = true

  user_data              = <<-EOF
            #!/bin/bash
            apt update -y
            apt install nginx -y
            systemctl start nginx
            cat > /etc/nginx/sites-available/default << EOL
            server {
                listen 80;
                location / {
                    proxy_pass http://${aws_lb.internal_alb.dns_name}:80;
                    proxy_set_header Host \$host;
                    proxy_set_header X-Real-IP \$remote_addr;
                    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
                    proxy_set_header X-Forwarded-Proto \$scheme;
                }
            }
            EOL
            systemctl restart nginx
            EOF

  tags = {
    Name = "proxy-2"
  }
}



resource "aws_instance" "backend_1" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private_az1.id
  key_name               = aws_key_pair.generated_key.key_name
  vpc_security_group_ids = [aws_security_group.sg_backend.id]

  user_data              = <<-EOF
              #!/bin/bash
              sleep 30
              apt-get update -y
              apt-get install -y apache2
              mkdir -p /var/www/html/
              echo "I am Backend 1 (AZ1)" > /var/www/html/index.html
              systemctl start apache2
              systemctl enable apache2
              EOF

 depends_on = [ aws_nat_gateway.NatGW ]
  tags = {
    Name = "backend-1"
  }
}

resource "aws_instance" "backend_2" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private_az2.id
  key_name               = aws_key_pair.generated_key.key_name
  vpc_security_group_ids = [aws_security_group.sg_backend.id]

 user_data = <<-EOF
              #!/bin/bash
              sleep 30
              apt-get update -y
              apt-get install -y apache2
              mkdir -p /var/www/html/
              echo "I am Backend 2 (AZ2)" > /var/www/html/index.html
              systemctl start apache2
              systemctl enable apache2
              EOF

  depends_on = [ aws_nat_gateway.NatGW ]
  tags = {
    Name = "backend-2"
  }
}
