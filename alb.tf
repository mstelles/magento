resource "aws_alb" "magentoalb" {
  load_balancer_type = "application"
  name               = "magentoalb"
  internal           = false
  security_groups    = ["${aws_security_group.elb_security_group.id}"]

  tags = {
    Name = "Magento ALB"
  }
  subnets = "${aws_subnet.public_subnets.*.id}"
  depends_on = ["aws_subnet.public_subnets",
  "aws_security_group.elb_security_group"]
}

resource "aws_alb_target_group" "magentoalb_http" {
  name     = "magentoalb-http"
  vpc_id   = "${aws_vpc.mainvpc.id}"
  port     = "80"
  protocol = "HTTP"
  health_check {
    path                = "/"
    port                = "80"
    protocol            = "HTTP"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    interval            = 5
    timeout             = 4
    matcher             = "200"
  }
  tags = {
    Name = "Magento ALB HTTP"
  }
  depends_on = ["aws_vpc.mainvpc"]
}

resource "aws_alb_target_group" "magentoalb_6081tcp" {
  name        = "magentoalb-http6081tcp"
  vpc_id      = "${aws_vpc.mainvpc.id}"
  port        = "6081"
  protocol    = "HTTP"
  target_type = "instance"
  health_check {
    path                = "/"
    port                = "6081"
    protocol            = "HTTP"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    interval            = 5
    timeout             = 4
    matcher             = "200-399"
  }
  tags = {
    Name = "Varnish ALB 6081/TCP"
  }
  depends_on = ["aws_vpc.mainvpc"]
}

resource "aws_alb_target_group_attachment" "http_targetgroup" {
  target_group_arn = "${aws_alb_target_group.magentoalb_http.arn}"
  #count            = "${length(var.public_subnet_cidr)}"
  port      = 80
  target_id = "${aws_instance.magento.id}"
}

resource "aws_alb_target_group_attachment" "tcp6081_targetgroup" {
  target_group_arn = "${aws_alb_target_group.magentoalb_6081tcp.arn}"
  #count            = "${length(var.public_subnet_cidr)}"
  port      = 6081
  target_id = "${aws_instance.varnish.id}"
}

resource "aws_alb_listener" "http_listener" {
  load_balancer_arn = "${aws_alb.magentoalb.arn}"
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = 443
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  depends_on = ["aws_alb.magentoalb",
    "aws_alb_target_group.magentoalb_http"
  ]
}

resource "aws_alb_listener" "https_listener" {
  load_balancer_arn = "${aws_alb.magentoalb.arn}"
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "arn:aws:iam::148765843611:server-certificate/magento-eu-north-1"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.magentoalb_6081tcp.arn}"
  }

  depends_on = ["aws_alb.magentoalb",
    "aws_alb_target_group.magentoalb_6081tcp"
  ]
}

resource "aws_alb_listener_rule" "static" {
  listener_arn = "${aws_alb_listener.https_listener.arn}"
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.magentoalb_http.arn}"
  }

  condition {
    path_pattern {
      values = ["/static/*", "/media/*"]
    }
  }
}

# resource "aws_alb_listener_rule" "redirect_http_to_https" {
#   listener_arn = "${aws_alb_listener.https_listener.arn}"
#
#   action {
#     type = "redirect"
#
#     redirect {
#       port        = "443"
#       protocol    = "HTTPS"
#       status_code = "HTTP_301"
#     }
#   }
#   condition {
#     http_header {
#       http_header_name = "host-header"
#       values           = ["https://#{host}:443/#{path}?#{query}"]
#     }
#   }
# }
