USE `sistema_vendas`;

-- Inserindo produtos iniciais
INSERT INTO `produtos` (`nome_produto`, `preco`, `quantidade_estoque`) 
VALUES ('Mouse para Computador', 89.90, 50),
       ('Teclado Mecânico', 199.90, 30);

-- Inserindo o cliente Carlos
INSERT INTO `clientes` (`nome`, `email`) 
VALUES ('Carlos', 'carlos@email.com');

-- Simulando uma venda inicial (Carlos comprando 1 Mouse)
INSERT INTO `vendas` (`cliente_id`, `produto_id`, `quantidade_vendida`)
VALUES (1, 1, 1);
