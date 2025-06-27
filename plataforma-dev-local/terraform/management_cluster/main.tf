# main.tf para o management_cluster

# Define a versão requerida do Terraform
terraform {
  required_version = ">= 1.0"

  # Define os providers requeridos e suas versões.
  # O provider `local` é usado pelo módulo k3s_cluster para executar scripts.
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4.0" # Bloqueia para uma versão específica para consistência
    }
    # Outros providers como kubernetes, helm, etc., serão configurados
    # aqui ou no providers.tf global, uma vez que o cluster esteja ativo.
  }
}

# Utiliza o módulo k3s_cluster para criar o cluster de gerenciamento.
module "management_k3s_cluster" {
  source = "../modules/k3s_cluster"

  cluster_name = var.cluster_name
  k3s_version  = var.k3s_version
  # Você pode sobrescrever outros defaults do módulo aqui, se necessário
  # k3s_extra_args = "--disable-cloud-controller --no-deploy traefik"
}

# Saídas do cluster de gerenciamento

output "management_cluster_kubeconfig_path" {
  description = "Caminho para o arquivo kubeconfig do cluster de gerenciamento k3s."
  value       = module.management_k3s_cluster.kubeconfig_file_path
}

output "management_cluster_k3s_install_command" {
  description = "Comando de instalação do k3s para o cluster de gerenciamento."
  value       = module.management_k3s_cluster.k3s_install_command
}

# Placeholder para configuração dos providers Kubernetes e Helm
# Uma vez que o cluster k3s esteja de pé e o kubeconfig esteja disponível,
# podemos configurar os providers Kubernetes e Helm para interagir com ele.

/*
provider "kubernetes" {
  alias      = "management_k3s"
  kubeconfig = module.management_k3s_cluster.kubeconfig_file_path
}

provider "helm" {
  alias = "management_k3s"
  kubernetes {
    kubeconfig = module.management_k3s_cluster.kubeconfig_file_path
  }
}

// Exemplo de como você poderia usar o provider Helm para instalar algo:
resource "helm_release" "argocd" {
  provider = helm.management_k3s # Especifica qual provider helm usar

  name       = "argo-cd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = "argocd"
  version    = "5.52.0" # Exemplo, verifique a versão mais recente

  create_namespace = true

  values = [
    // Valores customizados para o chart do ArgoCD
    // Ex: "${file("${path.module}/argocd-values.yaml")}"
  ]

  depends_on = [module.management_k3s_cluster] # Garante que o cluster exista primeiro
}
*/
