provider "aws" {
  region = "us-west-2"
  default_tags {
    tags = {
      created-by  = "terraform"
      managed-by  = "terraform"
      workspace   = terraform.workspace
    }
  }
}

data "local_file" "ssh_pubkey" {
  filename = var.ssh_pubkey
}
resource "aws_key_pair" "ssh" {
  key_name   = "benchmarking"
  public_key = data.local_file.ssh_pubkey.content
}

resource "aws_security_group" "benchmarking" {
  name        = "benchmarking"
  description = "Benchmarking rules"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 8080
    to_port   = 8080
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

data "template_file" "user_data" {
  template = file("cloud-init.nix")

  vars = {
    deploy-key = "${data.local_file.ssh_pubkey.content}"
  }
}

resource "aws_instance" "benchmarked" {
  ami               = var.ami_id
  instance_type     = var.instance_type
  availability_zone = "us-west-2a"
  count             = 2

  key_name = aws_key_pair.ssh.key_name

  user_data = data.template_file.user_data.rendered

  vpc_security_group_ids = [
    aws_security_group.benchmarking.id
  ]

  root_block_device {
    volume_size = 10 # GiB
    tags = {
      Name = "benchmarked-rootvol"
    }
  }

  tags = {
    Name = "benchmarking"
  }
}

output "dns" {
  value = [
    aws_instance.benchmarked[*].private_dns,
    aws_instance.benchmarked[*].public_dns
  ]
}
