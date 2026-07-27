@echo off
setlocal enabledelayedexpansion
:: ====================================================================
:: PROJETO: MERCADO FICTÍCIO (AUTOMAÇÃO DE BACKUP BLINDADA - DBA)
:: DESCRIÇÃO: SCRIPT PORTÁTIL INDESTRUTÍVEL PARA INSTALAÇÕES REAIS
:: ====================================================================

:: 1. CONFIGURAÇÃO DE DIRETÓRIOS E BANCO (NOME DA PASTA SEM ESPAÇOS)
set JALON_DIR="%~dp0backups_mercado"
set DATABASE=mercado_ficticio
set USER=postgres
set PGPASSWORD=adm1228

:: 2. GARANTIA DE INFRAESTRUTURA
if not exist !JALON_DIR! (
    echo [NÍVEL DBA] Criando pasta de destino automaticamente...
    md !JALON_DIR!
)

:: 3. DETECÇÃO AUTOMÁTICA E DINÂMICA DO PG_DUMP
echo [NÍVEL DBA] Localizando utilitario pg_dump no sistema...
set "PG_EXEC="

for /f "delims=" %%i in ('where pg_dump.exe 2^>nul') do set "PG_EXEC="%%i""

if not defined PG_EXEC (
    for %%d in (C D) do (
        if exist "%%d:\" (
            for /f "delims=" %%f in ('dir /b /s "%%d:\pg_dump.exe" 2^>nul') do (
                set "PG_EXEC="%%f""
                goto :encontrado
            )
        )
    )
)

:encontrado
if not defined PG_EXEC (
    echo [ERRO CRÍTICO] pg_dump.exe nao encontrado no sistema.
    goto :fim
)

echo [SUCESSO] Utilitario encontrado em: !PG_EXEC!

:: 4. GERAÇÃO DO TIMESTAMP BLINDADO (REMOVE ESPAÇOS, DOIS PONTOS E BARRAS)
set DATA=%date:~-4%-%date:~3,2%-%date:~0,2%
set HORA=%time:~0,2%-%time:~3,2%
set HORA=!HORA: =0!
set HORA=!HORA::=-!
set HORA=!HORA:/=-!
set ARQUIVO_FINAL=%DATABASE%_%DATA%_%HORA%.sql

:: 5. EXECUÇÃO DO BACKUP COM ASPAS DE SEGURANÇA REFORÇADAS
echo [NÍVEL DBA] Iniciando extracao de dados do banco %DATABASE%...
!PG_EXEC! -U %USER% -d %DATABASE% -F p -f "!JALON_DIR!\%ARQUIVO_FINAL%"

if !errorlevel! equ 0 (
    echo [SUCESSO] Backup gravado com exito em: !JALON_DIR!\%ARQUIVO_FINAL%
) else (
    echo [ERRO] Ocorreu uma falha durante a execucao do pg_dump.
)

:fim
pause
