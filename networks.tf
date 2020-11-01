resource "aws_vpc" "master_vpc"{
    provider = aws.region_master
    cidr_block = "10.0.0.0/16"
    enable_dns_support = true
    enable_dns_hostnames = true

    tags = {
        Name = "master-vpc-jenkins"
    }

}
resource "aws_vpc" "worker_vpc"{
    provider = aws.region_worker
    cidr_block = "192.168.0.0/16"
    enable_dns_support = true
    enable_dns_hostnames = true

    tags = {
        Name = "worker-vpc-jenkins"
    }

}

resource "aws_internet_gateway" "igw" {
    provider = aws.region_master
    vpc_id = aws_vpc.master_vpc.id
}

resource "aws_internet_gateway" "igw-oregon" {
    provider = aws.region_worker
    vpc_id = aws_vpc.worker_vpc.id
}

data "aws_availability_zones" "az"{
    provider = aws.region_master
    state = "available"
    #available availability zones
}

data "aws_availability_zones" "az-2"{
    provider = aws.region_worker
    state = "available"
    #available availability zones
}

#Subnet for master in us-east-1
resource "aws_subnet" "master-sn-1"{
    provider = aws.region_master
    cidr_block = "10.0.1.0/24"
    availability_zone = element(data.aws_availability_zones.az.names,0)
    vpc_id=aws_vpc.master_vpc.id
}

resource "aws_subnet" "master-sn-2"{
    provider = aws.region_master
    cidr_block = "10.0.2.0/24"
    availability_zone = element(data.aws_availability_zones.az.names,1)
    vpc_id=aws_vpc.master_vpc.id
}

#Subnet for worker in us-west-2
resource "aws_subnet" "worker-sn-1"{
    provider = aws.region_worker
    cidr_block = "192.168.1.0/24"
    availability_zone = element(data.aws_availability_zones.az-2.names,0)
    vpc_id=aws_vpc.worker_vpc.id
}

#Initiate VPC peering connection request will be from us-east-1 region master to us-west-2 region worker
resource "aws_vpc_peering_connection"  "vpc_peer_master_to_worker"{
    provider = aws.region_master
    #region = var.region_master
    vpc_id = aws_vpc.master_vpc.id
    peer_vpc_id = aws_vpc.worker_vpc.id
    peer_region = var.region_worker
}

#Accept the peering request in us-west-2 from us-east-1
resource "aws_vpc_peering_connection_accepter" "vpc_peer_accepter"{
    provider = aws.region_worker
    #region = var.region_worker
    vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peer_master_to_worker.id
    auto_accept = true
}

#route table for master vpc, which enables tarffic from worker vpc
resource "aws_route_table" "master-RT"{
    #region = var.region-master
    provider = aws.region_master
    vpc_id = aws_vpc.master_vpc.id
    route {
        cidr_block="0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
        }
    route {
        cidr_block="192.168.1.0/24"
        vpc_peering_connection_id=aws_vpc_peering_connection.vpc_peer_master_to_worker.id
    }

    lifecycle {
        ignore_changes = all
    }
    tags = {
        Name = "Master-Region-RT"
    }
}

# A default route table is being created and attached to VPC at the time of VPC creation
resource "aws_main_route_table_association" "master-default-RT-association"{
    provider = aws.region_master
    #region = var.region_master
    vpc_id = aws_vpc.master_vpc.id
    route_table_id = aws_route_table.master-RT.id

}

resource "aws_route_table" "worker-RT"{
    provider = aws.region_worker
    #region = var.region_worker
    vpc_id = aws_vpc.worker_vpc.id
    route {
        cidr_block="0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw-oregon.id
        }
    route {
        cidr_block="10.0.1.0/24"
        vpc_peering_connection_id=aws_vpc_peering_connection.vpc_peer_master_to_worker.id
    }

    lifecycle {
        ignore_changes = all
    }
    tags = {
        Name = "Worker-Region-RT"
    }
}

resource "aws_main_route_table_association" "worker-default-RT-association"{
    provider = aws.region_worker
    #region = var.region_worker
    vpc_id = aws_vpc.worker_vpc.id
    route_table_id = aws_route_table.worker-RT.id

}
