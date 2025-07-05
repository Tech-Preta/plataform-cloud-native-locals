# Guia de Configuração da Plataforma de Desenvolvimento Local

Este guia detalha os passos para configurar o ambiente base da plataforma de desenvolvimento local, incluindo o provisionamento do cluster de gerenciamento k3s (via k3d) e a instalação inicial do Crossplane.

## Pré-requisitos

Antes de começar, garanta que você tem as seguintes ferramentas instaladas e configuradas no seu sistema:

1.  **Git:** Para clonar e gerenciar o código fonte.
2.  **Docker:** Essencial, pois o k3d roda clusters Kubernetes (k3s) como containers Docker. Certifique-se de que o Docker Desktop ou Docker Engine esteja em execução.
3.  **k3d CLI:** A ferramenta de linha de comando para gerenciar clusters k3s no Docker. Siga as instruções de instalação em [k3d.io](https://k3d.io/#installation).
4.  **Terraform CLI (>= 1.0):** Para gerenciar a infraestrutura como código. Siga as instruções em [terraform.io](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli).
5.  **kubectl CLI:** A ferramenta de linha de comando para interagir com clusters Kubernetes. Siga as instruções em [kubernetes.io](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/).
6.  **Helm CLI:** O gerenciador de pacotes para Kubernetes. Siga as instruções em [helm.sh](https://helm.sh/docs/intro/install/).

## Parte 1: Provisionar o Cluster k3s de Gerenciamento com Terraform e k3d

Esta seção descreve como usar o Terraform para criar um cluster k3s local usando k3d. Este cluster servirá como o "cluster de gerenciamento" para as outras ferramentas da plataforma.

1.  **Clone o Repositório (se aplicável):**
    Se o código estiver em um repositório Git, clone-o. Caso contrário, certifique-se de que a estrutura de diretórios `plataforma-dev-local/` com todo o código gerado esteja no seu sistema.

2.  **Navegue até o Diretório do Cluster de Gerenciamento:**
    Abra seu terminal e navegue para o diretório onde a configuração Terraform do cluster de gerenciamento está localizada:
    ```bash
    cd plataforma-dev-local/terraform/management_cluster
    ```

3.  **Inicialize o Terraform:**
    Este comando baixa os providers Terraform necessários (incluindo `pvotal/k3d`).
    ```bash
    terraform init
    ```
    Se você já executou `terraform init` anteriormente com uma configuração diferente de providers, pode ser necessário usar `terraform init -upgrade` para garantir que as versões corretas dos providers sejam baixadas.

4.  **(Opcional) Revise o Plano Terraform:**
    Veja o que o Terraform planeja criar ou modificar:
    ```bash
    terraform plan
    ```
    Você deverá ver que um recurso do tipo `k3d_cluster` e `local_file` (para o kubeconfig) serão criados.

5.  **Aplique a Configuração Terraform:**
    Este comando provisionará o cluster k3d:
    ```bash
    terraform apply
    ```
    O Terraform solicitará uma confirmação. Digite `yes` e pressione Enter. O k3d começará a criar o cluster k3s dentro de containers Docker.
    Após a conclusão, um arquivo `kubeconfig` será gerado (por padrão) em `plataforma-dev-local/terraform/management_cluster/.kube/config`.

6.  **Configure `kubectl` para Usar o Novo Cluster:**
    Para interagir com o cluster recém-criado, aponte sua variável de ambiente `KUBECONFIG` para o arquivo gerado:
    ```bash
    export KUBECONFIG=$(pwd)/.kube/config
    # Para persistência entre sessões, adicione esta linha ao seu arquivo de perfil do shell (ex: ~/.bashrc, ~/.zshrc)
    # Lembre-se de usar o caminho absoluto se for adicionar ao perfil do shell:
    # export KUBECONFIG=${PWD}/.kube/config
    ```

7.  **Verifique a Criação do Cluster:**
    Execute os seguintes comandos para confirmar que o cluster está funcionando:
    ```bash
    kubectl get nodes
    # Você deverá ver o(s) nó(s) do cluster k3s com status 'Ready'.

    kubectl cluster-info
    # Verifica se o kubectl consegue se comunicar com o cluster.

    docker ps
    # Você verá os containers Docker que compõem seu cluster k3d (ex: k3d-management-k3s-server-0, k3d-management-k3s-serverlb).

    k3d cluster list
    # Lista os clusters k3d existentes.
    ```

## Parte 2: Instalar e Configurar Crossplane e Providers Iniciais

Com o cluster de gerenciamento k3s rodando e `kubectl` configurado, proceda com a instalação do Crossplane e seus providers.

*Certifique-se de que `kubectl` está configurado para o cluster k3s de gerenciamento (Passo 1.6).*

1.  **Instalar Crossplane via Helm:**
    ```bash
    helm repo add crossplane-stable https://charts.crossplane.io/stable
    helm repo update
    kubectl create namespace crossplane-system # Crie se ainda não existir
    helm install crossplane --namespace crossplane-system crossplane-stable/crossplane --set args='{--enable-composition-functions}' --wait
    ```
    Verifique se os pods do Crossplane estão rodando:
    ```bash
    kubectl get pods -n crossplane-system
    # Aguarde até que os pods `crossplane-...` e `crossplane-rbac-manager-...` estejam no estado 'Running'.
    ```

2.  **Instalar `provider-helm` do Crossplane:**
    Navegue de volta para a raiz do projeto ou para o diretório `plataforma-dev-local/crossplane/` se os arquivos YAML estiverem lá.
    ```bash
    kubectl apply -f plataforma-dev-local/crossplane/provider-helm.yaml
    ```
    Verifique a instalação do provider:
    ```bash
    kubectl get provider provider-helm
    # Aguarde até que INSTALLED=True e HEALTHY=True. Pode levar alguns minutos.
    # Você também pode verificar os logs do pod do provider-helm em crossplane-system.
    ```

3.  **Configurar `provider-helm` (in-cluster):**
    ```bash
    kubectl apply -f plataforma-dev-local/crossplane/providerconfig-helm-incluster.yaml
    ```
    Verifique a configuração:
    ```bash
    kubectl get providerconfigs.helm.crossplane.io helm-incluster-default
    ```

4.  **Instalar `provider-kubernetes` do Crossplane:**
    ```bash
    kubectl apply -f plataforma-dev-local/crossplane/provider-kubernetes.yaml
    ```
    Verifique a instalação do provider:
    ```bash
    kubectl get provider provider-kubernetes
    # Aguarde até que INSTALLED=True e HEALTHY=True.
    ```

5.  **Configurar `provider-kubernetes` (in-cluster):**
    ```bash
    kubectl apply -f plataforma-dev-local/crossplane/providerconfig-kubernetes-incluster.yaml
    ```
    Verifique a configuração:
    ```bash
    kubectl get providerconfigs.kubernetes.crossplane.io kubernetes-incluster-default
    ```

## Próximos Passos

Neste ponto, você deve ter:
*   Um cluster k3s de gerenciamento local rodando via k3d, provisionado pelo Terraform.
*   Crossplane instalado nesse cluster.
*   Os providers Crossplane `provider-helm` e `provider-kubernetes` instalados e configurados para operar dentro deste cluster.

Os próximos passos envolverão a configuração do `provider-aws` para LocalStack, a definição de XRDs/Composições no Crossplane, e a instalação das outras ferramentas da plataforma como ArgoCD e Backstage.
