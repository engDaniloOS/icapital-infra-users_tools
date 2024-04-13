##Criação dos security groups
resource "aws_security_group" "cluster_security_group" {
  name        = "cluster_security_group_icapital"
  description = "Security group for the cluster"
  vpc_id      = "vpc-069ead2516e1976ce" 
}

resource "aws_security_group" "lb_security_group" {
  name        = "lb_security_group_icapital"
  description = "Security group for the load balancer"
  vpc_id      = "vpc-069ead2516e1976ce" 
}

##Config do SG do cluster
resource "aws_security_group_rule" "cluster_http_ingress" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  security_group_id = aws_security_group.cluster_security_group.id
  source_security_group_id = aws_security_group.lb_security_group.id
}

resource "aws_security_group_rule" "cluster_http_egress" {
  type              = "egress"
  from_port         = 443
  to_port           = 8080
  protocol          = "tcp"
  security_group_id = aws_security_group.cluster_security_group.id
  cidr_blocks       = ["0.0.0.0/0"] 
}

##Config do SG do load balancer
resource "aws_security_group_rule" "lb_http_ingress" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.lb_security_group.id
  cidr_blocks       = ["0.0.0.0/0"]  
}

resource "aws_security_group_rule" "lb_http_egress" {
  type              = "egress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  security_group_id = aws_security_group.lb_security_group.id
  source_security_group_id = aws_security_group.cluster_security_group.id
}

resource "aws_security_group_rule" "lb_http_egress_https" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.lb_security_group.id
  cidr_blocks       = ["0.0.0.0/0"]
}