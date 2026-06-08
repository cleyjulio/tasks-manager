unit Model.Task;

interface

uses
  System.SysUtils;

type
  TTask = class
  private
    FID: Integer;
    FTitulo: string;
    FDescricao: string;
    FStatus: string;
    FPrioridade: Integer;
    FDataCriacao: TDateTime;
    FDataConclusao: TDateTime;
    FDataPrazo: TDateTime;
    function GetAtrasada: Boolean;
  public
    property ID: Integer read FID write FID;
    property Titulo: string read FTitulo write FTitulo;
    property Descricao: string read FDescricao write FDescricao;
    property Status: string read FStatus write FStatus;
    property Prioridade: Integer read FPrioridade write FPrioridade;
    property DataCriacao: TDateTime read FDataCriacao write FDataCriacao;
    property DataConclusao: TDateTime read FDataConclusao write FDataConclusao;
    property DataPrazo: TDateTime read FDataPrazo write FDataPrazo;
    property Atrasada: Boolean read GetAtrasada;

    constructor Create;
  end;

  TTaskStats = class
  public
    Total: Integer;
    MediaPrioridadeAtivas: Double;
    Concluidas7Dias: Integer;
    Atrasadas: Integer;
  end;

implementation

constructor TTask.Create;
begin
  inherited;
  FStatus := 'Não iniciada';
  FPrioridade := 1;
end;

function TTask.GetAtrasada: Boolean;
begin
  //prazo vencido e a tarefa ainda não foi concluída
  Result := (FDataPrazo <> 0) and (FDataPrazo < Now) and (FStatus <> 'Concluida');
end;

end.
