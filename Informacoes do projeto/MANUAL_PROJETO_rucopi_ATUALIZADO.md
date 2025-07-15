# 📖 MANUAL DO PROJETO - rucopi

## 📋 INFORMAÇÕES GERAIS

**Nome do Projeto:** rucopi - Sistema de Coleta de Entulho para Prefeitura Municipal de Piracuruca-PI
**Tecnologias Principais:** Flutter, Dart, Supabase
**Plataformas Alvo:** Android, iOS (Mobile App), Web (Dashboard Administrativo)
**Ambiente de Desenvolvimento:** Windows, VS Code (com Flutter SDK configurado)

---

## 🎯 VISÃO GERAL E OBJETIVOS

O projeto rucopi visa desenvolver um sistema completo para otimizar a gestão da coleta de entulho na Prefeitura Municipal de Piracuruca-PI. Este sistema será composto por um aplicativo móvel para moradores, permitindo a solicitação e acompanhamento de coletas, e um painel administrativo web para a gestão das operações pela prefeitura. O objetivo principal é aprimorar a eficiência do serviço, a comunicação com os cidadãos e a fiscalização do descarte de resíduos.

---

## 🏛️ ARQUITETURA DO SISTEMA

### Componentes Principais:

1.  **Mobile App (Flutter):** Aplicativo nativo para dispositivos Android e iOS, destinado aos moradores. Permitirá o cadastro, login, solicitação de coleta (com envio de fotos e descrição), acompanhamento do status das solicitações e histórico.
2.  **Dashboard Web (Flutter):** Painel administrativo acessível via navegador web, para uso exclusivo da equipe da prefeitura. Oferecerá funcionalidades como gestão de solicitações, visualização em mapa, cadastro de equipes, relatórios e auditoria.
3.  **Backend (Supabase):** A espinha dorsal do sistema, responsável pela autenticação de usuários, armazenamento de dados (banco de dados relacional), e gerenciamento de arquivos (fotos). Será utilizado o Supabase, uma alternativa de código aberto ao Firebase, que oferece um conjunto robusto de ferramentas para desenvolvimento de aplicações.

### Detalhes do Backend com Supabase:

- **Autenticação:** Gerenciamento de usuários via e-mail e senha, com suporte a outras formas de autenticação no futuro, se necessário.
- **Banco de Dados (PostgreSQL):** Estrutura relacional para usuários, solicitações, equipes, etc.
- **Armazenamento (Storage):** Utilizado para fotos das solicitações de coleta, com políticas de acesso e limites definidos.

### Estrutura de Pastas (Proposta Inicial):

```
rucopi/
├── mobile/             # Projeto Flutter para o aplicativo móvel
│   └── rucopi_mobile/
│       ├── lib/
│       ├── pubspec.yaml
│       └── ...
├── dashboard/          # Projeto Flutter para o painel administrativo web
│   └── rucopi_dashboard/
│       ├── lib/
│       ├── pubspec.yaml
│       └── ...
├── docs/               # Documentação do projeto (incluindo este manual)
│   └── rucopi_manual.md
└── README.md
```

---

## 📅 LINHA DO TEMPO E FASES DO PROJETO

Este projeto será dividido em fases, com objetivos claros e entregáveis em cada uma. A ideia é seguir um desenvolvimento iterativo, garantindo que as funcionalidades mais críticas sejam implementadas primeiro.

### **⏳ FASE 1 – PLANEJAMENTO E ESTRUTURA (EM ANDAMENTO/REVISÃO)**

Esta fase é crucial para estabelecer as bases do projeto, garantindo que todas as configurações iniciais estejam corretas e que a arquitetura esteja bem definida. Embora a versão anterior tenha sido excluída, esta fase está sendo refeita com foco nas novas tecnologias e requisitos.

**Objetivos:**
*   Definição e validação do escopo detalhado do projeto.
*   Criação da identidade visual básica (ícone, cores, splash screen).
*   Configuração inicial do ambiente Supabase (projeto, banco de dados, autenticação, storage).
*   Configuração do repositório Git para controle de versão.
*   Estrutura inicial dos projetos Flutter (Mobile App e Dashboard Web).

**Tarefas Detalhadas:**

*   **1.1 Validação do Escopo:**
    *   [ ] Revisar e confirmar todas as funcionalidades desejadas com a prefeitura de Piracuruca-PI.
    *   [ ] Documentar os casos de uso e requisitos não funcionais.

*   **1.2 Identidade Visual:**
    *   [ ] Desenvolver um ícone para o aplicativo e dashboard.
    *   [ ] Definir a paleta de cores principal e secundária.
    *   [ ] Criar a splash screen inicial para o aplicativo móvel.

