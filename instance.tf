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

resource "aws_instance" "jenkins-master"{
    provider = aws.region_master
    ami = data.aws_ssm_parameter.linux-ami.value
    key_name = aws_key_pair.master-keys.key_name
    subnet_id = aws_subnet.master-sn-1.id
    instance_type = var.instance-type
    associate_public_ip_address = true
    vpc_security_group_ids = [aws_security_group.jenkins-master-sg.id]
    tags = {
      Name = "Jenkins-master"
    }
    depends_on = [aws_main_route_table_association.master-default-RT-association]

    provisioner "local-exec" {
    command = <<EOF
aws --profile ${var.profile} ec2 wait instance-status-ok --region ${var.region_master} --instance-ids ${self.id}
ansible-playbook --extra-vars 'passed_in_hosts=tag_Name_${self.tags.Name}' ansible_templates/jenkins-master-sample.yml
EOF
  }
}

resource "aws_instance" "jenkins-worker"{
    provider = aws.region_worker
    count = var.worker_count
    ami = data.aws_ssm_parameter.linux-ami-oregon.value
    key_name = aws_key_pair.worker-keys.key_name
    subnet_id = aws_subnet.worker-sn-1.id
    instance_type = var.instance-type
    associate_public_ip_address = true
    vpc_security_group_ids = [aws_security_group.jenkins-worker-sg.id]
    tags = {
      Name = join("-",["jenkins-worker",count.index+1])
    }
    depends_on = [aws_main_route_table_association.worker-default-RT-association, aws_instance.jenkins-master]
    provisioner "local-exec" {
    command = <<EOF
aws --profile ${var.profile} ec2 wait instance-status-ok --region ${var.region_worker} --instance-ids ${self.id}
ansible-playbook --extra-vars 'passed_in_hosts=tag_Name_${self.tags.Name}' ansible_templates/jenkins-worker-sample.yml
EOF
}
}