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

### 2. Estrutura de Navegação
- [ ] Definir rotas principais do dashboard (login, lista de solicitações, detalhes, etc)
- [x] Implementar navegação segura (logout, proteção de rotas)

### 3. Listagem de Solicitações
- [x] Criar tela inicial com listagem de solicitações de coleta
- [x] Buscar dados da tabela `solicitacoes` no Supabase
- [x] Exibir campos principais: descrição, status, data, morador, etc
- [x] Permitir que administradores/operadores vejam todas as solicitações (ajuste de RLS)
- [ ] Implementar filtros por status, data, bairro, etc
- [ ] Permitir visualização dos detalhes de cada solicitação (incluindo fotos)

### 4. Gestão de Solicitações
- [ ] Permitir atualização do status da solicitação (pendente, em andamento, concluída)
- [ ] (Opcional) Permitir atribuição de solicitações a equipes

### 5. Relatórios e Análises
- [ ] Criar relatórios básicos (número de solicitações por período, status, bairro)
- [ ] Implementar exportação de relatórios (CSV/PDF)

### 6. Interface e Usabilidade
- [ ] Garantir responsividade e boa experiência de uso
- [ ] Adicionar feedbacks visuais (loadings, mensagens de sucesso/erro)

---

## Observação Final
- O checklist pode ser atualizado conforme novas necessidades surgirem durante o desenvolvimento da Fase 2. 