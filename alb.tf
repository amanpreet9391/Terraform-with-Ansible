resource "aws_lb" "application-lb"{
    provider = aws.region_master
    name = "jenkins-ALB"
    internal = false
    load_balancer_type = "application"
    security_groups = [aws_security_group.alb-sg.id]
    subnets = [aws_subnet.master-sn-1.id,aws_subnet.master-sn-2.id]
    tags = {
      Name = "Jenkins-ALB"
    }
}

resource "aws_lb_target_group" "app-TG" {
    provider = aws.region_master
    name = "app-TG"
    port = var.webserver-port
    target_type = "instance"
    vpc_id = aws_vpc.master_vpc.id
    protocol = "HTTP"
    health_check {
      enabled = true
      interval = 10
      port = var.webserver-port
      path = "/"
      protocol = "HTTP"
      matcher = "200-299"
    }
    tags = {
      Name = "Application-TG"
    }
  
}

resource "aws_lb_listener" "jenkin-lb-listener-http" {
    provider = aws.region_master
    load_balancer_arn = aws_lb.application-lb.arn
    port = "80"
    protocol = "HTTP"
    default_action {
      type = "redirect"
      redirect {
        port =  "443"
        protocol = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  
}

resource "aws_lb_listener" "jenkin-lb-listener-https" {
  provider          = aws.region_master
  load_balancer_arn = aws_lb.application-lb.arn
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate.aws-ssl-cert.arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app-TG.arn
  }
}

resource "aws_lb_target_group_attachment" "jenkins-master-attach" {
    provider = aws.region_master
    target_group_arn = aws_lb_target_group.app-TG.arn
    target_id = aws_instance.jenkins-master.id
    port = var.webserver-port
  
}

