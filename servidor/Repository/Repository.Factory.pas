unit Repository.Factory;

interface

uses
  Repository.Interfaces;

type
  TTaskRepositoryFactory = class
  public
    //único ponto do sistema que decide qual implementação concreta usar
    class function CreateRepository: ITaskRepository;
  end;

implementation

uses
  Repository.SQLServer; //isolado na implementação

class function TTaskRepositoryFactory.CreateRepository: ITaskRepository;
begin
  Result := TTaskRepositorySQL.Create;
end;

end.
