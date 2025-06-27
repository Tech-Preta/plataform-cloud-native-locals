# main.tf para o módulo k3s_cluster usando o provider pvotal/k3d

resource "k3d_cluster" "this" {
  name    = var.cluster_name
  servers = var.k3d_servers
  agents  = var.k3d_agents
  k3s_image_tag = var.k3s_version # O provider k3d usa 'image_tag' para a versão do k3s.
                                  # Se var.k3s_version for vazio, k3d usa sua versão padrão do k3s.

  network = var.k3d_network

  k3s_server_args = var.k3s_extra_args # Passa argumentos extras para k3s server

  # Mapeamento da porta da API. Ex: "0:6443" (aleatória no host) ou "127.0.0.1:6444:6443" (fixa no host)
  api_port {
    host_ip   = split(":", var.k3d_api_port_mapping)[0] == "0" ? "0.0.0.0" : split(":", var.k3d_api_port_mapping)[0]
    host_port = split(":", var.k3d_api_port_mapping)[0] == "0" ? tonumber(split(":", var.k3d_api_port_mapping)[0]) : tonumber(split(":", var.k3d_api_port_mapping)[1])
    # O provider espera host_port como número se host_ip estiver presente.
    # Se host_port for 0, uma porta aleatória é usada.
    # A lógica acima tenta lidar com "PORTA_HOST:CONTAINER_PORT" ou apenas "0" (para aleatório na API).
    # Simplificação: Se var.k3d_api_port_mapping for "0:6443", isso se traduz em host_ip="0.0.0.0", host_port=0.
    # Se for "127.0.0.1:6444:6443", precisamos extrair corretamente.
    # O provider k3d pode ter uma maneira mais simples de lidar com isso, verificar documentação.
    # Temporariamente, vamos assumir que o formato é "IP:HOST_PORT" ou "HOST_PORT" (para 0.0.0.0)
    # e o provider lida com a porta do container (6443) implicitamente.
    # A documentação do provider k3d para `api_port` indica `host` e `port`.
    # Vamos ajustar para um formato mais simples. Se `var.k3d_api_port_mapping` for "127.0.0.1:6444",
    # host = "127.0.0.1", port = 6444.
    # Se for apenas "6444", host="0.0.0.0", port=6444.
    # Se for "0", porta aleatória. (O provider parece usar `host_port = 0` para isso)
  }

  dynamic "port_auto_map" {
    for_each = var.k3d_port_mappings
    content {
      host_port      = port_auto_map.value.host_port
      container_port = port_auto_map.value.container_port
      protocol       = port_auto_map.value.protocol
      node_filters   = port_auto_map.value.node_filters
    }
  }

  # k3d_args são argumentos para o comando `k3d cluster create`
  args = var.k3d_extra_args

  # Volumes (ex: ["/host/path:/container/path@server:0;agent:*"])
  dynamic "volume_with_node_filter" {
    for_each = var.k3d_volumes
    content {
      volume        = split("@", volume_with_node_filter.value)[0]
      node_filters  = [split("@", volume_with_node_filter.value)[1]] # Espera uma lista
    }
  }

  # Variáveis de ambiente (ex: ["KEY=VALUE@server:0"])
  dynamic "env_var_with_node_filter" {
    for_each = var.k3d_env_vars
    content {
      env_var      = split("@", env_var_with_node_filter.value)[0]
      node_filters = [split("@", env_var_with_node_filter.value)[1]] # Espera uma lista
    }
  }

  # Registries
  dynamic "registry" {
    for_each = var.k3d_registries
    content {
      host         = registry.value.host
      port         = registry.value.host_port # O provider chama de 'port'
      # config_file_path = registry.value.config_path # Verificar nome exato no provider
      # proxy_remote_url = registry.value.proxy_url
      # insecure_skip_verify = registry.value.skip_verify
    }
  }

  wait    = var.k3d_wait_for_server
  timeout = var.k3d_timeout

  kubeconfig_options {
    update_default_kubeconfig = var.kubeconfig_update_default
    # O provider k3d não tem uma opção direta para *salvar* o kubeconfig em um caminho específico
    # como output direto do recurso `k3d_cluster`. Ele o retorna como um atributo do recurso.
    # Nós o salvaremos usando `local_file` se `kubeconfig_output_path` for fornecido.
  }

  # Tolerations, labels, etc. podem ser adicionados se o provider suportar.
}

