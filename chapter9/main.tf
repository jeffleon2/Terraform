provider "aws" {
  region = "us-west-2"
}

resource "tls_private_key" "key" {
    algorithm = "RSA"
}

# Crea un archivo ansible-key.pem con los permisos 0400 con el algoritmo RSA
resource "local_sensitive_file" "private_key" {
  filename = "${path.module}/ansible-key.pem"
  content = tls_private_key.key.private_key_pem
  file_permission = "0400"
}

resource "aws_key_pair" "key_pair" {
  key_name = "ansible_key"
  public_key = tls_private_key.key.public_key_openssh
}

data "aws_vpc" "default" {
    default = true
}

resource "aws_security_group" "allow_ssh" {
  vpc_id = data.aws_vpc.default.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_ami" "ubuntu" {
    most_recent = true
    filter {
      name = "name"
      values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
    }

    owners = ["099720109477"]
}

resource "aws_instance" "ansible_server" {
  ami = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  key_name = aws_key_pair.key_pair.key_name

  tags = {
    Name = "Ansible Server"
  }

  provisioner "remote-exec" {
    inline = [ 
        "sudo apt update -y",
        "sudo apt install -y software-properties-common",
        "sudo apt-add-repository --yes --update ppa:ansible/ansible",
        "sudo apt install -y ansible"
    ]

    connection {
      type = "ssh"
      user = "ubuntu"
      host = self.public_ip
      private_key = tls_private_key.key.private_key_pem
    }
  }    

  provisioner "local-exec" {
    environment = {
      ANSIBLE_SSH_ARGS = "-o StrictHostKeyChecking=no"
    }
   command = "ansible-playbook -u ubuntu --key-file ansible-key.pem -T 300 -i '${self.public_ip},', app.yml"
  }   

}


output "public_ip" {
  value = aws_instance.ansible_server.public_ip
}

output "ansible_command" {
  value = "ansible-playbook -u ubuntu --key-file ansible-key.pem -T 300 -i '${aws_instance.ansible_server.public_ip},', app.yml "
}

#WARNING: se debe tener ansible instalado en la maquina local