# outputs.tf para o management_cluster
# As saídas já foram definidas em main.tf.
# Este arquivo é um placeholder ou pode ser usado para adicionar descrições mais longas
# se necessário no futuro.

# Exemplo de como você poderia adicionar mais detalhes a um output aqui:
/*
output "management_cluster_kubeconfig_path" {
  description = "O caminho absoluto para o arquivo kubeconfig do cluster de GERENCIAMENTO k3s. Este arquivo é crucial para configurar kubectl, Backstage, ArgoCD e Crossplane para interagir com este cluster central."
  value       = module.management_k3s_cluster.kubeconfig_file_path
}

output "management_cluster_k3s_install_command" {
  description = "O comando de instalação do k3s específico para o cluster de gerenciamento. Útil para referência ou depuração."
  value       = module.management_k3s_cluster.k3s_install_command
}
*/