*   **1.3 Configuração do Supabase:**
    *   [ ] Criar um novo projeto no Supabase.
    *   [ ] Configurar o módulo de Autenticação (Auth) para e-mail e senha.
    *   [ ] Criar o esquema inicial do banco de dados PostgreSQL para usuários e solicitações.
    *   [ ] Configurar o Supabase Storage para o armazenamento de fotos, definindo políticas de acesso e tamanhos máximos para otimização do plano gratuito.
    *   [ ] Obter as chaves de API (URL e `anon_key`) do Supabase para integração com o Flutter.

*   **1.4 Configuração do Repositório Git:**
    *   [ ] Criar um novo repositório Git (ex: GitHub, GitLab, Bitbucket).
    *   [ ] Configurar o `.gitignore` para excluir arquivos desnecessários e sensíveis.
    *   [ ] Realizar o primeiro commit da estrutura básica do projeto.

*   **1.5 Estrutura Inicial dos Projetos Flutter:**
    *   [ ] Criar o projeto Flutter `rucopi_mobile`.
    *   [ ] Criar o projeto Flutter `rucopi_dashboard`.
    *   [ ] Adicionar as dependências do Supabase (ex: `supabase_flutter`) aos arquivos `pubspec.yaml` de ambos os projetos.
    *   [ ] Implementar a inicialização do Supabase nos projetos Flutter.

**Status:** Em andamento. A reestruturação do projeto implica na revisão e execução dessas tarefas com as novas tecnologias.

### **⏳ FASE 2 – DASHBOARD ADMINISTRATIVO (PRÓXIMA)**

Esta fase focará no desenvolvimento do painel de controle web, que será a principal ferramenta para a equipe da prefeitura gerenciar as operações de coleta.

**Objetivos:**
*   Implementar o sistema de autenticação e controle de perfis para administradores e operadores.
*   Desenvolver as funcionalidades de visualização e gestão de solicitações de coleta.
*   Criar ferramentas de relatórios e análise para monitoramento do serviço.

**Tarefas Detalhadas:**

*   **2.1 Autenticação e Perfis:**
    *   [ ] Tela de login para administradores e operadores.
    *   [ ] Implementação da autenticação via Supabase Auth.
    *   [ ] Gerenciamento de perfis (admin/operador/fiscal) e permissões de acesso.

*   **2.2 Gestão de Solicitações:**
    *   [ ] Lista de solicitações de coleta com filtros por status, data, bairro.
    *   [ ] Detalhes da solicitação: fotos, descrição, informações do solicitante.
    *   [ ] Funcionalidade para atualizar o status da solicitação (pendente, em andamento, concluída).
    *   [ ] Mapa interativo exibindo a localização das solicitações (sem GPS no momento, usar coordenadas fornecidas na solicitação).
    *   [ ] Visualização das fotos anexadas às solicitações (integrado com Supabase Storage).

*   **2.3 Gestão de Equipes e Coletas:**
    *   [ ] Cadastro e gerenciamento de equipes de coleta.
    *   [ ] Atribuição de solicitações a equipes específicas.
    *   [ ] Registro de ações no sistema de auditoria para rastrear mudanças.

*   **2.4 Relatórios e Análises:**
    *   [ ] Relatórios básicos por período, bairro e status.
    *   [ ] Funcionalidade de exportação de relatórios (Excel e PDF).
    *   [ ] Painel principal com visão geral e KPIs (indicadores chave de performance).

**Status:** A ser iniciada após a conclusão da Fase 1.

### **🔮 FASE 3 – APP DO MORADOR (FUTURO)**

Esta fase se concentrará no desenvolvimento do aplicativo móvel para os cidadãos, permitindo que eles interajam diretamente com o sistema.

**Objetivos:**
*   Permitir o cadastro e login de moradores.
*   Habilitar a criação e acompanhamento de solicitações de coleta.
*   Fornecer um histórico claro das interações do morador com o serviço.

**Tarefas Detalhadas:**

*   **3.1 Cadastro e Login:**
    *   [ ] Tela de cadastro de morador (com CPF, e-mail, endereço).
    *   [ ] Login com e-mail e senha via Supabase Auth.

*   **3.2 Solicitação de Coleta:**
    *   [ ] Formulário para nova solicitação: envio de fotos (Supabase Storage), descrição, tipo de entulho.
    *   [ ] Geração de protocolo de acompanhamento para cada solicitação.
    *   [ ] **Observação:** O GPS não será utilizado nesta fase. A localização da solicitação pode ser inferida pelo endereço ou, se necessário, um campo manual para coordenadas pode ser adicionado posteriormente.

