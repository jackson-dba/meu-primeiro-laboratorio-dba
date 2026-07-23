USE `sistema_vendas`;

-- Criação da usuária Maria para acesso seguro
CREATE USER IF NOT EXISTS 'maria'@'%' IDENTIFIED BY 'SenhaSeguraMaria123!';

-- Concedendo privilégios estritos de menor acesso (Data Governance)
GRANT SELECT ON `sistema_vendas`.`produtos` TO 'maria'@'%';
GRANT SELECT ON `sistema_vendas`.`clientes` TO 'maria'@'%';
GRANT INSERT, SELECT ON `sistema_vendas`.`vendas` TO 'maria'@'%';

-- Aplicando as novas permissões no servidor
FLUSH PRIVILEGES;
