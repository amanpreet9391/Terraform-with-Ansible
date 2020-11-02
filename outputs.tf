output "Jenkins-Main-Node-Public-IP" {
  value = aws_instance.jenkins-master.public_ip
}

output "Jenkins-Worker-Public-IPs" {
  value = {
    for instance in aws_instance.jenkins-worker :
    instance.id => instance.public_ip
  }
}

output "ALB-dns-name" {
    value = aws_lb.application-lb.dns_name
}

output "url" {
  value = aws_route53_record.jenkins-record.fqdn
}
