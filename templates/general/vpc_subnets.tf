# Criação da VPC
resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"
}

# Criação da Subnet Pública
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.example.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
}

# Criação da Subnet Privada
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.example.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
}

# Associação de uma Internet Gateway (IGW) à VPC
resource "aws_internet_gateway" "example" {
  vpc_id = aws_vpc.example.id
}

# Rota padrão para a Internet Gateway
resource "aws_route" "internet_gateway" {
  route_table_id         = aws_vpc.example.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.example.id
}

# Associação da Subnet Pública à Tabela de Roteamento Padrão
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_vpc.example.main_route_table_id
}