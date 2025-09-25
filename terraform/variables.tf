variable "pr_number" {
  description = "El numero del pull request para el ambiente efimero."
  type        = number
}

variable "vpc_id" {
  description = "ID de la VPC principal."
  type        = string
}

variable "public_subnets" {
  description = "Subredes publicas para el ALB."
  type        = list(string)
}

variable "private_subnets" {
  description = "Las subredes privadas para el servicio de ECS."
  type        = list(string)
}
variable "ecr_url" {
  description = "URL completa del repositorio ECR sin tag."
  type        = string
}