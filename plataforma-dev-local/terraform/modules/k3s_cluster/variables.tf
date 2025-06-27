# variables.tf para o módulo k3s_cluster
# As variáveis já foram definidas em main.tf com seus defaults.
# Este arquivo é um placeholder ou pode ser usado para adicionar descrições mais longas
# ou validações se necessário no futuro.

# Exemplo de como você poderia adicionar mais detalhes a uma variável aqui:
/*
variable "cluster_name" {
  description = "O nome que será usado para o cluster k3s. Isso pode influenciar como o k3s nomeia seus recursos internos ou como ele é identificado."
  type        = string
  default     = "management-cluster"
}

variable "k3s_version" {
  description = "Especifica a versão exata do k3s a ser instalada. É importante fixar a versão para garantir a reprodutibilidade. Consulte o site oficial do k3s para as versões disponíveis."
  type        = string
  default     = "v1.28.5+k3s1"
}

variable "k3s_install_script_url" {
  description = "A URL de onde o script de instalação do k3s (get.k3s.io) será baixado. Mantenha o padrão a menos que você esteja usando um mirror ou uma fonte alternativa."
  type        = string
  default     = "https://get.k3s.io"
}

variable "k3s_extra_args" {
  description = "Permite passar argumentos adicionais para o comando de instalação do k3s. Útil para customizar a instalação, como desabilitar componentes padrão (ex: '--no-deploy traefik') ou configurar opções de rede."
  type        = string
  default     = "--no-deploy traefik --no-deploy servicelb"
}
*/
