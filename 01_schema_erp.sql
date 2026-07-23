CREATE DATABASE IF NOT EXISTS `erp_loja_comercial`
DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;

USE `erp_loja_comercial`;

CREATE TABLE `clientes` (
  `id_cliente` INT NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(100) NOT NULL,
  `cpf` VARCHAR(14) NOT NULL UNIQUE,
  `email` VARCHAR(100) DEFAULT NULL,
  `telefone` VARCHAR(20) DEFAULT NULL,
  PRIMARY KEY (`id_cliente`)
) ENGINE=InnoDB;

CREATE TABLE `funcionarios` (
  `id_funcionario` INT NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(100) NOT NULL,
  `cargo` ENUM('Vendedor', 'Gerente') NOT NULL,
  `data_contratacao` DATE NOT NULL,
  PRIMARY KEY (`id_funcionario`)
) ENGINE=InnoDB;

CREATE TABLE `produtos` (
  `id_produto` INT NOT NULL AUTO_INCREMENT,
  `nome_produto` VARCHAR(100) NOT NULL,
  `preco_custo` DECIMAL(10,2) NOT NULL,
  `preco_venda` DECIMAL(10,2) NOT NULL,
  `quantidade_estoque` INT NOT NULL DEFAULT 0,
  `status_estoque` ENUM('Disponível', 'Esgotado') NOT NULL DEFAULT 'Disponível',
  PRIMARY KEY (`id_produto`)
) ENGINE=InnoDB;

CREATE TABLE `vendas` (
  `id_venda` INT NOT NULL AUTO_INCREMENT,
  `funcionario_id` INT NOT NULL,
  `cliente_id` INT NOT NULL,
  `data_venda` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `valor_total_venda` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  PRIMARY KEY (`id_venda`),
  CONSTRAINT `fk_vendas_funcionarios` FOREIGN KEY (`funcionario_id`) REFERENCES `funcionarios` (`id_funcionario`),
  CONSTRAINT `fk_vendas_clientes` FOREIGN KEY (`cliente_id`) REFERENCES `clientes` (`id_cliente`)
) ENGINE=InnoDB;

CREATE TABLE `itens_venda` (
  `id_item` INT NOT NULL AUTO_INCREMENT,
  `venda_id` INT NOT NULL,
  `produto_id` INT NOT NULL,
  `quantidade` INT NOT NULL,
  `preco_unitario` DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (`id_item`),
  CONSTRAINT `fk_itens_vendas` FOREIGN KEY (`venda_id`) REFERENCES `vendas` (`id_venda`) ON DELETE CASCADE,
  CONSTRAINT `fk_itens_produtos` FOREIGN KEY (`produto_id`) REFERENCES `produtos` (`id_produto`)
) ENGINE=InnoDB;
