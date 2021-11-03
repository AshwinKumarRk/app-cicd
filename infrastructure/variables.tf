variable "profile" {
    default = "dev"
}

variable "region" {
    default = "us-east-1"
}

variable "EC2_INSTANCE_NAME" {}
variable "CODE_DEPLOY_APPLICATION_NAME" {}
variable "CODE_DEPLOYMENT_GROUP_NAME" {}
variable "CODE_DEPLOY_S3_BUCKET_NAME" {}