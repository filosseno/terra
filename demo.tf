variable "public_subnet_cidr" {
    type = list(string)
    default = [ "10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24" ]
    description = "CIDR value public subnets"
  
}

variable "private_subnet_cidr" {
    type = list(string)
    default = [ "10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24" ]
  
}

resource "aws_vpc" "vpc_test" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "vpc_test"

    }
  
}

resource "aws_subnet" "PUBLICSUBNET" {
    vpc_id = aws_vpc.vpc_test.id
    count = length(var.public_subnet_cidr)
    cidr_block = element(var.public_subnet_cidr, count.index)

    tags = {
       Name = "Public_Subnet_${count.index + 1}"
  }
}

resource "aws_subnet" "PRIVATESUBNET" {
    vpc_id = aws_vpc.vpc_test.id
    count = length(var.private_subnet_cidr)
    cidr_block = element(var.private_subnet_cidr, count.index)

    tags = {
       Name = "Private_Subnet${count.index + 1}"
  }
}

resource "aws_internet_gateway" "TESTGW" {
    vpc_id = aws_vpc.vpc_test.id

    tags = {
      Name = "TestGW"
    }
  
}

resource "aws_route_table" "TESTROUTE" {
    vpc_id = aws_vpc.vpc_test.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.TESTGW.id
    }

    tags = {
      Name = "TestRoute"
    }
}

resource "aws_route_table_association" "TESTASS" {
    count = length(var.public_subnet_cidr)
    subnet_id = element(aws_subnet.PUBLICSUBNET[*].id, count.index)
    route_table_id = aws_route_table.TESTROUTE.id
  
}

resource "aws_instance" "DemoEC2" {
    ami           = "ami-0e872aee57663ae2d"
    instance_type = "t2.micro"
    count         = length(var.public_subnet_cidr)
    subnet_id     = element(aws_subnet.PUBLICSUBNET[*].id, count.index)

    tags = {
     Name = "DemoEC2_${count.index + 1}"
  }
}

resource "aws_s3_bucket" "TESTS3" {
    bucket = "iurbfiubeuirbiwebyiwebf"

    tags = {
      Name = "testbucketsamdemo"
    }
  
}