*   **3.3 Acompanhamento e Histórico:**
    *   [ ] Tela de histórico de solicitações com status atualizado.
    *   [ ] Visualização de detalhes da coleta, incluindo fotos e informações da equipe atribuída.

**Status:** A ser iniciada após a conclusão da Fase 2.

### **🧪 FASE 4 – TESTES E HOMOLOGAÇÃO (FUTURO)**

Esta fase é dedicada a garantir a qualidade e a estabilidade do sistema antes do lançamento.

**Objetivos:**
*   Realizar testes abrangentes em todas as funcionalidades.
*   Identificar e corrigir bugs.
*   Preparar o ambiente para a publicação final.

**Tarefas Detalhadas:**

*   **4.1 Testes:**
    *   [ ] Testes de unidade e integração para ambos os projetos (Mobile e Dashboard).
    *   [ ] Testes de usabilidade com usuários-piloto (equipe da prefeitura e moradores).
    *   [ ] Testes de segurança e performance.

*   **4.2 Correções:**
    *   [ ] Registro e priorização de bugs encontrados.
    *   [ ] Implementação de correções e retestes.

*   **4.3 Homologação:**
    *   [ ] Configuração de um ambiente de testes/homologação separado.
    *   [ ] Validação final do sistema com a prefeitura.

**Status:** A ser iniciada após a conclusão da Fase 3.

### **🚀 FASE 5 – ENTREGA E PUBLICAÇÃO (FUTURO)**

A fase final do projeto, focada na implantação e disponibilização do sistema para uso público.

**Objetivos:**
*   Publicar o Dashboard Web e o Mobile App nas respectivas lojas.
*   Fornecer documentação de uso e realizar a apresentação oficial.

**Tarefas Detalhadas:**

*   **5.1 Publicação:**
    *   [ ] Publicação do Dashboard Web em um ambiente de produção.
    *   [ ] Preparação e submissão do Mobile App para Google Play Store e Apple App Store.

*   **5.2 Documentação e Treinamento:**
    *   [ ] Elaboração de manuais de uso para o Dashboard e o Mobile App.
    *   [ ] Treinamento para a equipe da prefeitura.

*   **5.3 Apresentação:**
    *   [ ] Apresentação oficial do sistema à prefeitura e stakeholders.

**Status:** A ser iniciada após a conclusão da Fase 4.

---

## 🎯 ROADMAP DE PRIORIDADES

Este roadmap define a ordem de importância das funcionalidades, garantindo que o MVP (Produto Mínimo Viável) seja entregue primeiro.

### **🔥 Prioridade Alta (MVP Funcional)**

Essas funcionalidades são essenciais para que o sistema seja minimamente utilizável e entregue valor imediato.

*   [ ] **Login e Cadastro:**
    *   Implementação completa do fluxo de login e cadastro para usuários (moradores) e administradores/operadores (dashboard).
    *   Integração com Supabase Auth.
*   [ ] **Envio de Solicitação:**
    *   Funcionalidade no Mobile App para o morador criar uma nova solicitação de coleta.
    *   Inclusão de campos para fotos (upload para Supabase Storage), descrição do entulho e tipo.
    *   **Importante:** A localização será baseada no endereço fornecido, sem uso de GPS nesta etapa.
*   [ ] **Lista e Status da Solicitação:**
    *   Visualização das solicitações no Dashboard Web, com filtros e indicação clara do status (pendente, em andamento, concluída).
    *   No Mobile App, histórico das solicitações do morador com seus respectivos status.
*   [ ] **Visualização e Atualização no Painel:**
    *   No Dashboard, capacidade de visualizar os detalhes de cada solicitação e atualizar seu status.
    *   Integração com o banco de dados Supabase para persistência das informações.
*   [ ] **Relatórios Básicos:**
    *   Geração de relatórios simples no Dashboard, como número de solicitações por período ou status.
*   [ ] **Exportação:**
    *   Funcionalidade para exportar os relatórios básicos em formatos como CSV ou PDF.

### **📊 Prioridade Média**

Funcionalidades que agregam valor significativo após o MVP, melhorando a gestão e a interação.

*   [ ] **Denúncia de Descarte Irregular:**
    *   Funcionalidade no Mobile App para moradores reportarem descarte irregular de entulho.
*   [ ] **Canal de Atendimento:**
    *   Implementação de um canal de comunicação dentro do aplicativo para dúvidas ou suporte.
*   [ ] **Cadastro de Equipes:**
    *   No Dashboard, funcionalidade para cadastrar e gerenciar as equipes de coleta.
