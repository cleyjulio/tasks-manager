unit Controller.Tasks;

interface

type
  TTasksController = class
  public
    class procedure Register;
  end;

implementation

uses
  Horse,
  Winapi.ActiveX,
  Config,
  Repository.Factory,
  Repository.Interfaces,
  Model.Task,
  System.JSON,
  System.SysUtils,
  System.DateUtils,
  System.Generics.Collections;

function DateToISO(const ADate: TDateTime): string;
begin
  Result := FormatDateTime('yyyy-mm-dd"T"hh:nn:ss', ADate);
end;

function TaskToJSON(const ATask: TTask): TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('id', TJSONNumber.Create(ATask.ID));
  Result.AddPair('titulo', ATask.Titulo);
  Result.AddPair('descricao', ATask.Descricao);
  Result.AddPair('status', ATask.Status);
  Result.AddPair('prioridade', TJSONNumber.Create(ATask.Prioridade));
  Result.AddPair('dataCriacao', DateToISO(ATask.DataCriacao));

  if ATask.DataConclusao = 0 then
    Result.AddPair('dataConclusao', TJSONNull.Create)
  else
    Result.AddPair('dataConclusao', DateToISO(ATask.DataConclusao));

  if ATask.DataPrazo = 0 then
    Result.AddPair('dataPrazo', TJSONNull.Create)
  else
    Result.AddPair('dataPrazo', DateToISO(ATask.DataPrazo));

  Result.AddPair('atrasada', TJSONBool.Create(ATask.Atrasada));
end;

procedure SendError(const Res: THorseResponse; const AStatus: Integer; const AMsg: string);
var
  JSON: TJSONObject;
begin
  JSON := TJSONObject.Create;
  try
    JSON.AddPair('erro', AMsg);
    Res.Status(AStatus).ContentType('application/json').Send(JSON.ToJSON);
  finally
    JSON.Free;
  end;
end;

function StatusValido(const AStatus: string): Boolean;
begin
  Result := (AStatus = 'Não iniciada') or
            (AStatus = 'Em andamento') or
            (AStatus = 'Concluida');
end;

//middleware de segurança

procedure ValidateApiKey(Req: THorseRequest; Res: THorseResponse; Next: TNextProc);
begin
  if Req.Headers['X-API-Key'] <> TConfig.ApiKey then
  begin
    SendError(Res, 401, 'API Key inválida ou ausente.');
    Exit; //não chama Next
  end;
  Next;
end;

//handlers das rotas

procedure HandleGetAll(Req: THorseRequest; Res: THorseResponse; Next: TNextProc);
var
  Repo: ITaskRepository;
  Tasks: TObjectList<TTask>;
  Arr: TJSONArray;
  Task: TTask;
begin
  try
    Repo := TTaskRepositoryFactory.CreateRepository;
    Tasks := Repo.GetAll;
    try
      Arr := TJSONArray.Create;
      try
        for Task in Tasks do
          Arr.Add(TaskToJSON(Task));
        Res.Status(200).ContentType('application/json').Send(Arr.ToJSON);
      finally
        Arr.Free;
      end;
    finally
      Tasks.Free;
    end;
  except
    on E: Exception do
      SendError(Res, 500, 'Erro interno: ' + E.Message);
  end;
end;

procedure HandleCreate(Req: THorseRequest; Res: THorseResponse; Next: TNextProc);
var
  Repo: ITaskRepository;
  Body: TJSONObject;
  PrazoVal: TJSONValue;
  NewTask: TTask;
  Created: TTask;
  JSON: TJSONObject;
begin
  try
    Body := TJSONObject.ParseJSONValue(Req.Body) as TJSONObject;
    if not Assigned(Body) then
    begin
      SendError(Res, 400, 'JSON inválido no corpo da requisição.');
      Exit;
    end;
    try
      NewTask := TTask.Create;
      try
        NewTask.Titulo := Body.GetValue<string>('titulo', '');
        if NewTask.Titulo.Trim.IsEmpty then
        begin
          SendError(Res, 400, 'O campo "titulo" é obrigatório.');
          Exit;
        end;

        NewTask.Descricao := Body.GetValue<string>('descricao', '');
        NewTask.Prioridade := Body.GetValue<Integer>('prioridade', 1);

        //dataPrazo é opcional
        PrazoVal := Body.GetValue('dataPrazo');
        if (not Assigned(PrazoVal)) or (PrazoVal is TJSONNull) then
          NewTask.DataPrazo := 0
        else
          NewTask.DataPrazo := ISO8601ToDate(PrazoVal.Value, False);

        Repo := TTaskRepositoryFactory.CreateRepository;
        Created := Repo.Add(NewTask);
        try
          JSON := TaskToJSON(Created);
          try
            Res.Status(201).ContentType('application/json').Send(JSON.ToJSON);
          finally
            JSON.Free;
          end;
        finally
          Created.Free;
        end;
      finally
        NewTask.Free;
      end;
    finally
      Body.Free;
    end;
  except
    on E: EConvertError do
      SendError(Res, 400, 'Formato de data inválido. Use o padrão: yyyy-mm-ddThh:nn:ss');
    on E: Exception do
      SendError(Res, 500, 'Erro interno: ' + E.Message);
  end;
