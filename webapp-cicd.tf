provider "aws" {
  profile = var.profile
  region  = var.region
}

data "aws_iam_user" "ghactions" {
  user_name = "ghactions-app"
}

resource "aws_iam_policy" "CodeDeploy-EC2-S3" {
  name = "CodeDeploy-EC2-S3"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "s3:Get*",
                "s3:List*"
            ],
            "Effect": "Allow",
            "Resource": [
            "arn:aws:s3:::${var.CODE_DEPLOY_S3_BUCKET_NAME}",
            "arn:aws:s3:::${var.CODE_DEPLOY_S3_BUCKET_NAME}/*"]
            
        }
    ]
}
EOF
}

resource "aws_iam_user_policy" "GH-Upload-To-S3" {
  name = "GH-Upload-To-S3"
  user = data.aws_iam_user.ghactions.user_name

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
              "s3:PutObject",
              "s3:Get*",
              "s3:List*"
            ],
            "Resource": [
            "arn:aws:s3:::${var.CODE_DEPLOY_S3_BUCKET_NAME}",
                "arn:aws:s3:::${var.CODE_DEPLOY_S3_BUCKET_NAME}/*"
            ]
        }
    ]
}
EOF
}

data "aws_caller_identity" "current" {}

resource "aws_iam_user_policy" "GH-Code-Deploy" {
  name = "GH-Code-Deploy"
  user = data.aws_iam_user.ghactions.user_name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "codedeploy:RegisterApplicationRevision",
        "codedeploy:GetApplicationRevision"
      ],
      "Resource": [
        "arn:aws:codedeploy:${var.region}:${data.aws_caller_identity.current.account_id}:application:${var.CODE_DEPLOY_APPLICATION_NAME}"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "codedeploy:CreateDeployment",
        "codedeploy:GetDeployment"
      ],
      "Resource": [
        "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "codedeploy:GetDeploymentConfig"
      ],
      "Resource": [
        "arn:aws:codedeploy:${var.region}:${data.aws_caller_identity.current.account_id}:deploymentconfig:CodeDeployDefault.OneAtATime",
        "arn:aws:codedeploy:${var.region}:${data.aws_caller_identity.current.account_id}:deploymentconfig:CodeDeployDefault.HalfAtATime",
        "arn:aws:codedeploy:${var.region}:${data.aws_caller_identity.current.account_id}:deploymentconfig:CodeDeployDefault.AllAtOnce"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role" "CodeDeployEC2ServiceRole" {
  name               = "CodeDeployEC2ServiceRole"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
  tags = {
    name = "CodeDeployEC2ServiceRole"
  }
}

resource "aws_iam_role" "CodeDeployServiceRole" {
  name               = "CodeDeployServiceRole"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "codedeploy.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
  tags = {
    Name = "CodeDeployServiceRole"
  }
}

data "aws_iam_role" "s3_bucket_access" {
  name = "EC2-CSYE6225"
}

resource "aws_iam_role_policy_attachment" "Attach_CodeDeploy-EC2-S3" {
  role       = data.aws_iam_role.s3_bucket_access.name
  policy_arn = aws_iam_policy.CodeDeploy-EC2-S3.arn
}

resource "aws_iam_role_policy_attachment" "CodeDeployEC2ServiceRole_Attach_CodeDeploy-EC2-S3" {
  role       = aws_iam_role.CodeDeployEC2ServiceRole.name
  policy_arn = aws_iam_policy.CodeDeploy-EC2-S3.arn
}

resource "aws_iam_role_policy_attachment" "CodeDeployServiceRole-attach-AWSCodeDeployRole" {
  role       = aws_iam_role.CodeDeployServiceRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}

data "aws_autoscaling_group" "asg" {
  name = "asg"
}

data "aws_lb" "load_balancer" {
  name = "Application-Load-Balancer"
}

resource "aws_codedeploy_app" "codeDeployApp" {
  name             = var.CODE_DEPLOY_APPLICATION_NAME
  compute_platform = "Server"
}

resource "aws_codedeploy_deployment_group" "cd_group" {
  depends_on             = [aws_codedeploy_app.codeDeployApp]
  app_name               = aws_codedeploy_app.codeDeployApp.name
  deployment_group_name  = var.CODE_DEPLOYMENT_GROUP_NAME
  service_role_arn       = aws_iam_role.CodeDeployServiceRole.arn
  deployment_config_name = "CodeDeployDefault.AllAtOnce"
  autoscaling_groups     = [data.aws_autoscaling_group.asg.name]
  deployment_style {
    deployment_type = "IN_PLACE"
  }
  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }
  ec2_tag_set {
    ec2_tag_filter {
      key   = "Name"
      type  = "KEY_AND_VALUE"
      value = "webappv1"
    }
  }
}

data "aws_route53_zone" "current_zone" {
  name = var.dns_zone_name
}
// data "aws_instance" "ec2_instance" {
//   filter {
//     name   = "tag:Name"
//     values = [var.ec2_instance_tag]
//   }
// }
resource "aws_route53_record" "webapp_A_record" {
  zone_id = data.aws_route53_zone.current_zone.zone_id
  name    = var.A_record_name
  type    = "A"
  alias {
    name                   = data.aws_lb.load_balancer.dns_name
    zone_id                = data.aws_lb.load_balancer.zone_id
    evaluate_target_health = true
  }
  // ttl     = "60"
  // records = [data.aws_instance.ec2_instance.public_ip]
}