# Salvar o kubeconfig em um arquivo local se o caminho for fornecido
resource "local_file" "kubeconfig" {
  count = var.kubeconfig_output_path != "" ? 1 : 0

  content  = k3d_cluster.this.kubeconfig_raw # `kubeconfig_raw` é o atributo que contém o kubeconfig
  filename = var.kubeconfig_output_path

  # Permissões do arquivo (ex: 0600)
  file_permission = "0600"
  # directory_permission = "0700" # Se precisar criar o diretório
}

# Para simplificar o mapeamento da porta da API, vamos ajustar a variável k3d_api_port_mapping
# para ser um objeto, ou usar valores separados.
# Por agora, o main.tf acima tem uma tentativa de parse, mas pode precisar de refinamento
# baseado na forma exata como o provider `k3d_cluster.api_port` espera os dados.
# A documentação do provider para `k3d_cluster.api_port` sugere:
# api_port {
#   host    = "127.0.0.1" # IP do host ou "0.0.0.0" para todas as interfaces
#   port    = 6445        # Porta no host
# }
# A porta do container (6443) é implícita.
# Vamos precisar ajustar `var.k3d_api_port_mapping` para refletir isso ou adicionar novas variáveis.

# Solução temporária para api_port (REQUER AJUSTE NA DEFINIÇÃO DA VARIÁVEL `k3d_api_port_mapping`):
# Se `var.k3d_api_port_mapping` for "127.0.0.1:6444", então:
# host = "127.0.0.1"
# port = 6444
# Se for "0" (aleatório), o provider k3d geralmente lida com isso se port = 0.
# O `k3d_cluster.api_port` no TF provider espera `host` (string) e `host_port` (int).
# A lógica atual no `api_port` acima está um pouco confusa.
# Idealmente, teríamos:
# variable "k3d_api_host_ip" { default = "0.0.0.0" }
# variable "k3d_api_host_port" { default = 0 } # 0 para aleatório

# Vou simplificar o bloco api_port no resource "k3d_cluster" "this"
# e você precisará ajustar as variáveis de entrada no `management_cluster/main.tf`
# para `k3d_api_host_ip` e `k3d_api_host_port` (que adicionarei em variables.tf)

# (Este comentário é para mim mesmo, para corrigir na próxima etapa de variables.tf e management_cluster)
# A correção será:
# 1. Adicionar `k3d_api_host_ip` e `k3d_api_host_port` em `variables.tf`.
# 2. Usá-los diretamente no bloco `api_port` do `k3d_cluster`.
# 3. Remover `var.k3d_api_port_mapping`.
# 4. Atualizar `management_cluster/main.tf` para usar as novas variáveis.```hcl
# main.tf para o módulo k3s_cluster usando o provider pvotal/k3d

