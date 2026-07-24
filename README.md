# ERP Loja Comercial - Banco de Dados Relacional (MySQL)

Este repositório contém a arquitetura completa do banco de dados para um sistema ERP de vendas comerciais. O projeto simula um ambiente de produção real, aplicando boas práticas de administração de banco de dados (DBA), automação via gatilhos, segurança de acessos, rotinas de tolerância a falhas e análise de dados financeira.

## 🚀 Funcionalidades do Projeto

- **Modelagem Relacional Avançada**: Estrutura otimizada com chaves primárias, estrangeiras e integridade referencial.
- **Automação de Estoque**: `Trigger` procedural que realiza a baixa automatizada de produtos e altera o status para 'Esgotado' em tempo real após cada venda.
- **Políticas de Segurança (Data Security)**: Criação de usuários específicos para regras de negócio (Gerente vs. Vendedor) utilizando o princípio do menor privilégio (`RBAC`).
- **Analytics & BI**: `View` customizada para cálculo automático de Custo Total, Faturamento e Lucro Líquido por transação.
- **Resiliência e Tolerância a Falhas**: Script de automação em lote (`.bat`) para a realização de backups físicos diários estruturados.

---

## 📐 Estrutura do Banco de Dados (Arquitetura)

O ecossistema é composto por 5 tabelas principais:
1. `clientes`: Cadastro unificado com restrição de unicidade no CPF.
2. `funcionarios`: Gerenciamento de equipe por cargos (`ENUM`).
3. `produtos`: Controle de preços de custo, venda e quantitativo em estoque.
4. `vendas`: Registro do cabeçalho do pedido (Vendedor, Cliente e Data).
5. `itens_venda`: Detalhamento dos produtos comprados, valores unitários e relacionamento N:M.

---

## 🗂️ Organização dos Scripts

O projeto foi segmentado para execução sequencial:

*   **`01_schema_erp.sql`**: Criação do banco de dados `erp_loja_comercial` e todas as tabelas com suas respectivas constraints.
*   **`02_seeds_e_automacao.sql`**: Carga de dados iniciais (incluindo o cliente Carlos e a vendedora Maria Silva) e o gatilho `tg_baixa_estoque_venda`.
*   **`03_security_erp.sql`**: Implementação das regras de segurança com privilégios de acesso controlados.
*   **`04_views_e_analytics.sql`**: Criação da tabela virtual `vw_painel_financeiro` para relatórios gerenciais de lucratividade.
*   **`05_testes_e_validacao.sql`**: Scripts manuais para testes unitários de auditoria de permissões e validação do gatilho de estoque.
*   **`06_rotina_backup.bat`**: Script de automação Windows para execução do utilitário `mysqldump` e estruturação da pasta corporativa de backups.

---

## 🛡️ Política de Backup e Continuidade de Negócio

Para mitigar riscos de perda de dados, o arquivo `06_rotina_backup.bat` executa as seguintes tarefas:
1. Verifica e cria automaticamente o diretório raiz seguro `C:\Backups_ERP`.
2. Captura a data do sistema operacional para rotular os arquivos de forma histórica (`ANO_MES_DIA`).
3. Executa o dump lógico estruturado de tabelas e dados via CLI.

### Agendamento Automatizado:
A rotina foi homologada no **Agendador de Tarefas do Windows** para execução diária persistente às **02:00 AM**, operando de forma silenciosa e automatizada em segundo plano no servidor de aplicação.

---

## 🛠️ Como Executar o Projeto Localmente

1. Instale o **MySQL Server** (Versão 8.0 ou superior).
2. Abra o terminal ou o seu client preferido (DBeaver, MySQL Workbench).
3. Execute os scripts SQL na ordem numérica do diretório.
4. Para a automação de backup, configure sua variável de senha no arquivo `.bat` e execute-o.

---
## 📈 Exemplo de Relatório Financeiro Gerado (View)

Ao consultar a view `vw_painel_financeiro`, o sistema entrega os dados consolidados prontos para ferramentas de BI:
```sql
SELECT * FROM vw_painel_financeiro;
```

| Nº Pedido | Vendedor | Cliente | Produto | Qtd | Custo Total (R$) | Faturamento (R$) | Lucro Líquido (R$) |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 1 | Maria Silva | Carlos Albuquerque | Mouse Gamer RGB | 1 | 45.00 | 89.90 | 44.90 |

---
