# outputs.tf para o módulo k3s_cluster
# As saídas já foram definidas em main.tf.
# Este arquivo é um placeholder ou pode ser usado para adicionar descrições mais longas
# se necessário no futuro.

# Exemplo de como você poderia adicionar mais detalhes a um output aqui:
/*
output "kubeconfig_file_path" {
  description = "O caminho absoluto para o arquivo kubeconfig que foi copiado do cluster k3s para o seu ambiente local. Este arquivo é necessário para interagir com o cluster usando kubectl ou outros clientes Kubernetes. Lembre-se de que este kubeconfig tem privilégios de administrador."
  value       = "${path.cwd}/.kube/config"
  // sensitive   = true # Descomente se você considera o caminho em si como sensível
}

output "k3s_install_command" {
  description = "Exibe o comando de instalação do k3s que o Terraform tentaria executar. Pode ser útil para depuração ou para executar a instalação manualmente se o provisionador local falhar por algum motivo."
  value       = "curl -sfL ${var.k3s_install_script_url} | INSTALL_K3S_VERSION='${var.k3s_version}' INSTALL_K3S_NAME='${var.cluster_name}' INSTALL_K3S_EXEC='server ${var.k3s_extra_args}' sh -s -"
}
*/
