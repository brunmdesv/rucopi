# ✅ Checklist Fase 2 – Dashboard Administrativo (rucopi)

## Observações Gerais
- O dashboard **não terá link de cadastro**. O(s) usuário(s) administrador(es) devem ser criados manualmente no painel do Supabase.
- Apenas usuários autenticados poderão acessar o dashboard.

---

## Checklist Detalhado

### 1. Autenticação e Login
- [x] Criar tela de login para o dashboard (usuário e senha via Supabase Auth)
- [x] Implementar validação de login e feedback de erro
- [x] Garantir que apenas usuários autenticados acessem o dashboard
- [x] (Opcional) Implementar lógica para diferenciar administradores de operadores (campo extra no perfil, role, etc)
- [x] Testar login com usuário criado manualmente no Supabase
- [x] Criar sistema de tema e cores no dashboard igual ao do mobile (arquivos app_styles.dart e theme_provider.dart)
- [x] Integrar ThemeProvider no main.dart do dashboard, usando provider e Consumer
- [x] Recriar a tela de login do dashboard igual à do mobile, usando o novo sistema de tema e estilos

### 2. Estrutura de Navegação
- [x] Definir rotas principais do dashboard (login, dashboard inicial, lista de solicitações, detalhes, etc)
- [x] Implementar navegação segura (logout, proteção de rotas)

### 3. Listagem de Solicitações
- [x] Criar tela inicial com listagem de solicitações de coleta
- [x] Buscar dados da tabela `solicitacoes` no Supabase
- [x] Exibir campos principais: descrição, status, data, morador, etc
- [x] Permitir que administradores/operadores vejam todas as solicitações (ajuste de RLS)
- [x] Adicionar coluna `nome_morador` na tabela `solicitacoes` e atualizar código para exibir nome do morador
- [ ] Implementar filtros por status, data, bairro, etc
- [x] Permitir visualização dos detalhes de cada solicitação (incluindo fotos)

### 4. Gestão de Solicitações
- [ ] Permitir atualização do status da solicitação (pendente, em andamento, concluída)
- [ ] (Opcional) Permitir atribuição de solicitações a equipes

### 5. Relatórios e Análises
- [ ] Criar relatórios básicos (número de solicitações por período, status, bairro)
- [ ] Implementar exportação de relatórios (CSV/PDF)

### 6. Interface e Usabilidade
- [x] Criar dashboard inicial moderna e bonita, com cards de totais e atalhos úteis
- [x] Melhorar layout dos cards de solicitações com informações organizadas (status, data/hora, morador, endereço, descrição, tipo de entulho)
- [x] Implementar visualização em tabela moderna e responsiva para melhor organização das solicitações
- [x] Padronizar tamanhos de texto entre dashboard_home_page.dart e solicitacoes_page.dart para melhor legibilidade
- [x] Modificar seção "Solicitações Recentes" para exibir até 3 solicitações pendentes mais antigas com botão "Ver mais X solicitações pendentes"
- [ ] Garantir responsividade e boa experiência de uso
- [ ] Adicionar feedbacks visuais (loadings, mensagens de sucesso/erro)
- [x] Implementação da tela inicial do rucopi_mobile com AppBar, saudação, card de solicitações e botão de solicitar coleta.
- [x] Adicionar opção "Perfil" no menubar/sidebar e criar tela em branco (perfil_usuario_page.dart)

### 7. Correções no Aplicativo Mobile
- [x] Corrigir problema de autenticação no rucopi_mobile - aplicativo estava iniciando em tela protegida sem verificar autenticação
- [x] Implementar AuthWrapper para verificar estado de autenticação automaticamente
- [x] Configurar redirecionamento automático para tela de login quando usuário não autenticado
- [x] Padronizar todos os status de solicitação para: pendente, agendada, coletando, concluido, cancelado, em todos os pontos do código e exibição (mobile e dashboard)

---

## Observação Final
- O checklist pode ser atualizado conforme novas necessidades surgirem durante o desenvolvimento da Fase 2. 