*   [ ] **Mapa de Calor e KPIs Avançados:**
    *   Visualização em mapa de calor das áreas com maior concentração de solicitações.
    *   Dashboards com KPIs mais detalhados sobre a produtividade e eficiência.

### **🌟 Prioridade Futuro**

Funcionalidades que podem ser consideradas em etapas posteriores do projeto, após a estabilização e sucesso das fases anteriores.

*   [ ] **Avaliação de Serviço:**
    *   Funcionalidade no Mobile App para o morador avaliar o serviço de coleta.
*   [ ] **Selos e Pontuação:**
    *   Sistema de gamificação para incentivar o uso correto do serviço.
*   [ ] **Otimização de Rotas:**
    *   Integração com serviços de mapas para otimização das rotas de coleta das equipes.
*   [ ] **WhatsApp API:**
    *   Integração com a API do WhatsApp para notificações automáticas ou comunicação.
*   [ ] **Business Intelligence Avançado:**
    *   Ferramentas de BI para análises mais profundas dos dados de coleta.

---

## ⚠️ QUESTÕES IMPORTANTES E DECISÕES DE ARQUITETURA

### **1. Separação de Projetos Flutter:**

*   **Decisão:** O Mobile App e o Dashboard Web serão desenvolvidos como projetos Flutter distintos (`rucopi_mobile` e `rucopi_dashboard`).
*   **Justificativa:** Esta abordagem promove a organização do código, permite builds independentes para cada plataforma e facilita a publicação separada. Embora compartilhem algumas dependências e a lógica de backend (Supabase), a separação garante que as interfaces e fluxos de trabalho sejam otimizados para seus respectivos públicos e plataformas.

### **2. Plataformas Suportadas:**

*   **Mobile App:** Foco inicial em Android e iOS. Não haverá versão desktop do aplicativo móvel.
*   **Dashboard Web:** Exclusivamente para navegadores web.
*   **Justificativa:** Priorizar as plataformas mais relevantes para cada componente do sistema evita complexidade desnecessária e permite concentrar os esforços de desenvolvimento onde eles trarão o maior impacto.

### **3. Escolha do Backend (Supabase vs. Firebase):**

*   **Decisão:** Supabase será a principal solução de backend.
*   **Justificativa:** Embora o Firebase seja uma opção popular, o Supabase foi escolhido por ser uma alternativa de código aberto que oferece um conjunto de funcionalidades robustas (PostgreSQL, Auth, Storage) que atendem perfeitamente aos requisitos do projeto, especialmente a autenticação e o banco de dados para as fotos. A camada gratuita do Supabase é generosa para o início do projeto. A exclusão do Firebase Messaging e a não utilização de GPS inicialmente simplificam a integração e o foco nas funcionalidades essenciais.

---

## 🔧 COMANDOS ÚTEIS PARA O DESENVOLVIMENTO

Estes comandos são essenciais para navegar e gerenciar os projetos Flutter durante o desenvolvimento:

```bash
# Navegar para o diretório do projeto mobile
cd rucopi/mobile/rucopi_mobile

# Navegar para o diretório do projeto dashboard
cd rucopi/dashboard/rucopi_dashboard

# Executar o aplicativo móvel (ex: no Chrome para testes web, ou em um emulador/dispositivo)
flutter run -d chrome

# Executar o dashboard web
flutter run -d chrome

# Obter as dependências do projeto (executar em cada diretório de projeto Flutter)
flutter pub get

# Analisar o código em busca de erros e avisos (executar em cada diretório de projeto Flutter)
flutter analyze

# Limpar os arquivos de build (útil para resolver problemas de build)
flutter clean

# Atualizar o SDK do Flutter (executar no diretório raiz do Flutter SDK)
flutter upgrade

# Verificar a configuração do ambiente Flutter
flutter doctor
```

---

**📊 RESUMO:** Este manual serve como um guia vivo para o desenvolvimento do projeto rucopi. Ele será atualizado continuamente para refletir o progresso, as decisões e quaisquer mudanças no escopo. A colaboração e a comunicação são fundamentais para o sucesso deste empreendimento. A próxima etapa é focar na conclusão da Fase 1, garantindo que todas as configurações do Supabase e a estrutura inicial dos projetos Flutter estejam prontas para o desenvolvimento das funcionalidades.

---

## 📘 DIÁRIO DE PROGRESSO DO DESENVOLVIMENTO

### 🗓️ Atualizado em 15/07/2025

#### ✅ Etapas já concluídas até agora:

1. **Preparação do ambiente de desenvolvimento**
   - Instalado o Flutter SDK, configurado o VS Code e o Git.

