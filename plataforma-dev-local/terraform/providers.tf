terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4" # Pode ser removido se não usarmos mais local-exec em outros lugares
    }
    k3d = {
      source  = "pvotal/k3d"
      version = "~> 0.3.0" # Verifique a última versão no Terraform Registry
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20" # Exemplo, ajuste conforme necessário
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.10" # Exemplo, ajuste conforme necessário
    }
  }
}

provider "k3d" {
  # Nenhuma configuração global específica necessária para k3d por enquanto.
  # Ele usará o contexto Docker padrão.
}

// Provider Kubernetes (será configurado no management_cluster/main.tf após a criação do cluster k3d)
// provider "kubernetes" {
//   config_path = module.management_k3s_cluster.kubeconfig_path
// }

// Provider Helm (será configurado no management_cluster/main.tf após a criação do cluster k3d)
// provider "helm" {
//   kubernetes {
//     config_path = module.management_k3s_cluster.kubeconfig_path
//   }
// }
