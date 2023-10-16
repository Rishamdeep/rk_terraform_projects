# create vpc
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Rg Vpc"
  }
}

# create public subnets
resource "aws_subnet" "pubsub1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Pubsub1"
  }
}
resource "aws_subnet" "pubsub2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "Pubsub2"
  }
}

# create private subnets
resource "aws_subnet" "privsub1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Privsub1"
  }
}
resource "aws_subnet" "privsub2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "Privsub2"
  }
}

# create ig
resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Ig"
  }
}

#create public route
resource "aws_route_table" "myRoute" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig.id
  }
  tags = {
    Name = "MyRoute"
  }
}

# associate public subnets to public route
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.pubsub1.id
  route_table_id = aws_route_table.myRoute.id
}
resource "aws_route_table_association" "a1" {
  subnet_id      = aws_subnet.pubsub2.id
  route_table_id = aws_route_table.myRoute.id
}

# create private route
resource "aws_route_table" "myRoutePrivate" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.myNat.id
  }
  tags = {
    Name = "MyRoutePrivate"
  }
}

# associate private subnets to private route
resource "aws_route_table_association" "a2" {
  subnet_id      = aws_subnet.privsub1.id
  route_table_id = aws_route_table.myRoutePrivate.id
}
resource "aws_route_table_association" "a3" {
  subnet_id      = aws_subnet.privsub2.id
  route_table_id = aws_route_table.myRoutePrivate.id
}

resource "aws_eip" "myEip" {
  domain = "vpc"
  depends_on  = [aws_internet_gateway.ig]
}

resource "aws_nat_gateway" "myNat" {
  allocation_id = aws_eip.myEip.id
  subnet_id = aws_subnet.pubsub1.id
  depends_on = [aws_internet_gateway.ig]
}
