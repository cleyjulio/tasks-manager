unit uClientConfig;

interface

type
  TClientConfig = class
  private
    class var FServerUrl: string;
    class var FApiKey: string;
  public
    class property ServerUrl: string read FServerUrl;
    class property ApiKey: string read FApiKey;

    class procedure Initialize(const AConfigFile: string);
  end;

implementation

uses
  System.IniFiles,
  System.SysUtils;

class procedure TClientConfig.Initialize(const AConfigFile: string);
var
  Ini: TIniFile;
begin
  if not FileExists(AConfigFile) then
    raise Exception.CreateFmt('Arquivo de configuração não encontrado: %s', [AConfigFile]);

  Ini := TIniFile.Create(AConfigFile);
  try
    FServerUrl := Ini.ReadString('Server', 'Url',    'http://localhost:9000');
    FApiKey  := Ini.ReadString('Server', 'ApiKey', '');
  finally
    Ini.Free;
  end;
end;

end.
