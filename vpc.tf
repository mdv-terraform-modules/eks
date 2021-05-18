# VPC Resources

#======================== VPC =======================

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = merge(map(
    "Name", "main-VPC",
    "kubernetes.io/cluster/${var.cluster_name}", "for testing",
    ),
    var.common_tags
  )
}

#======================= Subnets =====================

resource "aws_subnet" "public" {
  count                   = var.num_subnets
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = cidrsubnet(var.vpc_cidr, var.newbits, var.netnum + count.index)
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.main.id

  tags = merge(map(
    "Name", "${var.cluster_name}-subnet-${count.index + 1}",
    "kubernetes.io/cluster/${var.cluster_name}", var.environment,
    ),
    var.common_tags
  )
}

#==================== Internet Gateway ===================

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.common_tags, { Name = "k8s-VPC-IGW" })
}

#=================== Route Tables =========================

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = var.common.any_cidr
    gateway_id = aws_internet_gateway.main.id
  }
  tags = var.common_tags
}

resource "aws_route_table_association" "public_rt" {
  count          = length(aws_subnet.public.*.id)
  subnet_id      = aws_subnet.public.*.id[count.index]
  route_table_id = aws_route_table.public.id
}
