# main.tf para o módulo k3s_cluster

variable "cluster_name" {
  description = "Nome do cluster k3s."
  type        = string
  default     = "management-cluster"
}

variable "k3s_version" {
  description = "Versão do k3s a ser instalada."
  type        = string
  default     = "v1.28.5+k3s1" # Exemplo, verifique a última versão estável
}

variable "k3s_install_script_url" {
  description = "URL do script de instalação do k3s."
  type        = string
  default     = "https://get.k3s.io"
}

variable "k3s_extra_args" {
  description = "Argumentos extras para a instalação do k3s (ex: --no-deploy traefik)."
  type        = string
  default     = "--no-deploy traefik --no-deploy servicelb" # Exemplo, podemos querer usar nosso próprio ingress
}

resource "null_resource" "k3s_server_install" {
  # Usaremos um provisionador local para instalar o k3s.
  # Isso é uma simplificação. Para ambientes de produção ou mais complexos,
  # você pode usar providers específicos de VM/cloud ou ferramentas como Ansible.

  triggers = {
    # Recria o recurso se o nome do cluster ou versão mudar.
    cluster_name = var.cluster_name
    k3s_version  = var.k3s_version
  }

  provisioner "local-exec" {
    command = <<EOT
      echo "Verificando se o k3s já está instalado e configurado para ${var.cluster_name}..."
      if k3s kubectl get nodes --kubeconfig /etc/rancher/k3s/k3s.yaml &>/dev/null && k3s --version | grep -q "${var.k3s_version}"; then
        echo "k3s versão ${var.k3s_version} já parece estar rodando para ${var.cluster_name}."
        k3s kubectl get nodes --kubeconfig /etc/rancher/k3s/k3s.yaml
        exit 0
      fi

      echo "Instalando k3s server (versão ${var.k3s_version}) com nome ${var.cluster_name}..."
      curl -sfL ${var.k3s_install_script_url} | INSTALL_K3S_VERSION='${var.k3s_version}' INSTALL_K3S_NAME='${var.cluster_name}' INSTALL_K3S_EXEC='server ${var.k3s_extra_args}' sh -s -

      echo "Aguardando o k3s server iniciar..."
      sleep 30 # Dê um tempo para o servidor iniciar completamente

      echo "Verificando status do k3s..."
      sudo k3s kubectl get nodes --kubeconfig /etc/rancher/k3s/k3s.yaml

      echo "Para interagir com o cluster, você geralmente precisará do kubeconfig:"
      echo "sudo cat /etc/rancher/k3s/k3s.yaml"
      echo "Considere copiar e ajustar as permissões ou usar 'k3s kubectl ...' "

      # Cria um diretório para o kubeconfig se não existir
      mkdir -p ${path.cwd}/.kube

      # Copia o kubeconfig para o diretório local para facilitar o acesso
      # CUIDADO: Este kubeconfig terá privilégios de administrador.
      # Em um cenário real, você deve gerenciar o acesso de forma mais segura.
      sudo cp /etc/rancher/k3s/k3s.yaml ${path.cwd}/.kube/config
      sudo chown $(id -u):$(id -g) ${path.cwd}/.kube/config
      chmod 0600 ${path.cwd}/.kube/config
      echo "Kubeconfig copiado para ${path.cwd}/.kube/config"
      echo "Você pode precisar definir a variável de ambiente KUBECONFIG:"
      echo "export KUBECONFIG=${path.cwd}/.kube/config"

    EOT
    interpreter = ["bash", "-c"]
    # on_failure  = fail # Ou continue, dependendo da política desejada
  }

  # Provisioner para desinstalação do k3s
  # É importante ter uma maneira de limpar os recursos
  provisioner "local-exec" {
    when    = destroy
    command = <<EOT
      echo "Desinstalando k3s server (${var.cluster_name})..."
      if [ -x "/usr/local/bin/k3s-uninstall.sh" ]; then
        /usr/local/bin/k3s-uninstall.sh
        echo "k3s desinstalado."
      elif [ -x "/usr/local/bin/k3s-agent-uninstall.sh" ]; then
        # Caso tenha sido instalado como agent por engano
        /usr/local/bin/k3s-agent-uninstall.sh
        echo "k3s agent desinstalado."
      else
        echo "Script de desinstalação do k3s não encontrado. Pode ser necessário remover manualmente."
      fi
      rm -f ${path.cwd}/.kube/config
    EOT
    interpreter = ["bash", "-c"]
  }
}

# Output para o kubeconfig (o conteúdo real, não apenas o caminho)
# Isso pode ser útil para outros providers Terraform ou para outputs raiz.
# No entanto, com local-exec, pegar o conteúdo diretamente é um pouco mais complexo
# e geralmente é mais fácil referenciar o arquivo copiado.
output "kubeconfig_file_path" {
  description = "Caminho para o arquivo kubeconfig gerado para o cluster k3s."
  value       = "${path.cwd}/.kube/config"
  depends_on  = [null_resource.k3s_server_install]
}

output "k3s_install_command" {
  description = "Comando de exemplo para instalar o k3s manualmente se necessário."
  value       = "curl -sfL ${var.k3s_install_script_url} | INSTALL_K3S_VERSION='${var.k3s_version}' INSTALL_K3S_NAME='${var.cluster_name}' INSTALL_K3S_EXEC='server ${var.k3s_extra_args}' sh -s -"
}
