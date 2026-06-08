unit uApiClient;

{ Camada HTTP do cliente — isola todo o acesso à API REST do servidor.
  A interface VCL nunca monta URLs, headers ou JSON diretamente;
  só chama os métodos desta classe. }

interface

uses
  System.SysUtils,
  System.Net.HttpClient,
  System.Net.URLClient,
  System.JSON;

type
  EApiError = class(Exception);

  TApiClient = class
  private
    FHttp:    THTTPClient;
    FBaseUrl: string;
    procedure RaiseApiError(const ABody: string);
    function  DoGet(const APath: string): string;
    function  DoPost(const APath, ABody: string): string;
    procedure DoPatch(const APath, ABody: string);
    procedure DoDelete(const APath: string);
  public
    constructor Create(const ABaseUrl, AApiKey: string);
    destructor  Destroy; override;

    function  GetTasks: TJSONArray;
    function  CreateTask(const ATitulo, ADescricao: string; APrioridade: Integer;
      const ADataPrazoISO: string): TJSONObject;
    procedure UpdateTask(AID: Integer; const ATitulo, ADescricao:
      string; APrioridade: Integer; const ADataPrazoISO: string);
    procedure UpdateStatus(AID: Integer; const AStatus: string);
    procedure DeleteTask(AID: Integer);
    function  GetStats: TJSONObject;
  end;

implementation

uses
  System.Classes;

constructor TApiClient.Create(const ABaseUrl, AApiKey: string);
begin
  inherited Create;
  FBaseUrl := ABaseUrl;
  FHttp := THTTPClient.Create;
  // API Key enviada em todas as requisições
  FHttp.CustomHeaders['X-API-Key'] := AApiKey;
  FHttp.ConnectionTimeout := 10000;
  FHttp.ResponseTimeout   := 15000;
end;

destructor TApiClient.Destroy;
begin
  FHttp.Free;
  inherited;
end;

procedure TApiClient.RaiseApiError(const ABody: string);
var
  JSON: TJSONValue;
  Msg: string;
begin
  Msg := ABody;
  JSON := TJSONObject.ParseJSONValue(ABody);
  if Assigned(JSON) then
  try
    Msg := (JSON as TJSONObject).GetValue<string>('erro', ABody);
  finally
    JSON.Free;
  end;
  raise EApiError.Create(Msg);
end;

function TApiClient.DoGet(const APath: string): string;
var
  Resp: IHTTPResponse;
begin
  Resp := FHttp.Get(FBaseUrl + APath);
  if Resp.StatusCode >= 400 then
    RaiseApiError(Resp.ContentAsString);
  Result := Resp.ContentAsString;
end;

function TApiClient.DoPost(const APath, ABody: string): string;
var
  Stream: TStringStream;
  Resp: IHTTPResponse;
  Hdrs: TNetHeaders;
begin
  Stream := TStringStream.Create(ABody, TEncoding.UTF8);
  try
    Hdrs   := [TNameValuePair.Create('Content-Type', 'application/json')];
    Resp   := FHttp.Post(FBaseUrl + APath, Stream, nil, Hdrs);
    if Resp.StatusCode >= 400 then
      RaiseApiError(Resp.ContentAsString);
    Result := Resp.ContentAsString;
  finally
    Stream.Free;
  end;
end;

procedure TApiClient.DoPatch(const APath, ABody: string);
var
  Stream: TStringStream;
  Resp: IHTTPResponse;
  Hdrs: TNetHeaders;
begin
  Stream := TStringStream.Create(ABody, TEncoding.UTF8);
  try
    Hdrs := [TNameValuePair.Create('Content-Type', 'application/json')];
    Resp := FHttp.Patch(FBaseUrl + APath, Stream, nil, Hdrs);
    if Resp.StatusCode >= 400 then
      RaiseApiError(Resp.ContentAsString);
  finally
    Stream.Free;
  end;
end;

procedure TApiClient.DoDelete(const APath: string);
var
  Resp: IHTTPResponse;
begin
  Resp := FHttp.Delete(FBaseUrl + APath);
  if Resp.StatusCode >= 400 then
    RaiseApiError(Resp.ContentAsString);
end;

function TApiClient.GetTasks: TJSONArray;
begin
  Result := TJSONObject.ParseJSONValue(DoGet('/tasks')) as TJSONArray;
end;

function TApiClient.CreateTask(const ATitulo, ADescricao: string;
                                APrioridade: Integer;
                                const ADataPrazoISO: string): TJSONObject;
var
  Body: TJSONObject;
begin
  Body := TJSONObject.Create;
  try
    Body.AddPair('titulo', ATitulo);
    Body.AddPair('descricao', ADescricao);
    Body.AddPair('prioridade', TJSONNumber.Create(APrioridade));
    if ADataPrazoISO = '' then
      Body.AddPair('dataPrazo', TJSONNull.Create)
    else
      Body.AddPair('dataPrazo', ADataPrazoISO);
    Result := TJSONObject.ParseJSONValue(DoPost('/tasks', Body.ToJSON)) as TJSONObject;
  finally
    Body.Free;
  end;
end;

procedure TApiClient.UpdateTask(AID: Integer; const ATitulo, ADescricao: string; APrioridade: Integer; const ADataPrazoISO: string);
var
  Body: TJSONObject;
begin
  Body := TJSONObject.Create;
  try
    Body.AddPair('titulo', ATitulo);
    Body.AddPair('descricao', ADescricao);
    Body.AddPair('prioridade', TJSONNumber.Create(APrioridade));
    if ADataPrazoISO = '' then
      Body.AddPair('dataPrazo', TJSONNull.Create)
    else
      Body.AddPair('dataPrazo', ADataPrazoISO);
    DoPatch('/tasks/' + AID.ToString, Body.ToJSON);
  finally
    Body.Free;
  end;
end;

procedure TApiClient.UpdateStatus(AID: Integer; const AStatus: string);
var
  Body: TJSONObject;
begin
  Body := TJSONObject.Create;
  try
    Body.AddPair('status', AStatus);
    DoPatch('/tasks/' + AID.ToString, Body.ToJSON);
  finally
    Body.Free;
  end;
end;

procedure TApiClient.DeleteTask(AID: Integer);
begin
  DoDelete('/tasks/' + AID.ToString);
end;

function TApiClient.GetStats: TJSONObject;
begin
  Result := TJSONObject.ParseJSONValue(DoGet('/stats')) as TJSONObject;
end;

end.
