unit Repository.Interfaces;

interface

uses
  Model.Task,
  System.SysUtils,
  System.Generics.Collections;

type
  //Quando o ID informado não existe na tabela
  ETaskNotFound = class(Exception);

  ITaskRepository = interface
    ['{7E4F8A1D-3C92-4B5E-9D6F-1A2B3C4D5E6F}']
    function  GetAll: TObjectList<TTask>;
    function  Add(const ATask: TTask): TTask;
    procedure Update(const AID: Integer; const ATitulo, ADescricao: string; APrioridade: Integer; ADataPrazo: TDateTime);
    procedure UpdateStatus(const AID: Integer; const AStatus: string);
    procedure Delete(const AID: Integer);
    function  GetStats: TTaskStats;
  end;

implementation

end.
