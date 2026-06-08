unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.Grids, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls,
  uApiClient, uClientConfig;

type
  TTaskInfo = record
    ID: Integer;
    Titulo: string;
    Descricao: string;
    Prioridade: Integer;
    DataPrazoISO: string;
  end;

  TfrmMain = class(TForm)
    pnlStats: TPanel;
    lblAtrasadas: TLabel;
    lblConcluidas: TLabel;
    lblMedia: TLabel;
    grdTarefas: TStringGrid;
    pnlBottom: TPanel;
    btnNew: TButton;
    lblStatusLabel: TLabel;
    cboStatus: TComboBox;
    btnApplyStatus: TButton;
    btnDelete: TButton;
    Shape1: TShape;
    Label1: TLabel;
    Shape2: TShape;
    Label2: TLabel;
    Shape3: TShape;
    Label3: TLabel;
    lblTotal: TLabel;
    Shape4: TShape;
    Label4: TLabel;
    btnRefresh: TButton;
    btnEdit: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnRefreshClick(Sender: TObject);
    procedure btnNewClick(Sender: TObject);
    procedure btnEditClick(Sender: TObject);
    procedure btnApplyStatusClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure grdTarefasSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
  private
    FApiClient: TApiClient;
    FTasks: TArray<TTaskInfo>;
    procedure SetupGrid;
    procedure LoadTasks;
    procedure LoadStats;
    function  SelectedID: Integer;
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

uses
  System.JSON,
  System.Math,
  System.UITypes,
  System.Generics.Collections,
  uTaskForm;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  TClientConfig.Initialize(ExtractFilePath(ParamStr(0)) + 'config.ini');
  FApiClient := TApiClient.Create(TClientConfig.ServerUrl, TClientConfig.ApiKey);
  SetupGrid;
  LoadStats;
  LoadTasks;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  FApiClient.Free;
end;

procedure TfrmMain.SetupGrid;
begin
  grdTarefas.ColCount := 6;

  grdTarefas.Cells[0, 0] := 'ID';
  grdTarefas.Cells[1, 0] := 'Titulo';
  grdTarefas.Cells[2, 0] := 'Status';
  grdTarefas.Cells[3, 0] := 'Prioridade';
  grdTarefas.Cells[4, 0] := 'Prazo';
  grdTarefas.Cells[5, 0] := 'Atrasada';

  grdTarefas.ColWidths[0] := 40;
  grdTarefas.ColWidths[1] := 300;
  grdTarefas.ColWidths[2] := 120;
  grdTarefas.ColWidths[3] := 110;
  grdTarefas.ColWidths[4] := 90;
  grdTarefas.ColWidths[5] := 70;
end;

procedure TfrmMain.LoadTasks;
var
  Tasks: TJSONArray;
  Task: TJSONValue;
  Prazo: TJSONValue;
  Row, i: Integer;
  Sim: string;
begin
  try
    Tasks := FApiClient.GetTasks;
    if not Assigned(Tasks) then Exit;
    try
      grdTarefas.RowCount := Max(2, Tasks.Count + 1);
      SetLength(FTasks, Tasks.Count);

      for i := 0 to Tasks.Count - 1 do
      begin
        Row := i + 1;
        Task := Tasks.Items[i];
        FTasks[i].ID := Task.GetValue<Integer>('id');
        FTasks[i].Titulo := Task.GetValue<string>('titulo');
        FTasks[i].Descricao := Task.GetValue<string>('descricao');
        FTasks[i].Prioridade := Task.GetValue<Integer>('prioridade');

        Prazo := (Task as TJSONObject).GetValue('dataPrazo');
        if (not Assigned(Prazo)) or (Prazo is TJSONNull) then
          FTasks[i].DataPrazoISO := ''
        else
          FTasks[i].DataPrazoISO := Copy(Prazo.Value, 1, 19);

        grdTarefas.Cells[0, Row] := Task.GetValue<Integer>('id').ToString;
        grdTarefas.Cells[1, Row] := Task.GetValue<string>('titulo');
        grdTarefas.Cells[2, Row] := Task.GetValue<string>('status');
        case Task.GetValue<Integer>('prioridade') of
          1: grdTarefas.Cells[3, Row] := '1 - Muito Alta';
          2: grdTarefas.Cells[3, Row] := '2 - Alta';
          3: grdTarefas.Cells[3, Row] := '3 - Média';
          4: grdTarefas.Cells[3, Row] := '4 - Baixa';
          5: grdTarefas.Cells[3, Row] := '5 - Muito Baixa';
        else
          grdTarefas.Cells[3, Row] := Task.GetValue<Integer>('prioridade').ToString;
        end;

        if FTasks[i].DataPrazoISO = '' then
          grdTarefas.Cells[4, Row] := '-'
        else
          grdTarefas.Cells[4, Row] := Copy(FTasks[i].DataPrazoISO, 9, 2) + '/' +
            Copy(FTasks[i].DataPrazoISO, 6, 2) + '/' + Copy(FTasks[i].DataPrazoISO, 1, 4);

        if Task.GetValue<Boolean>('atrasada') then
          Sim := 'Sim'
        else
          Sim := 'Não';
        grdTarefas.Cells[5, Row] := Sim;
      end;
    finally
      Tasks.Free;
    end;
  except
    on E: Exception do
      ShowMessage('Erro ao carregar tarefas: ' + E.Message);
  end;
