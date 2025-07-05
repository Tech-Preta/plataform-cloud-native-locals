output "cluster_name" {
  description = "Nome do cluster k3d criado."
  value       = k3d_cluster.this.name
}

output "kubeconfig_raw" {
  description = "Conteúdo bruto do kubeconfig para o cluster k3d."
  value       = data.k3d_kubeconfig.this.raw_config
  sensitive   = true
}

output "kubeconfig_file_saved_path" {
  description = "Caminho onde o kubeconfig foi salvo localmente, se kubeconfig_output_path foi fornecido."
  value       = var.kubeconfig_output_path != "" ? local_file.kubeconfig[0].filename : "Nenhum arquivo salvo pelo módulo (kubeconfig_output_path estava vazio)."
}

output "k3d_api_host_port_actual" {
  description = "Porta do host real onde a API do Kubernetes está exposta (útil se k3d_api_host_port foi 0)."
  # O provider k3d não expõe diretamente a porta alocada se foi 0.
  # O kubeconfig_raw conterá a porta correta.
  # Uma forma de extrair seria processar o kubeconfig_raw, mas isso é complexo no Terraform.
  # Por enquanto, instruiremos o usuário a verificar o kubeconfig ou usar `k3d cluster get <nome_cluster>`
  value       = "Verifique o kubeconfig gerado ou use 'k3d cluster get ${k3d_cluster.this.name}' para a porta exata se k3d_api_host_port foi 0."
}

output "k3d_servers_count" {
  description = "Número de servidores no cluster k3d."
  value       = k3d_cluster.this.servers
}

output "k3d_agents_count" {
  description = "Número de agentes no cluster k3d."
  value       = k3d_cluster.this.agents
}

output "k3d_network_name" {
  description = "Nome da rede Docker usada pelo cluster k3d."
  value       = k3d_cluster.this.network
}

# Adicionar mais outputs conforme necessário, por exemplo, IPs dos nós se o provider os expuser.
