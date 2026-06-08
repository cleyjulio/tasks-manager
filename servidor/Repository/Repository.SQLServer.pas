unit Repository.SQLServer;

{ATENÇÂO!!!
O ideal para o projeto seria o uso de FireDAC, porém minha licença do Delphi é
a Professional e o driver link do FireDAC para SQL Server (TFDPhysMSSQLDriverLink)
só está disponível nas edições Enterprise e Architect.
Para contornar o problema, adotei a conexão via TADOConnection (Data.Win.ADODB),
que acessa o SQL Server pelo provedor MSOLEDBSQL nativo do Windows,
sem dependências externas. }

interface

uses
  Repository.Interfaces,
  Model.Task,
  System.Generics.Collections,
  Data.Win.ADODB;

type
  TTaskRepositorySQL = class(TInterfacedObject, ITaskRepository)
  private
    FConnection: TADOConnection;
    procedure MapRow(const AQry: TADOQuery; const ATask: TTask);
    function GetByID(const AID: Integer): TTask;
  public
    constructor Create;
    destructor Destroy; override;
    function  GetAll: TObjectList<TTask>;
    function  Add(const ATask: TTask): TTask;
    procedure Update(const AID: Integer; const ATitulo, ADescricao: string; APrioridade: Integer; ADataPrazo: TDateTime);
    procedure UpdateStatus(const AID: Integer; const AStatus: string);
    procedure Delete(const AID: Integer);
    function  GetStats: TTaskStats;
  end;

implementation

uses
  Database.Connection,
  System.SysUtils,
  System.Variants,
  Data.DB;

const
  SQL_SELECT =
    'SELECT ID, Titulo, Descricao, Status, Prioridade, ' +
    'DataCriacao, DataConclusao, DataPrazo FROM Tarefas ';

constructor TTaskRepositorySQL.Create;
begin
  inherited;
  FConnection := CreateDBConnection;
end;

destructor TTaskRepositorySQL.Destroy;
begin
  FConnection.Free;
  inherited;
end;

procedure TTaskRepositorySQL.MapRow(const AQry: TADOQuery; const ATask: TTask);
begin
  ATask.ID := AQry.FieldByName('ID').AsInteger;
  ATask.Titulo := AQry.FieldByName('Titulo').AsString;
  ATask.Descricao := AQry.FieldByName('Descricao').AsString;
  ATask.Status := AQry.FieldByName('Status').AsString;
  ATask.Prioridade := AQry.FieldByName('Prioridade').AsInteger;
  ATask.DataCriacao := AQry.FieldByName('DataCriacao').AsDateTime;

  if AQry.FieldByName('DataConclusao').IsNull then
    ATask.DataConclusao := 0
  else
    ATask.DataConclusao := AQry.FieldByName('DataConclusao').AsDateTime;

  if AQry.FieldByName('DataPrazo').IsNull then
    ATask.DataPrazo := 0
  else
    ATask.DataPrazo := AQry.FieldByName('DataPrazo').AsDateTime;
end;

function TTaskRepositorySQL.GetByID(const AID: Integer): TTask;
var
  Qry: TADOQuery;
begin
  Qry := TADOQuery.Create(nil);
  try
    Qry.Connection := FConnection;
    Qry.SQL.Text   := SQL_SELECT + 'WHERE ID = :ID';
    Qry.Parameters.ParamByName('ID').Value := AID;
    Qry.Open;

    if Qry.IsEmpty then
      raise ETaskNotFound.CreateFmt('Tarefa com ID %d não encontrada.', [AID]);

    Result := TTask.Create;
    MapRow(Qry, Result);
  finally
    Qry.Free;
  end;
end;

function TTaskRepositorySQL.GetAll: TObjectList<TTask>;
var
  Qry:  TADOQuery;
  Task: TTask;
begin
  Result := TObjectList<TTask>.Create;
  try
    Qry := TADOQuery.Create(nil);
    try
      Qry.Connection := FConnection;
      Qry.SQL.Text   := SQL_SELECT + 'ORDER BY ID';
      Qry.Open;

      while not Qry.Eof do
      begin
        Task := TTask.Create;
        MapRow(Qry, Task);
        Result.Add(Task);
        Qry.Next;
      end;
    finally
      Qry.Free;
    end;
  except
    FreeAndNil(Result);
    raise;
  end;
end;

function TTaskRepositorySQL.Add(const ATask: TTask): TTask;
var
  Qry: TADOQuery;
  NewID: Integer;
begin
  Qry := TADOQuery.Create(nil);
  try
    Qry.Connection := FConnection;

    {OUTPUT INSERTED.ID retorna o ID gerado no mesmo comando, mais confiável que
    SCOPE_IDENTITY() com ADO, que perde o contexto de sessão entre queries}
    Qry.SQL.Text := '''
       INSERT INTO Tarefas (Titulo, Descricao, Prioridade, DataPrazo)
       OUTPUT INSERTED.ID VALUES (:Titulo, :Descricao, :Prioridade, :DataPrazo)
    ''';

    Qry.Parameters.ParamByName('Titulo').Value     := ATask.Titulo;
    Qry.Parameters.ParamByName('Descricao').Value  := ATask.Descricao;
    Qry.Parameters.ParamByName('Prioridade').Value := ATask.Prioridade;

    if ATask.DataPrazo = 0 then
      Qry.Parameters.ParamByName('DataPrazo').Value := Null
    else
      Qry.Parameters.ParamByName('DataPrazo').Value := ATask.DataPrazo;

    //Open porque OUTPUT faz o INSERT retornar um result set com o ID gerado
    Qry.Open;
    NewID := Qry.FieldByName('ID').AsInteger;
  finally
    Qry.Free;
  end;

  //retorna a tarefa completa, já com ID e DataCriacao preenchidos pelo banco
  Result := GetByID(NewID);
