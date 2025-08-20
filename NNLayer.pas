unit NNLayer;

interface

uses
  WinAPI.Windows,
  System.Types, System.Classes, System.SysUtils,
  NNCommon;

type

implementation

uses NNFullyConnectedLayer;

{ TNNLayer }

constructor TNNLayer.Create;
begin
end;

class function TNNLayer.CreateFromStream( const ANeuralNetwork: TObject; const AStream: TStream ): TNNLayer;

procedure TNNLayer.EmptyProcess;
begin

end;

function TNNLayer.GetBiases: PNNDynArray;
begin
  Result := @FBiases;
end;

function TNNLayer.GetOutput: PNNDynArray;
begin
  Result := @FOutput;
end;

function TNNLayer.GetWeights: PNNDynArray;
begin
  Result := @FWeights;
end;

end.
