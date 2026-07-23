USE `erp_loja_comercial`;

-- ==========================================
-- TESTE 1: VALIDAÇÃO DA TRIGGER DE ESTOQUE
-- ==========================================

-- 1.1 Consultar o estoque atual do Mouse Gamer (Deve ser 50 unidades)
SELECT nome_produto, quantidade_estoque, status_estoque 
FROM produtos 
WHERE id_produto = 1;

-- 1.2 Simular uma venda do cliente Carlos (ID 1) feita pela Maria (ID 1)
INSERT INTO vendas (funcionario_id, cliente_id, valor_total_venda) 
VALUES (1, 1, 89.90);

-- 1.3 Inserir o item da venda (1 Mouse Gamer RGB)
-- Obs: Use o ID da venda gerado pelo passo anterior (geralmente ID 1 se for o primeiro teste)
INSERT INTO itens_venda (venda_id, produto_id, quantidade, preco_unitario) 
VALUES (1, 1, 1, 89.90);

-- 1.4 Verificar se a TRIGGER reduziu o estoque para 49 automaticamente
SELECT nome_produto, quantidade_estoque, status_estoque 
FROM produtos 
WHERE id_produto = 1;


-- ==========================================
-- TESTE 2: AUDITORIA DE SEGURANÇA (PERMISSÕES)
-- ==========================================

-- Como Administrador/DBA, você pode rodar este comando para validar 
-- se os acessos restritos da vendedora Maria foram aplicados corretamente:
SHOW GRANTS FOR 'maria_vendedora'@'localhost';
