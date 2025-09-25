variable "pr_number" {
  description = "El numero del pull request para el ambiente efimero."
  type        = number
}

variable "private_subnets" {
  description = "Las subredes privadas para el servicio de ECS."
  type        = list(string)
}