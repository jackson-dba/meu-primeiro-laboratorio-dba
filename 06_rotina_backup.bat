@echo off
:: ========================================================
:: SCRIPT DE BACKUP DIÁRIO AUTOMATIZADO - ERP COMERCIAL
:: DESENVOLVIDO POR: JACKSON (DBA)
:: ========================================================

:: Configuração de data para o nome do arquivo (Formato: ANO_MES_DIA)
set DATA=%date:~6,4%_%date:~3,2%_%date:~0,2%
set PASTA_BACKUP=C:\Backups_ERP

:: Criar a pasta de destino caso ela não exista no computador
if not exist "%PASTA_BACKUP%" mkdir "%PASTA_BACKUP%"

echo Iniciando o backup do banco erp_loja_comercial...

:: Executa o dump jogando o resultado para o arquivo final (.sql)
"C:\Program Files\MySQL\MySQL Server 8.0\bin\mysqldump.exe" -u root -padm1228 erp_loja_comercial > "%PASTA_BACKUP%\backup_erp_%DATA%.sql"

echo ========================================================
echo Backup concluído com sucesso em: %PASTA_BACKUP%\backup_erp_%DATA%.sql
echo ========================================================
pause
