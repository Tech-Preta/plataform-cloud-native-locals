# variables.tf para o management_cluster

variable "cluster_name" {
  description = "Nome do cluster k3d de gerenciamento."
  type        = string
  default     = "management-k3s" # Nome alterado para refletir k3s via k3d
}

variable "k3s_version" {
  description = "Tag da imagem k3s para o cluster de gerenciamento (ex: 'v1.28.5+k3s1')."
  type        = string
  default     = "v1.28.5+k3s1"
}

variable "k3d_servers" {
  description = "Número de nós de servidor para o cluster de gerenciamento k3d."
  type        = number
  default     = 1
}

variable "k3d_agents" {
  description = "Número de nós de agente para o cluster de gerenciamento k3d."
  type        = number
  default     = 0 # Para um cluster de gerenciamento simples, 0 agentes pode ser suficiente.
                  # Pode aumentar para 1 ou 2 se quisermos simular um ambiente mais distribuído
                  # ou se o Backstage/ArgoCD/Crossplane precisarem de mais recursos.
}

variable "k3s_extra_args" {
  description = "Argumentos extras para os servidores k3s no cluster de gerenciamento."
  type        = list(string)
  default     = ["--no-deploy=traefik"] # Vamos instalar nosso próprio Ingress ou usar port-forward/NodePort inicialmente.
}

variable "k3d_api_host_ip" {
  description = "IP do host para expor a API do cluster de gerenciamento k3d."
  type        = string
  default     = "0.0.0.0" # Acessível de qualquer interface de rede do host.
                          # Use "127.0.0.1" para apenas localhost.
}

variable "k3d_api_host_port" {
  description = "Porta do host para expor a API do cluster de gerenciamento k3d. 0 para aleatório."
  type        = number
  default     = 6445 # Usar uma porta fixa > 1024 para evitar conflitos comuns e não exigir sudo no host.
                   # Se 0, o Terraform output indicará a porta alocada.
}

variable "k3d_port_mappings" {
  description = "Mapeamentos de porta adicionais para o cluster de gerenciamento k3d."
  type = list(object({
    host_ip        = optional(string, "0.0.0.0")
    host_port      = number
    container_port = number
    protocol       = optional(string, "tcp")
    node_filters   = optional(list(string), ["loadbalancer"])
  }))
  default = [
    # Exemplo: Se quisermos expor um NodePort para ArgoCD ou Backstage futuramente
    # { host_port = 30080, container_port = 30080, protocol = "tcp", node_filters = ["loadbalancer"] }, // Para ArgoCD UI
    # { host_port = 30007, container_port = 30007, protocol = "tcp", node_filters = ["loadbalancer"] }  // Para Backstage UI
    # Por enquanto, vamos manter vazio e usar `kubectl port-forward` ou configurar Ingress mais tarde.
  ]
}
