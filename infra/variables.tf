variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-2"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "aimapp"
}

variable "domain_name" {
  description = "Your domain name"
  type        = string
}

variable "subdomain" {
  description = "Subdomain for the application"
  type        = string
  default     = "tm"
}

variable "container_port" {
  description = "Port the container listens on"
  type        = number
  default     = 80
}

variable "container_cpu" {
  description = "CPU units for the container (256, 512, 1024, 2048, 4096)"
  type        = number
  default     = 256
}

variable "container_memory" {
  description = "Memory for the container in MB (512, 1024, 2048, etc.)"
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Desired number of ECS tasks"
  type        = number
  default     = 1
}

variable "github_repo" {
  description = "GitHub repository in format 'owner/repo-name' (e.g., 'username/repo') for OIDC setup"
  type        = string
  default     = ""
}

variable "image_tag" {
  description = "Docker image tag to use for ECS task definition (defaults to 'latest')"
  type        = string
  default     = "latest"
}