# 🛒 Mercado Fictício - Engenharia & Administração de Banco de Dados

Este repositório contém a infraestrutura, a inteligência procedural e a governança de dados para um sistema de mercado varejista. O objetivo deste projeto é demonstrar competências avançadas essenciais para um **DBA / Engenheiro de Dados**, com foco em automação, integridade transacional e portabilidade corporativa.

## 🛠️ Tecnologias e Ferramentas
* **SGBD:** PostgreSQL (v17)
* **Linguagem Procedural:** PL/pgSQL
* **Automação de Sistema Operacional:** Windows Batch (.bat) / Varredura Dinâmica
* **Interface de Gerenciamento:** DBeaver

---

## 🎯 Diferenciais Técnicos do Projeto (Foco DBA)

### 1. Script Raiz Autossuficiente e Idempotente (`main_deploy.sql`)
O deployment do schema foi projetado seguindo práticas rígidas de engenharia. O script principal executa um fluxo automatizado que limpa o ambiente de forma segura (`DROP TABLE IF EXISTS ... CASCADE`), recria a infraestrutura completa de tabelas, aplica chaves primárias/estrangeiras e compila as funções procedurais com **apenas um clique (`Alt + X`)**.

### 2. Automação de Negócios e Logística Inteligente (Triggers)
Para garantir consistência transacional direta no core do banco, eliminando latência na camada de aplicação, foi implementada a trigger **`trg_processa_item_venda`**:
* **Cálculo Dinâmico**: Atualiza em tempo real o valor acumulado no cabeçalho da venda (`vendas`) conforme novos itens são registrados.
* **Baixa de Estoque**: Deduz saldos físicos instantaneamente.
* **Logística Just-in-Time**: Avalia os níveis de segurança do inventário (unidades ≤ 10). Se atingido o ponto de pedido, gera automaticamente uma ordem de reabastecimento vinculada ao fornecedor correto do item, validando a existência de ordens pendentes para impedir redundância de dados.

### 3. Rotina de Backup Universal e Blindada (`rotina_backup.bat`)
A política de segurança e continuidade de negócios foi automatizada de forma dinâmica e portátil para o avaliador:
* **Garantia de Infraestrutura**: O script em lote valida e cria as pastas de armazenamento local automaticamente (`backups_mercado`) se não existirem no ambiente, tratando strings para evitar erros com espaços vazios.
* **Varredura Profunda Automática**: O script executa uma busca dinâmica nas raízes do sistema para localizar o utilitário `pg_dump.exe`. Ele detecta de forma automatizada se o PostgreSQL está rodando no Disco C:, no Disco D: ou em qualquer subpasta customizada, tornando-se 100% portátil para a máquina do recrutador.
* **Agendamento de Produção**: Configurado para orquestração nativa via Agendador de Tarefas do Windows (Task Scheduler) em horários de baixo pico (02:00 AM).

---

## 🏗️ Estrutura do Repositório
* 📂 **`main_deploy.sql`**: Script unificado de tabelas, triggers, carga inicial de dados e relatório automático de auditoria.
* 📂 **`rotina_backup.bat`**: Script de automação e execução em lote da política de backup com timestamping à prova de falhas.

---

## ⚡ Como Executar e Validar

1. No PostgreSQL, crie um banco de dados vazio chamado `mercado_ficticio`.
2. Abra o arquivo `main_deploy.sql` no DBeaver e execute-o integralmente pressionando **`Alt + X`**.
3. Acompanhe no console inferior o relatório de auditoria gerado de forma automática pela Trigger.
4. Para validar a rotina de infraestrutura de segurança, execute o arquivo `rotina_backup.bat` com um duplo clique. O dump de 14 KB do banco será gerado de forma automática na pasta criada pelo script.