2. **Estruturação do projeto e versionamento**
   - Criada pasta raiz `rucopi/`, com subpastas `mobile/` e `dashboard/`.
   - Projetos Flutter criados com os comandos:
     - `flutter create rucopi_mobile`
     - `flutter create rucopi_dashboard`
   - `.gitignore` configurado para ignorar arquivos sensíveis e irrelevantes.
   - Repositório Git inicializado e primeiro commit realizado com sucesso.

3. **Criação do projeto no Supabase**
   - Projeto criado no painel Supabase.
   - Obtidos e anotados os valores de `Project URL` e `anonKey`.

4. **Configuração de autenticação (Auth)**
   - Autenticação por email e senha ativada.
   - Desativadas todas as formas alternativas de login.
   - Templates de e-mail configurados (opcional).

5. **Modelagem e criação da tabela `moradores`**
   - Criada tabela `moradores` com os campos:
     - `id`, `nome`, `cpf`, `whatsapp`, `email`, `endereco`, `criado_em`
   - Aplicado RLS (Row Level Security).
   - Criadas as seguintes políticas de acesso:
     - `SELECT`: usuário só lê seu próprio registro.
     - `INSERT`: apenas usuários autenticados podem inserir.
     - `UPDATE`: usuário só atualiza seu próprio registro.

6. **Criação da tabela `solicitacoes`**
   - Criada tabela com campos:
     - `id`, `morador_id`, `descricao`, `tipo_entulho`, `endereco`, `fotos`, `status`, `criado_em`
   - Relacionamento com a tabela `moradores` via `morador_id`.
   - RLS ativado.
   - Políticas criadas:
     - `SELECT`: usuário vê apenas suas solicitações.
     - `INSERT`: permitido para usuários autenticados.
     - `UPDATE`: apenas o próprio morador pode atualizar suas solicitações (provisório, depois será refinado no dashboard).

7. **Configuração de Storage no Supabase**
   - Criado bucket público chamado `fotosrucopi`.
   - Definido limite de 2MB por imagem.
   - Política de `INSERT` criada para permitir apenas uploads de usuários autenticados (`auth.role() = 'authenticated'`).

8. **Integração do Supabase com os projetos Flutter**
   - Adicionada dependência `supabase_flutter: ^2.9.1` no `pubspec.yaml` do mobile.
   - Criado arquivo `.env` na raiz do projeto mobile com as chaves `SUPABASE_URL` e `SUPABASE_ANON_KEY`.
   - Instalado e configurado o pacote `flutter_dotenv` para carregar variáveis de ambiente.
   - Inicialização do Supabase no `main.dart` usando as variáveis do `.env`.
   - Implementada tela de login e cadastro, com fluxo correto de autenticação e criação de perfil do morador.
   - Testado cadastro, login e inserção de perfil, garantindo que o campo `id` do morador corresponde ao `auth.uid()` do usuário autenticado.
   - Ajustado código para garantir que o insert em `moradores` só ocorre após autenticação.
   - Adicionada tela de cadastro com campos completos e integração com Supabase.
   - Adicionada tela de login com redirecionamento e feedback ao usuário.

9. **Ajuste e criação de políticas RLS detalhadas**
   - Políticas de RLS da tabela `moradores` revisadas e atualizadas:
     - `SELECT`: `USING (auth.uid() = id)`
     - `INSERT`: `WITH CHECK (auth.uid() = id)`
     - `UPDATE`: `USING (auth.uid() = id)`
     - (Opcional) `DELETE`: `USING (auth.uid() = id)`
   - Políticas de RLS da tabela `solicitacoes` criadas:
     - `SELECT`: `USING (auth.uid() = morador_id)`
     - `INSERT`: `WITH CHECK (auth.uid() = morador_id)`
     - `UPDATE`: `USING (auth.uid() = morador_id)`
     - (Opcional) `DELETE`: `USING (auth.uid() = morador_id)`
   - Todas as políticas criadas via SQL Editor para garantir rastreabilidade e documentação.

10. **Testes e validação do fluxo completo**
    - Testado cadastro de usuário, login, criação de perfil e solicitação de coleta.
    - Validado que as políticas RLS estão funcionando corretamente, bloqueando acessos indevidos e permitindo apenas operações do próprio usuário.
    - Corrigido erro de Unauthorized após insert, ajustando o uso do método `.select()` e revisando as políticas de SELECT.

---

**Próxima Etapa:**
➡️ Início da integração do Supabase com o projeto `rucopi_dashboard` (painel administrativo web) e implementação das políticas de acesso para administradores e operadores.

---
