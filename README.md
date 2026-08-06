### 🛒 Mercado Fictício - Engenharia & Administração de Banco de Dados

Este repositório contém a infraestrutura, a inteligência procedural e a governança de dados para um sistema de mercado varejista. O objetivo deste projeto é demonstrar competências avançadas essenciais para um **DBA / Engenheiro de Dados**, com foco em automação, integridade transacional e portabilidade corporativa. 

### 🛠️ Tecnologias e Ferramentas

* **SGBD:** PostgreSQL (Compatibilidade Dinâmica e Universal via Curinga *)
* **Linguagem Procedural:** PL/pgSQL
* **Automação de Sistema Operacional:** Windows Batch (.bat) com Lógica Relativa (%~dp0)
* **Conteinerização:** Docker / Docker Desktop (Filtro por ancestor)
* **Interface de Gerenciamento:** DBeaver

### 🚀 Diferenciais Técnicos do Projeto (Foco DBA)

### 1. Script Raiz Autossuficiente e Idempotente (main_deploy.sql)

O deployment do schema foi projetado seguindo práticas rígidas de engenharia. O script principal executa um fluxo automatizado que limpa o ambiente de forma segura (DROP TABLE IF EXISTS ... CASCADE), recria a infraestrutura completa de tabelas, aplica chaves primárias/estrangeiras e compila as funções procedurais com **apenas um clique (Alt + X)**. 

### 2. Automação de Negócios e Logística Inteligente (Triggers)

Para garantir consistência transacional direto no core do banco, eliminando latência na camada de aplicação, foi implementada a trigger trg_processa_item_venda: 

* **Cálculo Dinâmico:** Atualiza em tempo real o valor acumulado no cabeçalho da venda (vendas) conforme novos itens são registrados.
* **Baixa de Estoque:** Deduz saldos físicos instantaneamente.
* **Logística Just-in-Time:** Avalia os níveis de segurança do inventário (unidades < 10). Se atingido o ponto de pedido, dispara automaticamente uma ordem de reabastecimento vinculada ao fornecedor correto do item, validando a existência de ordens pendentes para impedir redundância de dados.

### 3. Rotina de Backup Híbrida, Resiliente e Universal (rotina_backup.bat)

A política de segurança e continuidade de negócios foi totalmente reformulada de forma dinâmica com foco em resiliência industrial, blindagem e portabilidade para o avaliador: 

* **Varredura Profunda com Caractere Curinga (*)**: O script executa uma busca dinâmica nas raízes do sistema utilizando máscaras de texto (curingas). Isso permite localizar o utilitário pg_dump.exe de forma agnóstica, tornando a rotina totalmente indiferente à versão do PostgreSQL instalada nativamente no Windows (seja v13, v15, v17, etc., no Disco C:, Disco D: ou em subpastas customizadas), sendo 100% portátil para a máquina do recrutador.
* **Filtro Universal de Containers**: No modo Docker, identifica o container correto inspecionando a árvore de imagens (ancestor=postgres), eliminando falhas por nomes de containers customizados.
* **Auto-Start de Infraestrutura**: Caso o banco esteja no Docker e o container esteja desligado/inativo, o script realiza o boot automático da estrutura antes de disparar o pg_dump.
* **Segurança de Credenciais (No Hardcoded)**: O usuário e a senha são solicitados de forma interativa e dinâmica na execução, aceitando valores padrões automaticamente ao pressionar Enter.
* **Garantia de Infraestrutura & Logs Relativos**: Sem letras de disco rígidas. O script calcula caminhos relativos (%~dp0), trata strings para evitar erros com espaços vazios e cria/valida automaticamente as pastas de armazenamento local (backups_mercado) e relatórios de auditoria exatamente na mesma pasta de execução com *timestamping* à prova de falhas. Ele gerencia erros do utilitário (2>>) e força a abertura de um relatório detalhado no Bloco de Notas antes de encerrar o terminal.
* **Agendamento de Produção**: Configurado para orquestração nativa via **Agendador de Tarefas do Windows (Task Scheduler)** em horários de baixo pico (02:00 AM).

### 📁 Estrutura do Repositório

text

├── 📂 automacoes_infra/
│   ├── 📂 backup mercado/
│   └── 📄 rotina_backup.bat
├── 📂 scripts/
│   └── 📄 main_deploy.sql
├── 📄 LICENSE
└── 📄 README.md

Use code with caution.

ArquivoDescrição
****
main_deploy.sqlScript unificado de tabelas, triggers, carga inicial de dados e relatório automático de auditoria.
****
rotina_backup.batScript de automação e execução em lote da política de backup híbrida com timestamping à prova de falhas e tratamento de erros.

### ⚡ Como Executar e Validar

Siga os passos abaixo para implantar a infraestrutura e testar os mecanismos de automação: 

1. **Preparação do Ambiente:** No PostgreSQL, crie um banco de dados vazio chamado mercado_ficticio.
2. **Deploy Automatizado:** Abra o arquivo main_deploy.sql no **DBeaver** e execute-o integralmente pressionando **Alt + X**.
3. **Auditoria Interna:** Acompanhe no console inferior o relatório de auditoria gerado de forma automática pela Trigger incorporada ao script.
4. **Validação da Rotina de Resiliência (Backup):** Para validar a rotina de infraestrutura de segurança, execute o arquivo rotina_backup.bat com um duplo clique. O dump de aproximadamente 14 KB do banco será gerado de forma automática dentro da pasta criada dinamicamente pelo próprio script.
