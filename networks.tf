resource "aws_vpc" "master_vpc"{
    provider = aws.region-master
    cidr_block = "10.0.0.0/16"
    enable_dns_support = true
    enable_dns_hostnames = true

    tags = {
        Name = "master-vpc-jenkins"
    }

}
resource "aws_vpc" "worker_vpc"{
    provider = aws.region-worker
    cidr_block = "192.168.0.0/16"
    enable_dns_support = true
    enable_dns_hostnames = true

    tags = {
        Name = "worker-vpc-jenkins"
    }

}

resource "aws_internet_gateway" "igw" {
    provider = aws.region-master
    vpc_id = aws_vpc.master_vpc.id
}

resource "aws_internet_gateway" "igw-oregon" {
    provider = aws.region-worker
    vpc_id = aws_vpc.worker_vpc.id
}

data "aws_availability_zones" "az"{
    provider = aws.region-master
    state = "available"
    #available availability zones
}

data "aws_availability_zones" "az-2"{
    provider = aws.region-worker
    state = "available"
    #available availability zones
}

#Subnet for master in us-east-1
resource "aws_subnet" "master-sn-1"{
    provider = aws.region-master
    cidr_block = "10.0.1.0/24"
    availability_zone = element(data.aws_availability_zones.az.names,0)
    vpc_id=aws_vpc.master_vpc.id
}

resource "aws_subnet" "master-sn-2"{
    provider = aws.region-master
    cidr_block = "10.0.2.0/24"
    availability_zone = element(data.aws_availability_zones.az.names,1)
    vpc_id=aws_vpc.master_vpc.id
}

#Subnet for worker in us-west-2
resource "aws_subnet" "worker-sn-1"{
    provider = aws.region-worker
    cidr_block = "192.168.1.0/24"
    availability_zone = element(data.aws_availability_zones.az-2.names,0)
    vpc_id=aws_vpc.worker_vpc.id
}