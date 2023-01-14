# vpc
resource "aws_vpc" "prom_vpc" {
  cidr_block           = "10.123.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "dev"
  }
}

# subnet
resource "aws_subnet" "prom-public-subnet" {
  vpc_id                  = aws_vpc.prom_vpc.id
  cidr_block              = "10.123.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2a"
  tags = {
    Name = "dev-public"
  }
}

# internet gateway
resource "aws_internet_gateway" "prom-internet-gateway" {
  vpc_id = aws_vpc.prom_vpc.id
  tags = {
    Name = "prom-igw"
  }
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.prom-server.id
  allocation_id = aws_eip.example.id
}

resource "aws_eip" "example" {
  vpc = true
}

# route table
resource "aws_route_table" "prom-rt" {
  vpc_id = aws_vpc.prom_vpc.id

  tags = {
    Name = "prom-rt"
  }
}

# default route
resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.prom-rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.prom-internet-gateway.id
}


# route table association

resource "aws_route_table_association" "dev-rta" {
  subnet_id      = aws_subnet.prom-public-subnet.id
  route_table_id = aws_route_table.prom-rt.id
}

# key pair

resource "aws_key_pair" "prom-auth" {
  key_name   = "mtckey"
  public_key = file("~/.ssh/mtckey.pub")
}

# instance
resource "aws_instance" "prom-server" {
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.prom-auth.id
  vpc_security_group_ids = [aws_security_group.allow_public.id]
  subnet_id              = aws_subnet.prom-public-subnet.id

    ami = data.aws_ami.server_ami.id
    root_block_device {
      volume_size = 30
    }
    tags = {
      Name = "prom-server"
    }


    provisioner "file" {
    source      = "/mnt/c/Users/LogIT0000/terraform-spacelift/installation.sh"
    destination = "/home/ubuntu/installation.sh"
    }

    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ubuntu"
      private_key = file("~/.ssh/mtckey")
      timeout     = "4m"
    }

    
  

  # provisioner
  provisioner "local-exec" {
    command = templatefile("${var.host_os}-ssh-config.tpl", {
      hostname     = self.public_ip,
      user         = "ubuntu",
      identityfile = "~/.ssh/mtckey"
    })
    interpreter = var.host_os == "linux" ? ["bash", "-c"] : ["Powershell", "-command"]
  }



}