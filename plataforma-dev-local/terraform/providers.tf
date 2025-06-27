terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
    // Adicionaremos outros providers conforme necessário (kubernetes, helm, etc.)
  }
}

// Configuração do provider local (usado para executar scripts de instalação do k3s)
// Nenhuma configuração específica necessária por enquanto.

// Provider Kubernetes (será configurado após a criação do cluster k3s)
/*
provider "kubernetes" {
  // A ser configurado com o kubeconfig do cluster k3s
}
*/

// Provider Helm (será configurado após a criação do cluster k3s)
/*
provider "helm" {
  kubernetes {
    // A ser configurado com o kubeconfig do cluster k3s
  }
}
*/
