# main.tf para o management_cluster

terraform {
  required_version = ">= 1.0"

  required_providers {
    k3d = {
      source  = "pvotal/k3d"
      version = "~> 0.3.0" # Ou a versão especificada em ../providers.tf
    }
    local = { # Mantido para o recurso local_file dentro do módulo
      source  = "hashicorp/local"
      version = "~> 2.4.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20" # Ajuste conforme ../providers.tf
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.10" # Ajuste conforme ../providers.tf
    }
  }
}

module "management_k3s_cluster" {
  source = "../modules/k3s_cluster"

  cluster_name          = var.cluster_name
  k3s_version           = var.k3s_version # Tag da imagem k3s
  k3d_servers           = var.k3d_servers
  k3d_agents            = var.k3d_agents
  k3s_extra_args        = var.k3s_extra_args

  k3d_api_host_ip       = var.k3d_api_host_ip
  k3d_api_host_port     = var.k3d_api_host_port

  k3d_port_mappings     = var.k3d_port_mappings

  k3d_network           = "${var.cluster_name}-net" # Nome da rede baseado no nome do cluster
  kubeconfig_output_path = abspath("${path.module}/.kube/config") # Salva o kubeconfig relativo a este dir
  kubeconfig_update_default = false # Não atualiza o kubeconfig global

  # Outras variáveis do módulo k3d podem ser expostas aqui se necessário
  # k3d_extra_args      = []
  # k3d_env_vars        = []
  # k3d_volumes         = []
}

# Configuração dos providers Kubernetes e Helm
# Eles dependem do kubeconfig gerado pelo módulo do cluster k3d.

provider "kubernetes" {
  # Este provider será usado para interagir com o cluster k3d criado.
  # O alias não é estritamente necessário aqui se este for o único provider kubernetes,
  # mas é uma boa prática se você gerenciar múltiplos clusters com Terraform.
  # alias      = "management_k3s"
  kubeconfig = module.management_k3s_cluster.kubeconfig_raw
}

provider "helm" {
  # Este provider será usado para instalar charts Helm no cluster k3d.
  # alias = "management_k3s"
  kubernetes {
    kubeconfig = module.management_k3s_cluster.kubeconfig_raw
  }
}

# Saídas do cluster de gerenciamento
output "management_cluster_name" {
  description = "Nome do cluster k3d de gerenciamento."
  value       = module.management_k3s_cluster.cluster_name
}

output "management_cluster_kubeconfig_raw" {
  description = "Conteúdo bruto do kubeconfig para o cluster de gerenciamento k3s."
  value       = module.management_k3s_cluster.kubeconfig_raw
  sensitive   = true
}

output "management_cluster_kubeconfig_file_path" {
  description = "Caminho para o arquivo kubeconfig salvo do cluster de gerenciamento k3s."
  value       = module.management_k3s_cluster.kubeconfig_file_saved_path
}

output "management_cluster_api_port_info" {
  description = "Informações sobre a porta da API do cluster de gerenciamento."
  value       = module.management_k3s_cluster.k3d_api_host_port_actual
}

# Exemplo de como você poderia usar o provider Helm para instalar algo (DESCOMENTE PARA USAR):
/*
resource "helm_release" "argocd" {
  # provider = helm.management_k3s # Se usou alias no provider helm

  name       = "argo-cd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = "argocd"
  version    = "5.52.0" # Exemplo, verifique a versão mais recente

  create_namespace = true
  atomic           = true # Se a instalação falhar, o helm tentará reverter.

  values = [
    // Valores customizados para o chart do ArgoCD
    // Ex: "${file("${path.module}/argocd-values.yaml")}"
    // Exemplo: Para expor o servidor ArgoCD via NodePort (para k3d sem Ingress configurado ainda)
    // yamlencode({
    //   server = {
    //     service = {
    //       type = "NodePort"
    //       nodePort = 30080 # Exemplo, escolha uma porta válida
    //     }
    //   }
    // })
  ]

  # Garante que o cluster k3d e o kubeconfig estejam prontos antes de tentar instalar.
  depends_on = [module.management_k3s_cluster]
}
*/
