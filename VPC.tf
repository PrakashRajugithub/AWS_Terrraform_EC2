resource "aws_vpc" "new-vpc" {
  cidr_block           = "10.2.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = "true"

  tags = {
    Name      = "new-vpc"
    Terraform = "True"
  }
}

#Public Subnets

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.new-vpc.id
  count                   = length(data.aws_availability_zones.available.names)
  cidr_block              = element(var.pub_cidr, count.index)
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = "true"

  tags = {
    Name      = "Pub-subnet-${count.index + 1}"
    Terraform = "True"
  }
}

#Private Subnets

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.new-vpc.id
  count             = length(data.aws_availability_zones.available.names)
  cidr_block        = element(var.pvt_cidr, count.index)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
  # map_public_ip_on_launch = "true"

  tags = {
    Name      = "Pvt-subnet-${count.index + 1}"
    Terraform = "True"
  }
}

# Internet GW

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.new-vpc.id

  tags = {
    Name = "new-vpc-igw"
  }
  depends_on = [
    aws_vpc.new-vpc
  ]
}


#Route Table

resource "aws_route_table" "new_rt" {
  vpc_id = aws_vpc.new-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "new-route-table"
  }
}

# Subnet Association/Route table association
# Pub subnets association

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public[*].id)
  subnet_id      = element(aws_subnet.public[*].id, count.index)
  route_table_id = aws_route_table.new_rt.id
}




# Pvt subnet association

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private[*].id)
  subnet_id      = element(aws_subnet.private[*].id, count.index)
  route_table_id = aws_route_table.new_rt.id
}

