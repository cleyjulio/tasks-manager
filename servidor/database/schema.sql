-- Cria o banco se ainda não existir e o seleciona
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'TarefasDB')
    CREATE DATABASE TarefasDB;
GO

USE TarefasDB;
GO

-- Remove a tabela se já existir, para permitir recriar do zero
IF OBJECT_ID('dbo.Tarefas', 'U') IS NOT NULL
    DROP TABLE dbo.Tarefas;
GO

CREATE TABLE dbo.Tarefas (
    ID            INT IDENTITY(1,1)   NOT NULL,
    Titulo        VARCHAR(200)        NOT NULL,
    Descricao     VARCHAR(MAX)            NULL,
    -- valores possíveis: Não iniciada, Em andamento, Concluida
    Status        VARCHAR(20)         NOT NULL CONSTRAINT DF_Tarefas_Status      DEFAULT 'Não iniciada',
    -- escala 1 (baixa) a 5 (alta)
    Prioridade    INT                 NOT NULL CONSTRAINT DF_Tarefas_Prioridade  DEFAULT 1,
    DataCriacao   DATETIME            NOT NULL CONSTRAINT DF_Tarefas_DataCriacao DEFAULT GETDATE(),
    -- preenchido somente quando o status muda para 'Concluida'
    DataConclusao DATETIME                NULL,
    -- prazo para entrega; NULL significa sem prazo definido
    -- atrasada = DataPrazo < GETDATE() AND Status != 'Concluida'
    DataPrazo     DATETIME                NULL,

    CONSTRAINT PK_Tarefas PRIMARY KEY (ID),
    CONSTRAINT CK_Tarefas_Status     CHECK (Status IN ('Não iniciada', 'Em andamento', 'Concluida')),
    CONSTRAINT CK_Tarefas_Prioridade CHECK (Prioridade BETWEEN 1 AND 5)
);
GO

-- Dados de exemplo cobrindo os três status, prazos variados e tarefas atrasadas
INSERT INTO dbo.Tarefas (Titulo, Descricao, Status, Prioridade, DataCriacao, DataConclusao, DataPrazo)
VALUES
    (
        'Configurar ambiente de desenvolvimento',
        'Instalar Delphi, SQL Server, Boss e dependências do projeto.',
        'Concluida',
        3,
        DATEADD(DAY, -15, GETDATE()),
        DATEADD(DAY, -13, GETDATE()),
        DATEADD(DAY, -12, GETDATE())
    ),
    (
        'Modelar banco de dados',
        'Criar schema SQL com tabelas, constraints e dados de exemplo.',
        'Concluida',
        4,
        DATEADD(DAY, -14, GETDATE()),
        DATEADD(DAY, -12, GETDATE()),
        DATEADD(DAY, -11, GETDATE())
    ),
    (
        'Implementar camada de repositório',
        'Criar interface ITaskRepository e implementação SQL Server via ADO.',
        'Concluida',
        5,
        DATEADD(DAY, -12, GETDATE()),
        DATEADD(DAY, -9, GETDATE()),
        DATEADD(DAY, -8, GETDATE())
    ),
    (
        'Implementar serviço REST',
        'Criar endpoints GET, POST, PATCH, DELETE e /stats usando Horse.',
        'Concluida',
        5,
        DATEADD(DAY, -9, GETDATE()),
        DATEADD(DAY, -5, GETDATE()),
        DATEADD(DAY, -4, GETDATE())
    ),
    (
        'Implementar autenticação por API Key',
        'Adicionar middleware que valida o header X-API-Key em todas as rotas.',
        'Concluida',
        4,
        DATEADD(DAY, -8, GETDATE()),
        DATEADD(DAY, -6, GETDATE()),
        DATEADD(DAY, -5, GETDATE())
    ),
    (
        'Criar interface VCL',
        'Montar a tela principal com grid, formulário de cadastro e painel de estatísticas.',
        'Concluida',
        4,
        DATEADD(DAY, -6, GETDATE()),
        DATEADD(DAY, -3, GETDATE()),
        DATEADD(DAY, -2, GETDATE())
    ),
    (
        'Escrever documentação',
        'Preencher o README com pré-requisitos, arquitetura e exemplos de uso da API.',
        'Concluida',
        2,
        DATEADD(DAY, -4, GETDATE()),
        DATEADD(DAY, -2, GETDATE()),
        DATEADD(DAY, -1, GETDATE())
    ),
    (
        'Realizar testes de integração',
        'Testar todos os endpoints com cliente VCL e validar regras de negócio.',
        'Em andamento',
        5,
        DATEADD(DAY, -3, GETDATE()),
        NULL,
        DATEADD(DAY, 1, GETDATE())
    ),
    (
        'Revisar tratamento de erros',
        'Garantir que todos os endpoints retornam mensagens de erro claras e status HTTP corretos.',
        'Em andamento',
        3,
        DATEADD(DAY, -2, GETDATE()),
        NULL,
        DATEADD(DAY, 2, GETDATE())
    ),
    (
        'Otimizar queries SQL',
        'Analisar plano de execução das queries e adicionar índices se necessário.',
        'Não iniciada',
        2,
        DATEADD(DAY, -1, GETDATE()),
        NULL,
        DATEADD(DAY, 5, GETDATE())
    ),
    (
        'Implementar paginação na listagem',
        'Adicionar suporte a parâmetros page e pageSize no endpoint GET /tasks.',
        'Não iniciada',
        3,
        GETDATE(),
        NULL,
        DATEADD(DAY, 7, GETDATE())
    ),
    (
        'Adicionar filtros na listagem',
        'Permitir filtrar tarefas por status e prioridade via query string.',
        'Não iniciada',
        3,
        GETDATE(),
        NULL,
        DATEADD(DAY, 7, GETDATE())
    ),
    (
        'Criar tela de relatório',
        'Exibir gráfico de tarefas por status e histórico de conclusões.',
        'Não iniciada',
        2,
        GETDATE(),
        NULL,
        NULL
    ),
    (
        'Validar prazo no cadastro',
        'Impedir que o usuário informe uma data de prazo anterior à data atual.',
        'Não iniciada',
        4,
        DATEADD(DAY, -1, GETDATE()),
        NULL,
        DATEADD(DAY, -2, GETDATE())  -- prazo vencido, está atrasada
    ),
    (
        'Publicar servidor em produção',
        'Configurar servidor Windows com IIS ou serviço Windows para execução contínua.',
        'Não iniciada',
        5,
        DATEADD(DAY, -2, GETDATE()),
        NULL,
        DATEADD(DAY, -1, GETDATE())  -- prazo vencido, está atrasada
    );
GO

-- Confere o resultado, já indicando quais estão atrasadas
SELECT
    ID,
    Titulo,
    Status,
    Prioridade,
    CONVERT(VARCHAR(19), DataCriacao,   120) AS DataCriacao,
    CONVERT(VARCHAR(19), DataConclusao, 120) AS DataConclusao,
    CONVERT(VARCHAR(19), DataPrazo,     120) AS DataPrazo,
    CASE
        WHEN DataPrazo IS NOT NULL
         AND DataPrazo < GETDATE()
         AND Status != 'Concluida'
        THEN 'Sim'
        ELSE 'Nao'
    END AS Atrasada
FROM dbo.Tarefas
ORDER BY ID;
GO
