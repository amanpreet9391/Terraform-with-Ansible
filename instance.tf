#To avoid hardcoding the ami in the script. 
# For Jenkins-master
data "aws_ssm_parameter" "linux-ami"{
    provider = aws.region_master
    name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

# For Jenkins-worker
#AMI ID will be fetched for the region - us-west-2
data "aws_ssm_parameter" "linux-ami-oregon"{
    provider = aws.region_worker
    name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

resource "aws_key_pair" "master-keys"{
    provider = aws.region_master
    key_name = "jenkins"
    public_key = file("~/.ssh/terraform_key.pub")
}

resource "aws_key_pair" "worker-keys"{
    provider = aws.region_worker
    key_name = "jenkins"
    public_key = file("~/.ssh/terraform_key.pub")
}