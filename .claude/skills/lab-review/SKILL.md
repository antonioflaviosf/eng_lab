---
name: lab-review
description: Audita o eng_lab (lab de Platform Engineering com Incus, Ansible, k3s e ArgoCD) e devolve uma lista priorizada de problemas e melhorias. Use sempre que o usuário pedir para revisar, auditar, melhorar ou "dar uma olhada" no projeto, no README, nos docs, nos manifests Kubernetes, nos playbooks Ansible ou nos scripts do Incus, mesmo que não use a palavra "auditoria". Use também antes de propor qualquer reestruturação do repositório.
---

# Revisão do eng_lab

O objetivo é entregar ao usuário uma lista curta e priorizada do que está errado ou frágil no lab, com link para o arquivo e a linha, e a correção sugerida. A revisão é só leitura: não altere arquivos a menos que o usuário peça.

## Como o projeto está organizado

O fluxo é `Provision → Configure → Orchestrate → GitOps`:

| Camada | Onde fica | Ferramenta |
|---|---|---|
| Provisionamento | `environments/local/incus/` | Incus (VMs); `environments/prod/` reservado para OpenTofu |
| Configuração | `config/ansible/` | Ansible (bootstrap + role `k3s`) |
| GitOps | `platform/kubernetes/argocd/` | ArgoCD, App of Apps a partir do `root-app.yaml` |
| Workloads | `platform/kubernetes/apps/` | Manifests das aplicações |
| Infra do cluster | `platform/kubernetes/infra/` | ingress-nginx e afins |

O `Makefile` na raiz é o ponto de entrada (`local-up`, `local-down`, `local-bootstrap`, `local-k8s`).

## Passo a passo

1. Liste os arquivos versionados com `git ls-files`. O repo é pequeno; leia tudo, inclusive scripts e roles, e não só o README e os docs. Os problemas mais sérios costumam estar onde a documentação não olha.
2. Confira cada item do checklist abaixo contra o estado atual do código.
3. Leia `references/achados-2026-10-08.md`: é o resultado da última revisão. Verifique item por item se ainda vale antes de repetir, porque o usuário pode já ter corrigido.
4. Responda no formato descrito em "Formato da resposta".

## Checklist

**Segredos**
- Tokens, senhas ou chaves em arquivos ou comentários (o node-token do k3s já vazou uma vez em comentário). Um segredo commitado continua no histórico do GitHub mesmo depois de apagado, então a correção inclui rotacionar, não só remover.

**Coerência entre documentação e código**
- IPs, nomes de nós e topologia em `docs/environments.md` batem com `config/ansible/inventories/local/hosts.yml` e `environments/local/incus/create.sh`.
- Os comandos do README batem com os alvos do `Makefile`.
- Blocos de código Markdown fechados corretamente.

**Kubernetes e ArgoCD**
- Um único ingress controller ativo. O k3s traz o Traefik por padrão; se o ingress-nginx também sobe como `LoadBalancer`, os dois disputam as portas 80/443. Confira a flag `--disable traefik` na instalação do k3s e se todo `ingressClassName` aponta para a mesma classe.
- Recursos declarados duas vezes dentro da mesma Application (por exemplo, o mesmo `Namespace` em dois arquivos), o que gera aviso de recurso repetido no ArgoCD.
- Arquivos de values ou manifests que nenhuma Application referencia, ou que contradizem os values inline.
- Imagens sem tag fixa, containers sem `resources` e sem probes.
- Versão do ArgoCD e dos charts fixada (nada de `ref=stable` ou `latest`).
- Uso do projeto `default` para tudo, em vez de AppProjects com escopo.

**Ansible**
- O `ansible.cfg` está em `config/ansible/`, mas o `Makefile` roda da raiz; sem `ANSIBLE_CONFIG`, as opções dele não valem.
- Tarefas `shell`/`command` têm `creates` ou outra forma de idempotência.
- Esperas fixas (`sleep`, `wait_for` com timeout) usadas no lugar de uma condição real.

**Scripts do Incus**
- `set -euo pipefail` em todos os scripts.
- Checagens de existência frouxas (`grep -q "$node"` casa substrings).
- Arquivos de configuração que o script não lê (`config.yaml`).
- Sobras de depuração.

## Formato da resposta

Responda em português. Separe o que precisa ser corrigido do que é sugestão, e ordene por impacto:

```markdown
## Problemas a corrigir primeiro
1. **Título curto.** O que está errado, com link para arquivo e linha, e a correção.

## Melhorias sugeridas
- ...
```

Quando uma conclusão depender de algo que você não executou (por exemplo, o estado real do cluster), diga isso em vez de afirmar. No fim, diga o que você pode aplicar no repo e o que depende do usuário, como criar repositórios ou rotacionar credenciais.

Para a reestruturação do ArgoCD em um repositório por aplicação, use a skill `argocd-multi-repo`.