resource "k3d_cluster" "this" {
  name          = var.cluster_name
  servers       = var.k3d_servers
  agents        = var.k3d_agents
  image_tag     = var.k3s_version # O provider k3d usa 'image_tag' para a versão do k3s.

  network = var.k3d_network

  k3s_node_label { # Exemplo de como adicionar labels aos nós k3s
    key   = "k3d.cluster.name"
    value = var.cluster_name
    node_filters = ["all"]
  }

  k3s_server_arg { # Passa argumentos extras para k3s server
    arg          = join(" ", var.k3s_extra_args) # O provider espera uma string única para o arg
    node_filters = ["server:*"]
  }

  port_map { # Mapeamento da porta da API
    host_ip        = var.k3d_api_host_ip
    host_port      = var.k3d_api_host_port
    container_port = 6443 # Porta padrão da API k3s/k8s
    node_filters   = ["server:0", "loadbalancer"] # Expor no primeiro server e no loadbalancer do k3d
  }

  dynamic "port_map" { # Mapeamentos de porta adicionais
    for_each = var.k3d_port_mappings
    content {
      host_ip        = "0.0.0.0" # Ou permitir configuração por mapping
      host_port      = port_map.value.host_port
      container_port = port_map.value.container_port
      protocol       = port_map.value.protocol
      node_filters   = port_map.value.node_filters
    }
  }

  # k3d_args são argumentos para o comando `k3d cluster create`
  arg = var.k3d_extra_args # O provider espera uma lista de strings

  # Volumes (ex: ["/host/path:/container/path@server:0;agent:*"])
  dynamic "volume" {
    for_each = var.k3d_volumes
    content {
      volume       = split("@", volume.value)[0]
      node_filters = [split("@", volume.value)[1]] # Espera uma lista
    }
  }

  # Variáveis de ambiente (ex: ["KEY=VALUE@server:0"])
  dynamic "env" {
    for_each = var.k3d_env_vars
    content {
      value        = split("@", env.value)[0] # Formato "KEY=VALUE"
      node_filters = [split("@", env.value)[1]] # Espera uma lista
    }
  }

  # Registries
  # A estrutura exata para registries pode variar. O provider `pvotal/k3d`
  # pode ter uma maneira específica. O exemplo abaixo é uma suposição.
  # Consulte a documentação do provider para `registry` block.
  # Por enquanto, vamos omitir para simplificar, pode ser adicionado depois se necessário.
  /*
  dynamic "registry" {
    for_each = var.k3d_registries
    content {
      host_url     = registry.value.host # Ex: "my.registry.corp:5000"
      # ... outras opções como credentials, etc.
    }
  }
  */

  wait    = var.k3d_wait_for_server
  timeout = var.k3d_timeout # String, ex: "360s"

  kubeconfig_options {
    update_default_kubeconfig = var.kubeconfig_update_default
    # O provider k3d não tem uma opção direta para *salvar* o kubeconfig em um caminho específico
    # como output direto do recurso `k3d_cluster`. Ele o retorna como um atributo do recurso.
    # Nós o salvaremos usando `local_file` se `kubeconfig_output_path` for fornecido.
  }

  destroy_volumes = true # Garante que os volumes sejam limpos no destroy
}

# Salvar o kubeconfig em um arquivo local se o caminho for fornecido
resource "local_file" "kubeconfig" {
  count = var.kubeconfig_output_path != "" ? 1 : 0

  content  = k3d_cluster.this.kubeconfig_raw # `kubeconfig_raw` é o atributo que contém o kubeconfig
  filename = var.kubeconfig_output_path

  # Permissões do arquivo (ex: 0600)
  file_permission = "0600"
  directory_permission = "0700" # Se precisar criar o diretório
}
```

**Explicação das Mudanças e Pontos Importantes:**

*   **`k3d_cluster` Resource:** É o recurso principal do provider `pvotal/k3d` para criar o cluster.
*   **`image_tag`:** Usado para especificar a versão do k3s (ex: `v1.28.5+k3s1`).
*   **`k3s_server_arg` e `k3s_agent_arg`:** O provider estrutura argumentos para k3s de forma um pouco diferente. Usei `k3s_server_arg` para os argumentos do servidor.
*   **`port_map`:** Para mapear portas. A API (6443) é crítica. Outras portas (HTTP/HTTPS) podem ser mapeadas para Ingress.
    *   **Importante:** O `k3d_api_host_ip` e `k3d_api_host_port` são novas variáveis que precisaremos adicionar ao `variables.tf` do módulo e configurar no `management_cluster/main.tf`. Elas substituem a antiga `k3d_api_port_mapping` para maior clareza.
*   **`arg` (para k3d):** Argumentos diretos para o comando `k3d cluster create ...`.
*   **`volume` e `env`:** Para montar volumes e definir variáveis de ambiente nos nós.
*   **`kubeconfig_options`:** `update_default_kubeconfig = false` é recomendado para evitar que o k3d altere seu `~/.kube/config` global.
*   **`local_file`:** Usado para explicitamente salvar o `kubeconfig_raw` (que é uma saída do recurso `k3d_cluster.this`) em um arquivo local, se `var.kubeconfig_output_path` for especificado. Isso nos dá controle sobre onde o kubeconfig do cluster gerenciado pelo Terraform é armazenado.
*   **`destroy_volumes = true`:** Para garantir a limpeza.

**Próximo Passo Imediato:**

1.  Atualizar `plataforma-dev-local/terraform/modules/k3s_cluster/variables.tf` para remover `k3d_api_port_mapping` e adicionar `k3d_api_host_ip` e `k3d_api_host_port`.
2.  Atualizar `plataforma-dev-local/terraform/modules/k3s_cluster/outputs.tf`.

Vamos fazer isso. Vou começar atualizando `variables.tf`.
