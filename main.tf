data "aws_ami" "service" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical

}

resource "aws_instance" "service" {

  ami                         = data.aws_ami.service.id
  vpc_security_group_ids      = ["${var.vpc_sg_id}"]
  subnet_id                   = var.vpc_public_subnets[0]
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.service.key_name
  associate_public_ip_address = true
  
  

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install gnupg",
      "wget -qO- https://www.mongodb.org/static/pgp/server-7.0.asc | sudo tee /etc/apt/trusted.gpg.d/server-7.0.asc",
      "echo 'deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/7.0 multiverse' | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list",
      "sudo apt-get update -y",
      "sudo apt-get install -y mongodb-mongosh",
      "mongosh --version"
    ]
  }

  connection {
    host        = self.public_ip
    type        = "ssh"
    user        = "ubuntu"
    private_key = tls_private_key.service.private_key_pem
  }
}

resource "tls_private_key" "service" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "service" {
  key_name   = "${var.application_name}-ec2.pem"
  public_key = tls_private_key.service.public_key_openssh
}

resource "local_file" "service_private_key" {
  content  = tls_private_key.service.private_key_pem
  filename = aws_key_pair.service.key_name

  provisioner "local-exec" {
    command = <<-EOT
      chmod 400 ${aws_key_pair.service.key_name}
      echo "ssh -i '${aws_key_pair.service.key_name}' ubuntu@${aws_instance.service.public_dns}" > connect-ec2.sh
      chmod +x connect-ec2.sh
    EOT
  }
}
