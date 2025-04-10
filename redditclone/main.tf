# This is a sample Terraform script to create an EC2 instance with Jenkins and SonarQube installed on it.
# It also sets up a security group to allow inbound traffic on specific ports.
resource "aws_instance" "web" {
  ami                    = "ami-0f9de6e2d2f067fca"      #change ami id for different region
  instance_type          = "t2.large"
  key_name               = "mykey"              #change key name as per your setup
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.Jenkins-VM-SG.id]
  user_data = <<-EOF
    #!/bin/bash
    exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1
    set -euxo pipefail

    # Update and install required packages
    apt update -y
    apt install -y wget curl gnupg2 software-properties-common apt-transport-https lsb-release docker.io

    # Install Temurin JDK 17
    wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public | tee /etc/apt/keyrings/adoptium.asc
    echo "deb [signed-by=/etc/apt/keyrings/adoptium.asc] https://packages.adoptium.net/artifactory/deb $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/adoptium.list
    apt update -y
    apt install -y temurin-17-jdk
    java --version

    # Install Jenkins
    curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
    echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | tee /etc/apt/sources.list.d/jenkins.list > /dev/null
    apt update -y
    apt install -y jenkins
    systemctl enable jenkins
    systemctl start jenkins

    # Configure Docker permissions
    usermod -aG docker ubuntu
    usermod -aG docker jenkins
    chmod 777 /var/run/docker.sock

    # Run SonarQube container
    docker run -d --name sonar -p 9000:9000 sonarqube:lts-community

    # Install Trivy
    wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | tee /usr/share/keyrings/trivy.gpg > /dev/null
    echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/trivy.list
    apt update -y
    apt install -y trivy

    # Confirm success
    echo "Jenkins + SonarQube + Trivy installed!" > /home/ubuntu/installed.txt
  EOF

  tags = {
    Name = "Jenkins-SonarQube"
  }

  root_block_device {
    volume_size = 40
  }
}

resource "aws_security_group" "Jenkins-VM-SG" {
  name        = "Jenkins-VM-SG"
  description = "Allow TLS inbound traffic"
  vpc_id      = var.vpc_id

  ingress = [
    for port in [22, 80, 443, 8080, 9000, 3000] : {
      description      = "inbound rules"
      from_port        = port
      to_port          = port
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Jenkins-VM-SG"
  }
}

