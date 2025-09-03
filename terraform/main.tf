resource "aws_vpc" "mtc_vpc" {
  cidr_block = var.cidr_block

  tags = {
    Name = "dev"
  }
}

resource "aws_subnet" "mtc_public_subnet" {
  vpc_id                  = aws_vpc.mtc_vpc.id
  cidr_block              = var.subnet_ip
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name = "dev-public"
  }
}

resource "aws_internet_gateway" "mtc_internet_gateway" {
  vpc_id = aws_vpc.mtc_vpc.id

  tags = {
    Name = "dev-igw"
  }
}

resource "aws_route_table" "mtc_public_rt" {
  vpc_id = aws_vpc.mtc_vpc.id

  tags = {
    Name = "dev_public_rt"
  }
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.mtc_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.mtc_internet_gateway.id
}

resource "aws_route_table_association" "mtc_public_assoc" {
  subnet_id      = aws_subnet.mtc_public_subnet.id
  route_table_id = aws_route_table.mtc_public_rt.id
}

resource "aws_security_group" "mtc_sg" {
  name        = "dev_sg"
  description = "dev security group"
  vpc_id      = aws_vpc.mtc_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "mtc_auth" {
  key_name   = "mtckey"
  public_key = file("~/.ssh/ansible.pub")
}

resource "aws_instance" "control_plane" {
  instance_type = "t2.medium"
  ami = lookup({
    "ubuntu" = data.aws_ami.ubuntu_ami.id,
    "debian" = data.aws_ami.debian_ami.id,
    "redhat" = data.aws_ami.redhat_ami.id
  }, var.distro, data.aws_ami.debian_ami.id)
  key_name               = aws_key_pair.mtc_auth.key_name
  vpc_security_group_ids = [aws_security_group.mtc_sg.id]
  subnet_id              = aws_subnet.mtc_public_subnet.id

  root_block_device {
    volume_size = 40
    encrypted   = true
  }

  tags = {
    Name = "control-plane"
    Role = "controller"
  }

  provisioner "local-exec" {
    command = templatefile("linux-ssh-config.tpl", {
      hostname     = self.public_ip
      private      = self.private_ip
      user         = lookup(var.user_map, var.distro, "admin")
      identityFile = "~/.ssh/ansible"
    })
    interpreter = ["bash", "-c"]
  }
}

resource "aws_instance" "workers" {
  count         = 2
  instance_type = var.ec2_type
  ami = lookup({
    "ubuntu" = data.aws_ami.ubuntu_ami.id,
    "debian" = data.aws_ami.debian_ami.id,
    "redhat" = data.aws_ami.redhat_ami.id
  }, var.distro, data.aws_ami.debian_ami.id)
  key_name               = aws_key_pair.mtc_auth.key_name
  vpc_security_group_ids = [aws_security_group.mtc_sg.id]
  subnet_id              = aws_subnet.mtc_public_subnet.id

  root_block_device {
    volume_size = 30
    encrypted   = true
  }

  tags = {
    Name = "worker-${count.index + 1}"
    Role = "worker"
  }

  provisioner "local-exec" {
    command = templatefile("linux-ssh-config.tpl", {
      hostname     = self.public_ip
      private      = self.private_ip
      user         = lookup(var.user_map, var.distro, "admin")
      identityFile = "~/.ssh/ansible"
    })
    interpreter = ["bash", "-c"]
  }
}

output "public_ip" {
  value = concat([aws_instance.control_plane.public_ip], aws_instance.workers[*].public_ip)
}

output "private_ip" {
  value = concat([aws_instance.control_plane.private_ip], aws_instance.workers[*].private_ip)
}

