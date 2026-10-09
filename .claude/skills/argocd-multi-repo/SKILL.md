---
name: argocd-multi-repo
description: Estrutura o ArgoCD do eng_lab com um repositório Git por aplicação, usando um ApplicationSet no repo de plataforma, e registra ou migra aplicações nesse modelo. Use sempre que o usuário falar em separar apps em repositórios próprios, multi-repo, ApplicationSet, AppProject, "adicionar uma nova aplicação no ArgoCD", "registrar um app", migrar um app de `platform/kubernetes/apps/` para um repo próprio, ou perguntar como organizar o GitOps do lab.
---

# ArgoCD com um repositório por aplicação

## O modelo

O `eng_lab` é o repo de plataforma: ele diz quais aplicações existem e onde estão, e cuida da infra do cluster. Cada aplicação vive no próprio repositório e é dona dos próprios manifests, em `deploy/`.

```text
eng_lab/                          (plataforma)
└── platform/kubernetes/
    ├── argocd/
    │   ├── root-app.yaml         # aponta para argocd/bootstrap
    │   ├── bootstrap/
    │   │   ├── projects/         # AppProject: infra, apps
    │   │   ├── infra-appset.yaml
    │   │   └── apps-appset.yaml
    │   └── apps/                 # um arquivo pequeno por aplicação
    │       └── <app>.yaml
    └── infra/                    # ingress-nginx, cert-manager, monitoring

<app>/                            (repo próprio)
├── src/, Dockerfile
└── deploy/
    ├── base/                     # deployment, service, ingress, kustomization
    └── overlays/
        ├── local/
        └── prod/
```

Um único ApplicationSet lê os arquivos de `argocd/apps/` e gera uma Application para cada um. Esse desenho foi escolhido em vez de uma `Application` escrita à mão por app porque o template fica em um só lugar e registrar um app vira um arquivo de cinco linhas. Se o usuário preferir ver cada Application explícita, o modelo antigo continua válido: basta trocar o `repoURL` de cada uma.

Os modelos prontos estão em `assets/`; copie e ajuste em vez de reescrever:

| Arquivo | Destino |
|---|---|
| `assets/apps-appset.yaml` | `platform/kubernetes/argocd/bootstrap/apps-appset.yaml` |
| `assets/project-apps.yaml` | `platform/kubernetes/argocd/bootstrap/projects/apps.yaml` |
| `assets/app-entry.yaml` | `platform/kubernetes/argocd/apps/<app>.yaml` |
| `assets/deploy/` | `deploy/` no repositório da aplicação |

## Antes de começar

Olhe o estado atual de `platform/kubernetes/argocd/`. Se `bootstrap/` e o ApplicationSet ainda não existem, a tarefa inclui montar a estrutura; se já existem, a tarefa é só registrar o app.

Criar repositórios no GitHub e dar push são ações externas: confirme com o usuário antes, ou peça que ele crie.

## Montar a estrutura (uma vez)

1. Crie `bootstrap/projects/apps.yaml` e `bootstrap/apps-appset.yaml` a partir dos modelos.
2. Mude o `path` do `root-app.yaml` para `platform/kubernetes/argocd/bootstrap`.
3. Mova as Applications de infra (hoje em `argocd/applications/`) para `bootstrap/` ou para um `infra-appset.yaml`, com `project: infra`.
4. Só remova as Applications antigas dos apps depois que o app correspondente estiver registrado no modelo novo. Como o `root-app` tem `prune: true`, apagar a Application antiga remove os recursos do cluster; no lab isso é aceitável, mas avise o usuário.

## Registrar uma aplicação

1. No repositório da aplicação, crie `deploy/base/` e `deploy/overlays/local/` a partir de `assets/deploy/`, trocando o nome, a imagem e o host.
2. Não declare o `Namespace` nos manifests do app: o ApplicationSet usa `CreateNamespace=true`, e declarar nos dois lugares gera recurso duplicado.
3. Use `ingressClassName` igual ao do controller do cluster e uma tag de imagem fixa.
4. No `eng_lab`, crie `platform/kubernetes/argocd/apps/<app>.yaml` a partir de `assets/app-entry.yaml`.
5. Valide com `kubectl kustomize deploy/overlays/local` no repo do app.

Para migrar um app que hoje está em `platform/kubernetes/apps/<app>/`, mova os manifests para `deploy/base/` do repo novo, tire o `Namespace` e os campos `namespace:` fixos, registre o app e só então apague a pasta e a Application antigas.

## Cuidados que acompanham o modelo

- **Chave `path` reservada.** O gerador de arquivos Git do ApplicationSet já expõe `path` como parâmetro. Não use essa chave nos arquivos de `argocd/apps/`; se o diretório de deploy precisar variar, use outro nome, como `deployPath`.
- **AppProject `apps`.** Restringe `sourceRepos` aos repos do usuário e não libera recursos de cluster, para que um repo de app não consiga mexer na infra.
- **Repos privados.** Um único Secret com o label `argocd.argoproj.io/secret-type: repo-creds` e a URL `https://github.com/antonioflaviosf` vale para todos os repos. O token nunca entra no Git.
- **Ambiente prod.** O caminho `deploy/overlays/local` vira parâmetro, com um ApplicationSet por cluster ou um gerador de matriz.
- **CI.** Se o pipeline do app commitar a tag da imagem em `deploy/`, o gatilho precisa ignorar esse caminho para não entrar em loop. Separar código e deploy em dois repos por app resolve isso, mas é exagero para o lab.
