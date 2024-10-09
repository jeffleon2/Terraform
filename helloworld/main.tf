provider "aws" {
  region = "us-west-2"
}


data "aws_ami" "ubuntu" {
  // Obtiene la ami mas reciente
  most_recent = true

  // Filtra sobre el nombre de la ami con el valor especificado
  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  // Filtra para que sea unicamente de este owner
  owners = ["099720109477"]
}

// Nota: 
// - Revisar de donde se puede ver el valor de los filtros
// - Donde podemos obtener el ownership de las AMIs

resource "aws_instance" "helloword" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  tags = {
    Name = "HelloWorld"
  }
}