end;

procedure TfrmMain.LoadStats;
var
  Stats: TJSONObject;
begin
  try
    Stats := FApiClient.GetStats;
    if not Assigned(Stats) then Exit;
    try
      lblTotal.Caption := Stats.GetValue<Integer>('total', 0).ToString;
      lblAtrasadas.Caption := Stats.GetValue<Integer>('atrasadas', 0).ToString;
      lblConcluidas.Caption:= Stats.GetValue<Integer>('concluidas7Dias', 0).ToString;
      lblMedia.Caption := FormatFloat('0.0', Stats.GetValue<Double>('mediaPrioridadeAtivas', 0));
    finally
      Stats.Free;
    end;
  except
    on E: Exception do
      lblTotal.Caption := 'Erro ao carregar estatisticas';
  end;
end;

function TfrmMain.SelectedID: Integer;
var
  Idx: Integer;
begin
  Result := -1;
  Idx    := grdTarefas.Row - 1;
  if (Idx >= 0) and (Idx < Length(FTasks)) then
    Result := FTasks[Idx].ID;
end;

procedure TfrmMain.grdTarefasSelectCell(Sender: TObject; ACol, ARow: Integer;
  var CanSelect: Boolean);
begin
  CanSelect := ARow > 0;
end;

procedure TfrmMain.btnRefreshClick(Sender: TObject);
begin
  LoadStats;
  LoadTasks;
end;

procedure TfrmMain.btnNewClick(Sender: TObject);
var
  Form: TfrmTask;
  Created: TJSONObject;
begin
  Form := TfrmTask.Create(Self);
  try
    if Form.ShowModal = mrOk then
    try
      Created := FApiClient.CreateTask(Form.edtTitulo.Text, Form.memDescricao.Text,
        Form.cboPrioridade.ItemIndex + 1, Form.DataPrazoISO);
      Created.Free;
      LoadStats;
      LoadTasks;
    except
      on E: Exception do
        ShowMessage('Erro ao criar tarefa: ' + E.Message);
    end;
  finally
    Form.Free;
  end;
end;

procedure TfrmMain.btnEditClick(Sender: TObject);
var
  Form: TfrmTask;
  Idx:  Integer;
begin
  Idx := grdTarefas.Row - 1;
  if (Idx < 0) or (Idx >= Length(FTasks)) then
  begin
    ShowMessage('Selecione uma tarefa na lista.');
    Exit;
  end;

  Form := TfrmTask.Create(Self);
  try
    Form.LoadFromData(FTasks[Idx].Titulo, FTasks[Idx].Descricao,
      FTasks[Idx].Prioridade, FTasks[Idx].DataPrazoISO);
    if Form.ShowModal = mrOk then
    try
      FApiClient.UpdateTask(FTasks[Idx].ID, Form.edtTitulo.Text, Form.memDescricao.Text,
        Form.cboPrioridade.ItemIndex + 1, Form.DataPrazoISO);
      LoadStats;
      LoadTasks;
    except
      on E: Exception do
        ShowMessage('Erro ao editar tarefa: ' + E.Message);
    end;
  finally
    Form.Free;
  end;
end;

procedure TfrmMain.btnApplyStatusClick(Sender: TObject);
var
  ID: Integer;
begin
  ID := SelectedID;
  if ID = -1 then
  begin
    ShowMessage('Selecione uma tarefa na lista.');
    Exit;
  end;
  if cboStatus.ItemIndex = -1 then
  begin
    ShowMessage('Selecione um status no combo.');
    Exit;
  end;

  if MessageDlg('Alterar status para "' + cboStatus.Text + '"?', mtConfirmation,
    [mbYes, mbNo], 0) = mrYes then
  try
    FApiClient.UpdateStatus(ID, cboStatus.Text);
    LoadStats;
    LoadTasks;
  except
    on E: Exception do
      ShowMessage('Erro ao atualizar status: ' + E.Message);
  end;
end;

procedure TfrmMain.btnDeleteClick(Sender: TObject);
var
  ID: Integer;
begin
  ID := SelectedID;
  if ID = -1 then
  begin
    ShowMessage('Selecione uma tarefa na lista.');
    Exit;
  end;

  if MessageDlg('Excluir tarefa ID ' + IntToStr(ID) + '?', mtConfirmation,
    [mbYes, mbNo], 0) = mrYes then
  try
    FApiClient.DeleteTask(ID);
    LoadStats;
    LoadTasks;
  except
    on E: Exception do
      ShowMessage('Erro ao excluir tarefa: ' + E.Message);
  end;
end;

end.
