# variables.tf para o management_cluster

variable "cluster_name" {
  description = "Nome do cluster k3s de gerenciamento."
  type        = string
  default     = "management-cluster"
}

variable "k3s_version" {
  description = "Versão do k3s para o cluster de gerenciamento."
  type        = string
  default     = "v1.28.5+k3s1" # Recomenda-se usar uma versão específica e testada
}
