resource "aws_security_group" "alb-sg"{
    provider = aws.region_master
    name = "alb-sg"
    description = "Security group for Application Load balancer"
    vpc_id = aws_vpc.master_vpc.id
    ingress  {
        description = "Allow port 80 from anywhere"
        to_port = 80
        from_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        description = "Allow port 443 from anywhere"
        to_port = 443
        from_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]

    }
    # all ports, all protocols in the outbound rule
    egress {
        to_port = 0
        from_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
}


resource "aws_security_group" "jenkins-master-sg"{
    provider = aws.region_master
    name = "jenkins-master-sg"
    description = "Security group for Jenkins Master"
    vpc_id = aws_vpc.master_vpc.id
    ingress  {
        description = "Allow port 22 from our external ip"
        to_port = 22
        from_port = 22
        protocol = "tcp"
        cidr_blocks = [var.external_ip]
    }
    ingress {
        description = "Allow port 8080 from ALB"
        to_port = 8080
        from_port = 8080
        protocol = "tcp"
        security_groups = [aws_security_group.alb-sg.id]

    }
    ingress {
        description = "Allow traffic from us-west-2"
        to_port = 0
        from_port = 0
        protocol = "-1"
        cidr_blocks = ["192.168.1.0/24"]

    }
    # all ports, all protocols in the outbound rule
    egress {
        to_port = 0
        from_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
}

#Security group for jenkins worker. It won't recieve traffic from ALB. It will just communicate with the Jenkins master in us-east-1 region.
resource "aws_security_group" "jenkins-worker-sg"{
    provider = aws.region_worker
    name = "jenkins-worker-sg"
    description = "Security group for Jenkins worker"
    vpc_id = aws_vpc.worker_vpc.id
    ingress  {
        description = "Allow from Jenkins master"
        to_port = 0
        from_port = 0
        protocol = "-1"
        cidr_blocks = ["10.0.1.0/24"]
    }
    ingress {
        description = "Allow port 22 from public ip"
        to_port = 22
        from_port = 22
        protocol = "tcp"
        cidr_blocks = [var.external_ip]

    }
    # all ports, all protocols in the outbound rule
    egress {
        to_port = 0
        from_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
}