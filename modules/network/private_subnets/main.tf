resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = var.vpc_id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = element(var.azs, count.index)
  tags = {
    Name = "${var.name}-private-${count.index + 1}"
  }
}

resource "aws_eip" "nat" {
  count = 1
  domain   = "vpc"
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat[0].id
  subnet_id     = var.public_subnet_id_for_nat
  tags = {
    Name = "${var.name}-nat"
  }
}

resource "aws_route_table" "private" {
  vpc_id = var.vpc_id
  tags = {
    Name = "${var.name}-private-rt"
  }
}

resource "aws_route" "default" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this.id
}

resource "aws_route_table_association" "a" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
