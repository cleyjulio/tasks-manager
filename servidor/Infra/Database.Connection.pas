unit Database.Connection;

interface

uses
  Data.Win.ADODB;

{ATENÇÂO!!!
O ideal para o projeto seria o uso de FireDAC, porém minha licença do Delphi é
a Professional e o driver link do FireDAC para SQL Server (TFDPhysMSSQLDriverLink)
só está disponível nas edições Enterprise e Architect.
Para contornar o problema, adotei a conexão via TADOConnection (Data.Win.ADODB),
que acessa o SQL Server pelo provedor MSOLEDBSQL nativo do Windows,
sem dependências externas. }

//retorna uma conexão aberta e configurada;
function CreateDBConnection: TADOConnection;

implementation

uses
  Config,
  System.SysUtils;

function CreateDBConnection: TADOConnection;
var
  Conn: TADOConnection;
  CS: string;
begin
  Conn := TADOConnection.Create(nil);
  try

    CS := Format('Provider=MSOLEDBSQL;Server=%s;Database=%s;', [TConfig.DbServer, TConfig.DbName]);

    if TConfig.TrustedConnection then
      CS := CS + 'Integrated Security=SSPI;'
    else
      CS := CS + Format('User ID=%s;Password=%s;', [TConfig.DbUser, TConfig.DbPassword]);

    Conn.ConnectionString := CS;
    Conn.LoginPrompt := False;
    Conn.ConnectionTimeout := 10;
    Conn.Connected := True;
    Result := Conn;
  except
    Conn.Free;
    raise;
  end;
end;

end.
