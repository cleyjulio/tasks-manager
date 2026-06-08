unit Config;

interface

type
  TConfig = class
  private
    class var FDbServer: string;
    class var FDbName: string;
    class var FTrustedConn: Boolean;
    class var FDbUser: string;
    class var FDbPassword: string;
    class var FPort: Integer;
    class var FApiKey: string;
  public
    class property DbServer: string  read FDbServer;
    class property DbName: string  read FDbName;
    class property TrustedConnection: Boolean read FTrustedConn;
    class property DbUser: string  read FDbUser;
    class property DbPassword: string  read FDbPassword;
    class property Port: Integer read FPort;
    class property ApiKey: string  read FApiKey;

    //lê todas as chaves do ini em memória na inicialização
    class procedure Initialize(const AConfigFile: string);
  end;

implementation

uses
  System.IniFiles,
  System.SysUtils;

class procedure TConfig.Initialize(const AConfigFile: string);
var
  Ini: TIniFile;
begin
  if not FileExists(AConfigFile) then
    raise Exception.CreateFmt('Arquivo de configuração não encontrado: %s', [AConfigFile]);

  Ini := TIniFile.Create(AConfigFile);
  try
    FDbServer := Ini.ReadString('Database', 'Server', 'localhost');
    FDbName := Ini.ReadString('Database', 'Database', 'TarefasDB');
    FTrustedConn := Ini.ReadBool('Database', 'Trusted_Connection', True);
    FDbUser := Ini.ReadString('Database', 'Username', '');
    FDbPassword := Ini.ReadString('Database', 'Password', '');
    FPort := Ini.ReadInteger('Server', 'Port', 9000);
    FApiKey := Ini.ReadString('Security', 'ApiKey', '');
  finally
    Ini.Free;
  end;
end;

end.
