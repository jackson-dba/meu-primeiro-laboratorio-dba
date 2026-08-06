@echo off
setlocal enabledelayedexpansion

:: =========================================================================
:: PRONTO: MERCADO FICTÍCIO (AUTOMAÇÃO DE BACKUP HÍBRIDA - DBA)
:: DESCRIÇÃO: SCRIPT UNIVERSAL PORTÁVEL (SEM LETRA DE DISCO FIXA) COM LOGS
:: =========================================================================

:: 1. CONFIGURAÇÃO DE DIRETÓRIOS E BANCO (CAMINHO RELATIVO DO DISCO ATUAL)
:: %~dp0 identifica automaticamente onde o script está rodando (Ex: C:\pasta\ ou D:\teste\)
set "JALON_DIR=%~dp0dpBackups_mercado"
set "DATABASE=mercado_ficticio"

echo ===================================================
echo          PARAMETROS DE ACESSO AO POSTGRES
echo ===================================================

:: Pergunta o usuário. Se deixar em branco e apertar Enter, o padrão será 'postgres'
set "USER="
set /p "USER=Digite o usuario do banco [Padrao: postgres]: "
if "%USER%"=="" set "USER=postgres"

:: Pergunta a senha de forma interativa
echo Digite a senha do banco de dados:
set /p PGPASSWORD=
echo ===================================================

:: 2. GARANTIA DE INFRAESTRUTURA
if not exist "%JALON_DIR%" (
    echo [NÍVEL DBA] Criando pasta de destino automaticamente...
    md "%JALON_DIR%"
)

:: Cria ou limpa o arquivo de relatório de hoje
set "LOG_FILE=%JALON_DIR%\relatorio_backup.txt"
echo =================================================== > "%LOG_FILE%"
echo RELATÓRIO DE EXECUÇÃO DO BACKUP - %DATE% %TIME% >> "%LOG_FILE%"
echo =================================================== >> "%LOG_FILE%"


:: 3. DETECÇÃO AUTOMÁTICA ULTRA RESILIENTE DO AMBIENTE
echo [NÍVEL DBA] Localizando ambiente do PostgreSQL...

set "PG_EXEC="
set "DOCKER_MODE=N"

:: Passo A: Procura o pg_dump tradicional instalado no Windows
for /d %%I in ("C:\Program Files\PostgreSQL\*") do (
    if exist "%%I\bin\pg_dump.exe" set "PG_EXEC=%%I\bin\pg_dump.exe"
)
if not defined PG_EXEC (
    for /d %%I in ("C:\Arquivos de Programas\PostgreSQL\*") do (
        if exist "%%I\bin\pg_dump.exe" set "PG_EXEC=%%I\bin\pg_dump.exe"
    )
)
if not defined PG_EXEC (
    for /d %%I in ("C:\Program Files (x86)\PostgreSQL\*") do (
        if exist "%%I\bin\pg_dump.exe" set "PG_EXEC=%%I\bin\pg_dump.exe"
    )
)

:: Passo B: Se nao achou local, busca no Docker de forma genérica pela imagem usada (ancestor)
if not defined PG_EXEC (
    where docker >nul 2>nul
    if %errorlevel% equ 0 (
        :: Filtra por containers gerados a partir de qualquer versão da imagem oficial do postgres
        for /f "tokens=*" %%A in ('docker ps -a --filter "ancestor=postgres" --format "{{.Names}}" 2^>nul') do (
            set "PG_EXEC=%%A"
            set "DOCKER_MODE=S"
        )
    )
)

:: Passo C: Se mesmo assim nao achou nada, gera erro no relatório e fecha
if not defined PG_EXEC (
    echo [ERRO] PostgreSQL nao localizado no sistema. >> "%LOG_FILE%"
    cls
    echo ===================================================
    echo             FALHA GRAVE NO PROCESSO
    echo ===================================================
    echo O script nao encontrou o PostgreSQL no Windows nem no Docker.
    echo O motivo detalhado foi salvo no relatorio em:
    echo "%LOG_FILE%"
    echo ===================================================
    pause
    exit /b
)


:: 4. EXECUÇÃO DO BACKUP CONFORME O MODO ENCONTRADO
if "%DOCKER_MODE%"=="S" (
    echo [SUCESSO] Usando ambiente Docker (Container: %PG_EXEC%)
    echo [INFO] Garantindo inicializacao do container...
    docker start %PG_EXEC% >nul 2>nul
    timeout /t 2 >nul
    
    :: Executa o backup de dentro do Docker jogando para a pasta local relativizada
    docker exec -t %PG_EXEC% pg_dump -U %USER% %DATABASE% > "%JALON_DIR%\backup_%DATABASE%.sql" 2>> "%LOG_FILE%"
) else (
    echo [SUCESSO] Usando utilitário local do Windows.
    "%PG_EXEC%" -U %USER% -F c -b -v -f "%JALON_DIR%\backup_%DATABASE%.backup" %DATABASE% 2>> "%LOG_FILE%"
)


:: 5. VERIFICAÇÃO FINAL E EXIBIÇÃO DO RELATÓRIO
if %errorlevel% equ 0 (
    echo STATUS: BACKUP REALIZADO COM SUCESSO! >> "%LOG_FILE%"
    set "RESULTADO=SUCESSO"
) else (
    echo STATUS: ERRO AO EXECUTAR O COMANDO PG_DUMP. >> "%LOG_FILE%"
    set "RESULTADO=ERRO"
)

cls
echo ===================================================
echo          EXECUÇÃO FINALIZADA (%RESULTADO%)
echo ===================================================
echo Visualizando o relatorio gerado (Feche o bloco de notas para encerrar):
echo.

:: Abre o relatório automaticamente na tela para o usuário ler antes do script fechar
notepad "%LOG_FILE%"

echo ===================================================
echo Script encerrado de forma segura.
pause
