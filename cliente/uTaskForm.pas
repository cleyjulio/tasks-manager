unit uTaskForm;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls;

type
  TfrmTask = class(TForm)
    lblTitulo: TLabel;
    lblDescricao: TLabel;
    lblPrioridade: TLabel;
    edtTitulo: TEdit;
    memDescricao: TMemo;
    cboPrioridade: TComboBox;
    chkPrazo: TCheckBox;
    dtpPrazo: TDateTimePicker;
    pnlButtons: TPanel;
    btnOk: TButton;
    btnCancel: TButton;
    procedure FormCreate(Sender: TObject);
    procedure chkPrazoClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
  public
    procedure LoadFromData(const ATitulo, ADescricao: string; APrioridade: Integer; const ADataPrazoISO: string);
    function DataPrazoISO: string;
  end;

implementation

{$R *.dfm}

uses
  System.DateUtils;

procedure TfrmTask.FormCreate(Sender: TObject);
begin
  dtpPrazo.Date := Now + 7;
  dtpPrazo.Enabled := False;
end;

procedure TfrmTask.chkPrazoClick(Sender: TObject);
begin
  dtpPrazo.Enabled := chkPrazo.Checked;
end;

procedure TfrmTask.btnOkClick(Sender: TObject);
begin
  if Trim(edtTitulo.Text) = '' then
  begin
    ShowMessage('O título é obrigatório.');
    edtTitulo.SetFocus;
    Exit;
  end;
  ModalResult := mrOk;
end;

procedure TfrmTask.LoadFromData(const ATitulo, ADescricao: string; APrioridade: Integer; const ADataPrazoISO: string);
begin
  Caption := 'Editar Tarefa';
  edtTitulo.Text := ATitulo;
  memDescricao.Lines.Text := ADescricao;
  cboPrioridade.ItemIndex := APrioridade - 1;
  if ADataPrazoISO <> '' then
  begin
    chkPrazo.Checked := True;
    dtpPrazo.Enabled := True;
    dtpPrazo.Date := EncodeDate(StrToInt(Copy(ADataPrazoISO, 1, 4)),
      StrToInt(Copy(ADataPrazoISO, 6, 2)), StrToInt(Copy(ADataPrazoISO, 9, 2)));
  end;
end;

function TfrmTask.DataPrazoISO: string;
begin
  // retorna data no formato correto se tiver prazo
  if chkPrazo.Checked then
    Result := FormatDateTime('yyyy-mm-dd"T"00:00:00', dtpPrazo.Date)
  else
    Result := '';
end;

end.
