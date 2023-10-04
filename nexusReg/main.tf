provider "aws" {
    region      = "eu-west-1"
    access_key  = var.aws_access_key
    secret_key  = var.aws_secret_key
}

resource "aws_key_pair" "nexus_inst" {
  key_name   = "registryKey"
  public_key = "${file("/home/zzz/.ssh/id_rsa.pub")}"
}

resource "aws_instance" "nexus_inst" {
  ami                         = "ami-0f3164307ee5d695a"
  instance_type               = "t2.medium"
  key_name                    = "${aws_key_pair.nexus_inst.id}"
  associate_public_ip_address = true
  subnet_id                   = "subnet-0099195c2990200a1"
  vpc_security_group_ids      = [ "sg-0ad140d1502abbb59" ]
  user_data                   = "${file("setup.sh")}"
  tags = {
    Name                      = "nexusReg_inst"
  }
}

