USE `erp_loja_comercial`;

-- Carga Operacional
INSERT INTO `funcionarios` (`nome`, `cargo`, `data_contratacao`) VALUES ('Maria Silva', 'Vendedor', '2025-01-15'), ('João Souza', 'Gerente', '2024-06-10');
INSERT INTO `clientes` (`nome`, `cpf`, `email`, `telefone`) VALUES ('Carlos Albuquerque', '123.456.789-00', 'carlos@email.com', '(11) 98888-7777');
INSERT INTO `produtos` (`nome_produto`, `preco_custo`, `preco_venda`, `quantidade_estoque`, `status_estoque`) VALUES ('Mouse Gamer RGB', 45.00, 89.90, 50, 'Disponível'), ('Teclado Mecânico Pro', 110.00, 249.90, 30, 'Disponível');

-- Gatilho Automatizado de Estoque
DELIMITER $$
CREATE TRIGGER `tg_baixa_estoque_venda`
AFTER INSERT ON `itens_venda`
FOR EACH ROW
BEGIN
    UPDATE `produtos` SET `quantidade_estoque` = `quantidade_estoque` - NEW.`quantidade` WHERE `id_produto` = NEW.`produto_id`;
    UPDATE `produtos` SET `status_estoque` = 'Esgotado' WHERE `id_produto` = NEW.`produto_id` AND `quantidade_estoque` <= 0;
END$$
DELIMITER ;
