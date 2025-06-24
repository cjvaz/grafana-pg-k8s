# 🚀 Grafana + PostgreSQL no Kubernetes com Kind

Este projeto configura uma stack completa de monitoramento usando **Grafana** e **PostgreSQL** em um cluster **Kubernetes** local usando **Kind**.

## 📋 Índice

- [🎯 Visão Geral](#-visão-geral)
- [🛠️ Pré-requisitos](#%EF%B8%8F-pré-requisitos)
- [📦 Instalação](#-instalação)
- [🚀 Uso Rápido](#-uso-rápido)
- [📖 Comandos Disponíveis](#-comandos-disponíveis)
- [🌐 Acesso aos Serviços](#-acesso-aos-serviços)
- [📁 Estrutura do Projeto](#-estrutura-do-projeto)
- [🔧 Configuração](#-configuração)
- [❓ Troubleshooting](#-troubleshooting)
- [🧹 Limpeza](#-limpeza)

## 🎯 Visão Geral

Este projeto oferece:

- ✅ **Cluster Kubernetes local** com Kind
- ✅ **PostgreSQL** como banco de dados principal
- ✅ **Grafana** para visualização e dashboards
- ✅ **Volumes persistentes** para dados
- ✅ **Port-forwarding** para acesso local
- ✅ **Automação completa** via Makefile

## 🛠️ Pré-requisitos

Certifique-se de ter as seguintes ferramentas instaladas:

### Obrigatórios
- **Docker** (versão 20.10+)
- **Kind** (versão 0.14+)
- **kubectl** (versão 1.20+)
- **Helm** (versão 3.7+)
- **Make**

### Verificação dos Pré-requisitos
```bash
# Verificar Docker
docker --version

# Verificar Kind
kind --version

# Verificar kubectl
kubectl version --client

# Verificar Helm
helm version

# Verificar Make
make --version
```

### Instalação dos Pré-requisitos (macOS)
```bash
# Instalar via Homebrew
brew install docker kind kubectl helm make

# Iniciar Docker Desktop
open -a Docker
```

## 📦 Instalação

### 🚀 Instalação Completa (Recomendada)
```bash
# Clone o repositório
git clone <repository-url>
cd Grafana_dd_Solutions

# Instalação completa automática
make install-all
```

### 📝 Instalação Passo a Passo
```bash
# 1. Preparar ambiente
make setup

# 2. Criar cluster Kubernetes
make create-cluster

# 3. Aplicar volumes persistentes
make apply-pvc

# 4. Instalar PostgreSQL
make install-postgres

# 5. Instalar Grafana
make install-grafana
```

## 🚀 Uso Rápido

### Após a instalação:

1. **Verificar status dos serviços:**
```bash
make status
```

2. **Iniciar port-forward para Grafana:**
```bash
make port-forward
```

3. **Obter senha do Grafana:**
```bash
make get-grafana-password
```

4. **Acessar Grafana:**
   - URL: http://localhost:3000
   - Usuário: `admin`
   - Senha: (usar comando acima)

## 🔄 Retomando Trabalho Após Reiniciar o Computador

Quando você reiniciar o computador, **seus dados persistem**, mas os serviços param de executar. Para retomar o trabalho:

### **🚀 Método Rápido (Recomendado):**
```bash
# Um comando que faz tudo automaticamente
make resume
```

### **📝 Método Manual (Passo a Passo):**
```bash
# 1. Verificar se Docker está rodando
docker ps

# 2. Verificar se cluster existe
kind get clusters

# 3. Verificar status dos serviços
make status

# 4. Reativar port-forwards
make port-forward          # Terminal 1 - Grafana
make port-forward-postgres # Terminal 2 - PostgreSQL (opcional)
```

### **⚠️ Se algo der errado:**
```bash
# Reset completo (seus dados serão mantidos)
make destroy && make install-all
```

## 📖 Comandos Disponíveis

Execute `make help` para ver todos os comandos ou consulte a lista abaixo:

### 🛠️ Setup e Preparação
| Comando | Descrição |
|---------|-----------|
| `make setup` | Prepara o ambiente (cria diretórios, instala helm deps) |
| `make create-cluster` | Cria o cluster Kubernetes com Kind |
| `make install-all` | Instalação completa (setup + cluster + serviços) |

### 📦 Instalação Individual
| Comando | Descrição |
|---------|-----------|
| `make apply-pvc` | Aplica PersistentVolumeClaim |
| `make install-postgres` | Instala PostgreSQL |
| `make install-grafana` | Instala Grafana |

### 🌐 Acesso aos Serviços
| Comando | Descrição |
|---------|-----------|
| `make port-forward` | Port-forward para Grafana (porta 3000) |
| `make port-forward-postgres` | Port-forward para PostgreSQL (porta 5432) |
| `make get-grafana-password` | Exibe a senha do admin do Grafana |

### 📊 Monitoramento
| Comando | Descrição |
|---------|-----------|
| `make status` | Mostra status de todos os recursos |
| `make cluster-info` | Informações do cluster |
| `make logs-grafana` | Logs do Grafana |
| `make logs-postgres` | Logs do PostgreSQL |

### 🔧 Utilitários
| Comando | Descrição |
|---------|-----------|
| `make restart-grafana` | Reinicia o Grafana |
| `make restart-postgres` | Reinicia o PostgreSQL |
| `make shell-postgres` | Conecta ao shell do PostgreSQL |

### 🧹 Limpeza
| Comando | Descrição |
|---------|-----------|
| `make uninstall-services` | Remove apenas os serviços (mantém cluster) |
| `make destroy` | Remove cluster e todos os recursos |
| `make clean` | Limpa arquivos locais |

## 🌐 Acesso aos Serviços

### 📊 Grafana
- **URL:** http://localhost:3000
- **Usuário:** `admin`
- **Senha:** Execute `make get-grafana-password`
- **Port-forward:** `make port-forward`

### 🐘 PostgreSQL
- **Host:** `localhost`
- **Porta:** `5432`
- **Database:** `grafanadb`
- **Usuário:** `grafana`
- **Senha:** `grafanapass`
- **Port-forward:** `make port-forward-postgres`
- **Shell direto:** `make shell-postgres`

### 🔗 String de Conexão PostgreSQL
```
postgresql://grafana:grafanapass@localhost:5432/grafanadb
```

## 📁 Estrutura do Projeto

```
Grafana_dd_Solutions/
├── Makefile                    # Automação principal
├── README.md                   # Esta documentação
├── kind-cluster.yaml          # Configuração do cluster Kind
├── postgres-values.yaml       # Configuração do PostgreSQL
├── grafana-values.yaml        # Configuração do Grafana
├── pv-pvc-postgres.yaml       # Volumes persistentes
└── kind-volumes/              # Diretório de volumes locais
    └── postgres/              # Volume do PostgreSQL
```

## 🔧 Configuração

### Personalizar Configurações
Edite as variáveis no início do `Makefile`:

```makefile
CLUSTER_NAME=grafana-local
POSTGRES_RELEASE=my-postgres
GRAFANA_RELEASE=my-grafana
NAMESPACE=default
```

### Arquivos de Configuração
- **`kind-cluster.yaml`**: Configuração do cluster Kind
- **`postgres-values.yaml`**: Configuração do Helm para PostgreSQL
- **`grafana-values.yaml`**: Configuração do Helm para Grafana
- **`pv-pvc-postgres.yaml`**: Definição de volumes persistentes

## ❓ Troubleshooting

### Problemas Comuns

#### 🔍 Cluster não inicia
```bash
# Verificar se Docker está rodando
docker ps

# Recriar cluster
make destroy
make create-cluster
```

#### 🔍 Pods ficam em Pending
```bash
# Verificar eventos
kubectl get events --sort-by=.metadata.creationTimestamp

# Verificar recursos
kubectl describe pod <pod-name>
```

#### 🔍 Port-forward não funciona
```bash
# Verificar se pod está Ready
make status

# Aguardar inicialização completa
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=grafana --timeout=300s
```

#### 🔍 Erro de permissão no volume
```bash
# Recriar diretório com permissões corretas
make clean
make mkdir-postgres
```

### Logs e Diagnóstico

```bash
# Verificar status geral
make status

# Logs específicos
make logs-grafana
make logs-postgres

# Informações do cluster
make cluster-info

# Eventos do Kubernetes
kubectl get events --sort-by=.metadata.creationTimestamp
```

### Reset Completo
```bash
# Limpeza total e reinstalação
make destroy
make clean
make install-all
```

## 🧹 Limpeza

### Limpeza Seletiva
```bash
# Remover apenas serviços (manter cluster)
make uninstall-services

# Limpar apenas dados locais
make clean
```

### Limpeza Completa
```bash
# Remover tudo
make destroy
```

## 📚 Recursos Adicionais

### Documentação Oficial
- [Kind Documentation](https://kind.sigs.k8s.io/)
- [Grafana Documentation](https://grafana.com/docs/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)

### Comandos Kubernetes Úteis
```bash
# Listar todos os recursos
kubectl get all

# Descrever um recurso específico
kubectl describe <resource-type> <resource-name>

# Acessar shell de um pod
kubectl exec -it <pod-name> -- /bin/bash

# Port-forward manual
kubectl port-forward <pod-name> <local-port>:<pod-port>
```

---

## 🆘 Suporte

Se encontrar problemas:

1. ✅ Verificar pré-requisitos
2. ✅ Consultar seção de [Troubleshooting](#-troubleshooting)
3. ✅ Verificar logs com `make logs-grafana` ou `make logs-postgres`
4. ✅ Tentar reset completo: `make destroy && make install-all`

---

**🎉 Projeto desenvolvido para ambiente de desenvolvimento local com Kubernetes!**
