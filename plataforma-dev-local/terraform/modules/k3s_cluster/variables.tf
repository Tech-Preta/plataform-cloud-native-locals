variable "cluster_name" {
  description = "Nome do cluster k3d."
  type        = string
  default     = "k3s-default"
}

variable "k3s_version" {
  description = "Tag da imagem k3s a ser usada pelo k3d (ex: 'v1.28.5-k3s1'). Deixe em branco para usar o padrão do k3d."
  type        = string
  default     = "v1.28.5+k3s1"
}

variable "k3d_servers" {
  description = "Número de servidores (control-plane nodes) no cluster k3d."
  type        = number
  default     = 1
}

variable "k3d_agents" {
  description = "Número de agentes (worker nodes) no cluster k3d."
  type        = number
  default     = 0
}

variable "k3s_extra_args" {
  description = "Lista de argumentos extras para passar aos servidores k3s (ex: \"--no-deploy=traefik\")."
  type        = list(string)
  default     = ["--no-deploy=traefik"]
}

variable "k3d_extra_args" {
  description = "Lista de argumentos extras para o comando 'k3d cluster create' (ex: \"--timeout=300s\")."
  type        = list(string)
  default     = []
}

variable "k3d_network" {
  description = "Nome da rede Docker para o cluster k3d. Se não existir, será criada."
  type        = string
  default     = "k3d-plataforma-net"
}

variable "k3d_api_host_ip" {
  description = "IP do host para mapear a porta da API do Kubernetes. Use '0.0.0.0' para todas as interfaces."
  type        = string
  default     = "0.0.0.0"
}

variable "k3d_api_host_port" {
  description = "Porta do host para mapear a porta da API do Kubernetes (6443). Use 0 para uma porta aleatória."
  type        = number
  default     = 0 # Recomenda-se 0 para evitar conflitos, ou uma porta fixa como 6445 se souber que está livre.
                  # Se usar 0, o Terraform output mostrará a porta alocada.
}

variable "k3d_port_mappings" {
  description = "Lista de mapeamentos de porta adicionais. Node_filters especifica em quais nós do k3d a porta deve ser exposta (ex: 'server:*', 'agent:0', 'loadbalancer')."
  type = list(object({
    host_ip        = optional(string, "0.0.0.0")
    host_port      = number
    container_port = number
    protocol       = optional(string, "tcp")
    node_filters   = optional(list(string), ["loadbalancer"])
  }))
  default = [
    # Exemplo para expor HTTP e HTTPS se você instalar um Ingress
    # { host_port = 8080, container_port = 80, protocol = "tcp", node_filters = ["loadbalancer"] },
    # { host_port = 8443, container_port = 443, protocol = "tcp", node_filters = ["loadbalancer"] }
  ]
}

variable "k3d_env_vars" {
  description = "Variáveis de ambiente para passar aos nós do k3s. Formato: lista de strings 'KEY=VALUE@NODE_FILTER'."
  type        = list(string)
  default     = []
  # Exemplo: ["HTTP_PROXY=http://myproxy.com@server:*;agent:*"]
}

variable "k3d_volumes" {
  description = "Montagem de volumes nos nós do k3s. Formato: lista de strings 'HOST_PATH:CONTAINER_PATH@NODE_FILTER'."
  type        = list(string)
  default     = []
  # Exemplo: ["/meu/local/dados:/dados/no/container@server:0"]
}

variable "k3d_wait_for_server" {
  description = "Se o Terraform deve esperar o servidor k3s estar pronto."
  type        = bool
  default     = true
}

variable "k3d_timeout" {
  description = "Timeout para a criação do cluster k3d (ex: '300s')."
  type        = string
  default     = "360s"
}

variable "kubeconfig_output_path" {
  description = "Caminho onde o kubeconfig gerado pelo k3d será salvo. Se vazio, não será salvo em arquivo pelo módulo."
  type        = string
  default     = "" # Ex: "./.kube/k3d-config.yaml"
}

variable "kubeconfig_update_default" {
  description = "Se o k3d deve atualizar o kubeconfig padrão do usuário (~/.kube/config) ao criar o cluster. Recomenda-se 'false' para isolamento."
  type        = bool
  default     = false
}
