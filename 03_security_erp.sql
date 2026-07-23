USE `erp_loja_comercial`;

CREATE USER IF NOT EXISTS 'joao_gerente'@'localhost' IDENTIFIED BY 'GerenteForte2026!';
CREATE USER IF NOT EXISTS 'maria_vendedora'@'localhost' IDENTIFIED BY 'VendaSegura2026!';

GRANT SELECT, INSERT, UPDATE, DELETE ON `erp_loja_comercial`.* TO 'joao_gerente'@'localhost';
GRANT SELECT ON `erp_loja_comercial`.`produtos` TO 'maria_vendedora'@'localhost';
GRANT SELECT ON `erp_loja_comercial`.`clientes` TO 'maria_vendedora'@'localhost';
GRANT SELECT ON `erp_loja_comercial`.`funcionarios` TO 'maria_vendedora'@'localhost';
GRANT SELECT, INSERT ON `erp_loja_comercial`.`vendas` TO 'maria_vendedora'@'localhost';
GRANT SELECT, INSERT ON `erp_loja_comercial`.`itens_venda` TO 'maria_vendedora'@'localhost';

FLUSH PRIVILEGES;
