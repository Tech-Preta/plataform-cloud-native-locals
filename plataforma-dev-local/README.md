# Plataforma de Desenvolvimento Local

Este repositório contém a configuração para uma plataforma de desenvolvimento local usando k3s, Terraform, Backstage, ArgoCD, LocalStack e Komoplane.

## Estrutura do Repositório

- `terraform/`: Contém o código Infrastructure as Code (IaC) usando Terraform para provisionar o cluster de gerenciamento k3s.
  - `modules/k3s_cluster/`: Módulo Terraform para criar um cluster k3s.
  - `management_cluster/`: Configuração do cluster k3s de gerenciamento.
- `backstage/`: (A ser criado) Configuração do Backstage.
- `argocd/`: (A ser criado) Configurações e manifestos do ArgoCD.
- `crossplane/`: (A ser criado) Configurações do Crossplane, XRDs, Composições.

## Como Começar

(Instruções serão adicionadas aqui)
