program Cliente;

uses
  Vcl.Forms,
  Vcl.Themes,
  Vcl.Styles,
  uMain         in 'uMain.pas'         {frmMain},
  uTaskForm     in 'uTaskForm.pas'     {frmTask},
  uClientConfig in 'uClientConfig.pas',
  uApiClient    in 'uApiClient.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Tablet Dark');
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