end;

procedure TTaskRepositorySQL.Update(const AID: Integer; const ATitulo, ADescricao: string; APrioridade: Integer; ADataPrazo: TDateTime);
var
  Qry: TADOQuery;
begin
  Qry := TADOQuery.Create(nil);
  try
    Qry.Connection := FConnection;
    Qry.SQL.Text := '''
      UPDATE Tarefas SET Titulo = :Titulo, Descricao = :Descricao,
      Prioridade = :Prioridade, DataPrazo = :DataPrazo WHERE ID = :ID
    ''';

    Qry.Parameters.ParamByName('Titulo').Value     := ATitulo;
    Qry.Parameters.ParamByName('Descricao').Value  := ADescricao;
    Qry.Parameters.ParamByName('Prioridade').Value := APrioridade;
    if ADataPrazo = 0 then
      Qry.Parameters.ParamByName('DataPrazo').Value := Null
    else
      Qry.Parameters.ParamByName('DataPrazo').Value := ADataPrazo;
    Qry.Parameters.ParamByName('ID').Value := AID;
    Qry.ExecSQL;

    if Qry.RowsAffected = 0 then
      raise ETaskNotFound.CreateFmt('Tarefa com ID %d não encontrada.', [AID]);
  finally
    Qry.Free;
  end;
end;

procedure TTaskRepositorySQL.UpdateStatus(const AID: Integer; const AStatus: string);
var
  Qry: TADOQuery;
begin
  Qry := TADOQuery.Create(nil);
  try
    Qry.Connection := FConnection;

    if AStatus = 'Concluida' then
      // grava a data de conclusão no momento exato em que o status muda
      Qry.SQL.Text :=
        'UPDATE Tarefas SET Status = :Status, DataConclusao = GETDATE() WHERE ID = :ID'
    else
      Qry.SQL.Text :=
        'UPDATE Tarefas SET Status = :Status, DataConclusao = NULL WHERE ID = :ID';

    Qry.Parameters.ParamByName('Status').Value := AStatus;
    Qry.Parameters.ParamByName('ID').Value     := AID;
    Qry.ExecSQL;

    if Qry.RowsAffected = 0 then
      raise ETaskNotFound.CreateFmt('Tarefa com ID %d não encontrada.', [AID]);
  finally
    Qry.Free;
  end;
end;

procedure TTaskRepositorySQL.Delete(const AID: Integer);
var
  Qry: TADOQuery;
begin
  Qry := TADOQuery.Create(nil);
  try
    Qry.Connection := FConnection;
    Qry.SQL.Text := 'DELETE FROM Tarefas WHERE ID = :ID';
    Qry.Parameters.ParamByName('ID').Value := AID;
    Qry.ExecSQL;

    if Qry.RowsAffected = 0 then
      raise ETaskNotFound.CreateFmt('Tarefa com ID %d não encontrada.', [AID]);
  finally
    Qry.Free;
  end;
end;

function TTaskRepositorySQL.GetStats: TTaskStats;
var
  Qry: TADOQuery;
begin
  Result := TTaskStats.Create;
  try
    Qry := TADOQuery.Create(nil);
    try
      Qry.Connection := FConnection;

      Qry.SQL.Text := 'SELECT COUNT(*) AS Total FROM Tarefas';
      Qry.Open;
      Result.Total := Qry.FieldByName('Total').AsInteger;
      Qry.Close;

      //CAST garante média com casas decimais em vez de inteiro arredondado
      Qry.SQL.Text := '''
        SELECT AVG(CAST(Prioridade AS FLOAT)) AS Media FROM Tarefas
        WHERE Status <> 'Concluida'
      ''';
      Qry.Open;
      if Qry.FieldByName('Media').IsNull then
        Result.MediaPrioridadeAtivas := 0
      else
        Result.MediaPrioridadeAtivas := Qry.FieldByName('Media').AsFloat;
      Qry.Close;

      Qry.SQL.Text := '''
        SELECT COUNT(*) AS Total FROM Tarefas WHERE Status = 'Concluida'
        AND DataConclusao >= DATEADD(DAY, -7, GETDATE())
      ''';

      Qry.Open;
      Result.Concluidas7Dias := Qry.FieldByName('Total').AsInteger;
      Qry.Close;

      Qry.SQL.Text := '''
        SELECT COUNT(*) AS Total FROM Tarefas WHERE DataPrazo IS NOT NULL
        AND DataPrazo < GETDATE() AND Status <> 'Concluida'
      ''';

      Qry.Open;
      Result.Atrasadas := Qry.FieldByName('Total').AsInteger;
      Qry.Close;
    finally
      Qry.Free;
    end;
  except
    FreeAndNil(Result);
    raise;
  end;
end;

end.
