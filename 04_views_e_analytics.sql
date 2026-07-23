USE `erp_loja_comercial`;

CREATE OR REPLACE VIEW vw_painel_financeiro AS
SELECT 
    v.id_venda AS 'Nº Pedido',
    f.nome AS 'Vendedor',
    c.nome AS 'Cliente',
    p.nome_produto AS 'Produto',
    iv.quantidade AS 'Qtd',
    (iv.quantidade * p.preco_custo) AS 'Custo Total (R$)',
    (iv.quantidade * iv.preco_unitario) AS 'Faturamento (R$)',
    ((iv.quantidade * iv.preco_unitario) - (iv.quantidade * p.preco_custo)) AS 'Lucro Líquido (R$)'
FROM `itens_venda` iv
INNER JOIN `vendas` v ON iv.venda_id = v.id_venda
INNER JOIN `produtos` p ON iv.produto_id = p.id_produto
INNER JOIN `clientes` c ON v.cliente_id = c.id_cliente
INNER JOIN `funcionarios` f ON v.funcionario_id = f.id_funcionario;
