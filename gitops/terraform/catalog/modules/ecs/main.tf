locals {
  cluster_name = "${var.name}-ecs-task-${random_string.random.result}"
  ecr_image    = "${var.ecr_repository_url}:${var.image_tag}"
}

resource "random_string" "random" {
  length  = 7
  special = false
}

module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "~> 7.0"

  cluster_name = local.cluster_name

  cluster_capacity_providers = ["FARGATE"]
  default_capacity_provider_strategy = {
    FARGATE = {
      weight = 1
      base   = 1
    }
  }

  services = {
    (var.name) = {
      cpu    = 1024
      memory = 4096

      autoscaling_policies = {
        predictive = {
          policy_type = "PredictiveScaling"
          predictive_scaling_policy_configuration = {
            mode = "ForecastOnly"
            metric_specification = [{
              target_value = 60
              predefined_metric_pair_specification = {
                predefined_metric_type = "ECSServiceCPUUtilization"
              }
            }]
          }
        }
      }

      container_definitions = {
        (var.name) = {
          cpu       = 512
          memory    = 1024
          essential = true
          image     = local.ecr_image

          healthCheck = {
            command = ["CMD-SHELL", "curl -f http://localhost:${var.container_port}/health || exit 1"]
          }

          secrets     = var.secrets
          environment = var.environment

          portMappings = [
            {
              name          = var.name
              containerPort = var.container_port
              hostPort      = var.container_port
              protocol      = "tcp"
            }
          ]

          readonlyRootFilesystem = false

          enable_cloudwatch_logging = true
          logConfiguration = {
            logDriver = "awslogs"
            options = {
              awslogs-group         = "/ecs/${local.cluster_name}"
              awslogs-stream-prefix = var.name
              awslogs-region        = var.region
            }
          }

          memoryReservation = 100

          restartPolicy = {
            enabled              = true
            ignoredExitCodes     = [1]
            restartAttemptPeriod = 60
          }
        }
      }

      load_balancer = {
        service = {
          target_group_arn = module.alb.target_groups["main"].arn
          container_name   = var.name
          container_port   = var.container_port
        }
      }

      tasks_iam_role_name                 = "${var.name}-tasks"
      tasks_iam_role_description          = "Example tasks IAM role for ${var.name}"
      tasks_iam_role_max_session_duration = 7200

      tasks_iam_role_policies = {
        ReadOnlyAccess = "arn:aws:iam::aws:policy/ReadOnlyAccess"
      }
      tasks_iam_role_statements = [
        {
          actions   = ["s3:List*"]
          resources = ["arn:aws:s3:::*"]
        }
      ]
      task_exec_iam_statements = [
        {
          actions = [
            "secretsmanager:GetSecretValue",
            "kms:Decrypt"
          ]
          resources = ["arn:aws:secretsmanager:eu-central-1:239861161554:secret:task/*"]
        }
      ]

      subnet_ids                    = var.private_subnets
      vpc_id                        = var.vpc_id
      availability_zone_rebalancing = "ENABLED"

      security_group_ingress_rules = {
        alb_svc_port = {
          from_port                    = var.container_port
          description                  = "Service port"
          referenced_security_group_id = module.alb.security_group_id
        }
      }
      security_group_egress_rules = {
        all = {
          cidr_ipv4   = "0.0.0.0/0"
          ip_protocol = "-1"
        }
      }
    }
  }

  tags       = var.tags
  depends_on = [aws_cloudwatch_log_group.ecs]
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 10.0"

  name               = var.name
  load_balancer_type = "application"
  vpc_id             = var.vpc_id
  subnets            = var.public_subnets

  enable_deletion_protection = false

  security_group_ingress_rules = {
    all_http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    }
    all_https = {
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  listeners = {
    http = {
      port        = 80
      protocol    = "HTTP"
      action_type = "redirect"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
    https = {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = aws_acm_certificate_validation.this.certificate_arn
      forward = {
        target_group_key = "main"
      }
    }
  }

  target_groups = {
    main = {
      backend_protocol                  = "HTTP"
      backend_port                      = var.container_port
      target_type                       = "ip"
      deregistration_delay              = 5
      load_balancing_cross_zone_enabled = true

      health_check = {
        enabled             = true
        healthy_threshold   = 5
        interval            = 30
        matcher             = "200"
        path                = "/health"
        port                = "traffic-port"
        protocol            = "HTTP"
        timeout             = 5
        unhealthy_threshold = 2
      }

      create_attachment = false
    }
  }

  tags = var.tags
}

resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${local.cluster_name}"
  retention_in_days = 14
}

resource "aws_acm_certificate" "this" {
  domain_name       = var.domain_name
  validation_method = "DNS"
  tags              = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "cloudflare_dns_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.this.domain_validation_options : dvo.domain_name => dvo
  }

  zone_id = "d4e68aa7a474446762b5879cddc5f3ba"
  name    = trimsuffix(each.value.resource_record_name, ".")
  type    = each.value.resource_record_type
  content = trimsuffix(each.value.resource_record_value, ".")
  ttl     = 60
}

resource "aws_acm_certificate_validation" "this" {
  certificate_arn         = aws_acm_certificate.this.arn
  validation_record_fqdns = [for r in cloudflare_dns_record.cert_validation : r.name]
}

resource "cloudflare_dns_record" "dns_record" {
  zone_id = var.cloudflare_zone_id
  name    = var.domain_name
  ttl     = 1
  type    = "CNAME"
  content = module.alb.dns_name
}
