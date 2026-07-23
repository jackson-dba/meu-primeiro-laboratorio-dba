# 🛒 Sistema de Vendas & Governança de Dados (MySQL)

Este repositório apresenta um projeto corporativo completo de modelagem de banco de dados relacional e controle de privilégios de segurança de nível sênior (Data Governance), gerenciado de forma otimizada via **DBeaver**.

## 📊 Cenário de Negócio
O sistema foi desenvolvido para gerenciar as operações de vendas de periféricos de informática (Mouses e Teclados).
* **Cliente/Comprador cadastrado:** Carlos (`carlos@email.com`)
* **Produtos estruturados:** Mouse para Computador e Teclado Mecânico com controle dinâmico de estoque.

## 📁 Arquitetura e Organização do Projeto (Padrão de Mercado)
Seguindo as melhores práticas de Engenharia de Dados, o projeto foi segmentado de forma modular em scripts ordenados:

*   `01_schema.sql`: Definição da estrutura física de dados (DDL), chaves primárias e relacionamentos via chaves estrangeiras (*Foreign Keys*).
*   `02_seed.sql`: Carga inicial de dados de teste (DML) para simulação de vendas em ambiente de homologação.
*   `03_security.sql`: Implementação das políticas de controle de acesso ao banco (DCL).
*   `docker-compose.yml`: Arquivo de automação de infraestrutura preparado para inicialização rápida do banco de dados em contêineres Docker.

## 🔐 Política de Segurança & LGPD (Menor Privilégio)
Para garantir a integridade dos dados organizacionais, a funcionária **Maria (Vendedora)** recebeu um perfil estritamente restrito:
* Possui acesso apenas para consultar produtos, clientes e registrar novas linhas de vendas (`SELECT` e `INSERT`).
* Ela **não possui privilégios** para alterar estruturas de tabelas ou remover registros cruciais (`DROP`, `DELETE` ou `ALTER` bloqueados).

---
*Desenvolvido como projeto de portfólio para demonstração de competências como Administrador de Banco de Dados (DBA).*
