resource "aws_vpc" "main" {
    cidr_block = var.vpc_cidr
    enable_dns_support = true
    enable_dns_hostnames = true

    tags = merge(
        local.common_tags,
        tomap({"Name" = "${local.prefix}-vpc"})
    )
}

# Create 2 subnets
resource "aws_subnet" "public" {
    cidr_block = var.subnet_cidr_list[0]
    map_public_ip_on_launch = true
    vpc_id = aws_vpc.main.id
    availability_zone = "${data.aws_region.current.name}a"

    tags = merge(
        local.common_tags,
        tomap({ "Name" = "${local.prefix}-public"})
    )
}

resource "aws_subnet" "private" {
    cidr_block = var.subnet_cidr_list[1]
    vpc_id = aws_vpc.main.id
    availability_zone = "${data.aws_region.current.name}a"
    tags = merge(
        local.common_tags,
        tomap({"Name" = "${local.prefix}-private"})
    )
}

# Internet gateway
resource "aws_internet_gateway" "main" {
    vpc_id = aws_vpc.main.id
    tags = merge(
        local.common_tags,
        tomap({ "Name" = "${local.prefix}-public"})
    )
}

# ElasticIP
resource "aws_eip" "public" {
    tags = merge(
        local.common_tags,
        tomap({ "Name" = "${local.prefix}-public"})
    )
}

# NAT Gateway
resource "aws_nat_gateway" "public" {
    allocation_id = aws_eip.public.id
    subnet_id = aws_subnet.public.id

    tags = merge(
        local.common_tags,
        tomap({ "Name" = "${local.prefix}-public-a"})
    )
}

# Route table
resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id
    tags = merge(
        local.common_tags,
        tomap({ "Name" = "${local.prefix}-public"})
    )
}

resource "aws_route_table" "private" {
    vpc_id = aws_vpc.main.id

    tags = merge(
        local.common_tags,
        tomap({ "Name" = "${local.prefix}-private"})
    )
}

resource "aws_route" "private-internet_out" {
    route_table_id = aws_route_table.private.id
    nat_gateway_id = aws_nat_gateway.public.id
    destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route" "public_internet_access" {
    route_table_id = aws_route_table.public.id
    gateway_id = aws_internet_gateway.main.id
    destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "public" {
    subnet_id = aws_subnet.public.id
    route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
    subnet_id = aws_subnet.private.id
    route_table_id = aws_route_table.private.id
}

# Security group
resource "aws_security_group" "ssh" {
    description = "allow ssh to ec2"
    name = "${local.prefix}-ssh_access"
    vpc_id = aws_vpc.main.id

    ingress {
        protocol = "tcp"
        from_port = 22
        to_port = 22
        cidr_blocks = [var.vpc_cidr]
    }
    tags = local.common_tags
}