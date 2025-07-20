# Internet Gateway para a VPC ter acesso à internet
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "igw-desafio-vw"
  }
}

# Tabela de Rota Pública: direciona todo tráfego (0.0.0.0/0) para o Internet Gateway
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "rt-public"
  }
}

# Associa a tabela de rota pública com as subnets públicas
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Elastic IP para o NAT Gateway (necessário para ele ter um IP fixo)
resource "aws_eip" "nat" {
  domain = "vpc"
}

# NAT Gateway: permite que recursos na subnet privada acessem a internet (ex: para updates)
# sem serem acessíveis externamente. Coloquei na primeira subnet pública.
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id
  depends_on    = [aws_internet_gateway.igw]

  tags = {
    Name = "nat-desafio-vw"
  }
}

# Tabela de Rota Privada: direciona todo tráfego para o NAT Gateway
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "rt-private"
  }
}

# Associa a tabela de rota privada com as subnets privadas
resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}