end;

procedure HandleUpdate(Req: THorseRequest; Res: THorseResponse; Next: TNextProc);
var
  Repo: ITaskRepository;
  Body: TJSONObject;
  ID: Integer;
  PrazoVal: TJSONValue;
  DataPrazo: TDateTime;
  NewStatus: string;
  HasTitulo, HasStatus: Boolean;
begin
  try
    if not TryStrToInt(Req.Params['id'], ID) then
    begin
      SendError(Res, 400, 'ID inválido.');
      Exit;
    end;

    Body := TJSONObject.ParseJSONValue(Req.Body) as TJSONObject;
    if not Assigned(Body) then
    begin
      SendError(Res, 400, 'JSON inválido no corpo da requisição.');
      Exit;
    end;
    try
      HasTitulo := Assigned(Body.GetValue('titulo'));
      HasStatus := Assigned(Body.GetValue('status'));

      if not HasTitulo and not HasStatus then
      begin
        SendError(Res, 400, 'Informe ao menos "titulo" ou "status" para atualizar.');
        Exit;
      end;

      Repo := TTaskRepositoryFactory.CreateRepository;

      if HasTitulo then
      begin
        if Body.GetValue<string>('titulo', '').Trim.IsEmpty then
        begin
          SendError(Res, 400, 'O campo "titulo" não pode ser vazio.');
          Exit;
        end;

        PrazoVal := Body.GetValue('dataPrazo');
        if (not Assigned(PrazoVal)) or (PrazoVal is TJSONNull) then
          DataPrazo := 0
        else
          DataPrazo := ISO8601ToDate(PrazoVal.Value, False);

        Repo.Update(
          ID,
          Body.GetValue<string>('titulo', ''),
          Body.GetValue<string>('descricao', ''),
          Body.GetValue<Integer>('prioridade', 1),
          DataPrazo
        );
      end;

      if HasStatus then
      begin
        NewStatus := Body.GetValue<string>('status', '');
        if not StatusValido(NewStatus) then
        begin
          SendError(Res, 400, 'Status inv'#225'lido. Valores aceitos: N'#227'o iniciada, Em andamento, Concluida');
          Exit;
        end;
        Repo.UpdateStatus(ID, NewStatus);
      end;

      Res.Status(200).ContentType('application/json').Send('{"ok":true}');
    finally
      Body.Free;
    end;
  except
    on E: ETaskNotFound do
      SendError(Res, 404, E.Message);
    on E: EConvertError do
      SendError(Res, 400, 'Formato de data inválido. Use o padrão: yyyy-mm-ddThh:nn:ss');
    on E: Exception do
      SendError(Res, 500, 'Erro interno: ' + E.Message);
  end;
end;

procedure HandleDelete(Req: THorseRequest; Res: THorseResponse; Next: TNextProc);
var
  Repo: ITaskRepository;
  ID: Integer;
begin
  try
    if not TryStrToInt(Req.Params['id'], ID) then
    begin
      SendError(Res, 400, 'ID inválido.');
      Exit;
    end;

    Repo := TTaskRepositoryFactory.CreateRepository;
    Repo.Delete(ID);
    Res.Status(204).Send('');
  except
    on E: ETaskNotFound do
      SendError(Res, 404, E.Message);
    on E: Exception do
      SendError(Res, 500, 'Erro interno: ' + E.Message);
  end;
end;

procedure HandleGetStats(Req: THorseRequest; Res: THorseResponse; Next: TNextProc);
var
  Repo: ITaskRepository;
  Stats: TTaskStats;
  JSON: TJSONObject;
begin
  try
    Repo := TTaskRepositoryFactory.CreateRepository;
    Stats := Repo.GetStats;
    try
      JSON := TJSONObject.Create;
      try
        JSON.AddPair('total', TJSONNumber.Create(Stats.Total));
        JSON.AddPair('mediaPrioridadeAtivas', TJSONNumber.Create(Stats.MediaPrioridadeAtivas));
        JSON.AddPair('concluidas7Dias', TJSONNumber.Create(Stats.Concluidas7Dias));
        JSON.AddPair('atrasadas', TJSONNumber.Create(Stats.Atrasadas));
        Res.Status(200).ContentType('application/json').Send(JSON.ToJSON);
      finally
        JSON.Free;
      end;
    finally
      Stats.Free;
    end;
  except
    on E: Exception do
      SendError(Res, 500, 'Erro interno: ' + E.Message);
  end;
end;

class procedure TTasksController.Register;
begin
  {Horse despacha cada requisição em thread própria. COM (usado pelo ADO) precisa
  ser inicializado individualmente em cada thread. Não funciona usar o
  CoInitialize somente na main}
  THorse.Use(
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TNextProc)
    begin
      CoInitialize(nil);
      try
        Next;
      finally
        CoUninitialize;
      end;
    end
  );

  THorse.Use(ValidateApiKey); //middleware roda antes de qualquer rota

  THorse.Get('/tasks', HandleGetAll);
  THorse.Post('/tasks', HandleCreate);
  THorse.Patch('/tasks/:id', HandleUpdate);
  THorse.Delete('/tasks/:id', HandleDelete);
  THorse.Get('/stats', HandleGetStats);
end;

end.
