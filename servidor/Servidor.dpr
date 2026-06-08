program Servidor;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  Winapi.ActiveX,   // CoInitialize/CoUninitialize — exigido pelo ADO (COM)
  System.SysUtils,
  Horse,
  Config              in 'Infra\Config.pas',
  Database.Connection in 'Infra\Database.Connection.pas',
  Model.Task          in 'Model\Model.Task.pas',
  Repository.Interfaces in 'Repository\Repository.Interfaces.pas',
  Repository.SQLServer  in 'Repository\Repository.SQLServer.pas',
  Repository.Factory    in 'Repository\Repository.Factory.pas',
  Controller.Tasks      in 'Controller\Controller.Tasks.pas';

begin
  // ADO usa COM; em console app o Delphi não inicializa COM automaticamente
  // (em app VCL o Application.Initialize cuida disso)
  CoInitialize(nil);
  try
    try
      TConfig.Initialize(ExtractFilePath(ParamStr(0)) + 'config.ini');

      Writeln('Conectando ao banco de dados...');
      CreateDBConnection.Free;
      Writeln('Conexão com o banco OK.');

      TTasksController.Register;

      Writeln(Format('Servidor rodando em http://localhost:%d', [TConfig.Port]));
      Writeln('Pressione Ctrl+C para encerrar.');

      THorse.Listen(TConfig.Port);
    except
      on E: Exception do
      begin
        Writeln('ERRO: ', E.Message);
        Readln;
      end;
    end;
  finally
    CoUninitialize;
  end;
end.
