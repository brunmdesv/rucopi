-- Adicionar coluna nome_morador na tabela solicitacoes
ALTER TABLE solicitacoes 
ADD COLUMN nome_morador TEXT;

-- Comentário para documentar a coluna
COMMENT ON COLUMN solicitacoes.nome_morador IS 'Nome do morador que fez a solicitação'; 