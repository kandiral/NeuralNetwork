unit NNOptimizers;

interface

{$I NNConfig.inc}

uses
  WinAPI.Windows,
  System.Types, System.Classes, System.SysUtils, System.Math,
  NNCommon, NeuralNetwork;

type
  TNNSGD = class( TNNOptimizer )
  private
    FWeightCount, FBiasCount: int32;
    FWeightCount1, FBiasCount1: int32;
    procedure UpdateBias;
    procedure UpdateNoBias;
  public
    constructor Create; override;
    procedure Init; override;
  end;

  TNNAdam = class(TNNOptimizer)
  private
    FWeightsM, FWeightsV: TNNDynArray; // Моменты для весов
    FBiasesM, FBiasesV: TNNDynArray;   // Моменты для смещений
    FWeightCount, FBiasCount: int32;
    FWeightCount1, FBiasCount1: int32;
    FT: int32;                      // Счётчик шагов
    FBeta1, FBeta2, FEpsilon: NNFloat; // Гиперпараметры
    procedure UpdateBias;
    procedure UpdateNoBias;
  public
    constructor Create; override;
    procedure Init; override;
  end;

  TNNRMSProp = class(TNNOptimizer)
  private
    FWeightsV: TNNDynArray; // Среднее квадратов градиентов для весов
    FBiasesV: TNNDynArray;  // Среднее квадратов градиентов для смещений
    FWeightCount, FBiasCount: int32;
    FWeightCount1, FBiasCount1: int32;
    FRho, FEpsilon: NNFloat; // Гиперпараметры
    procedure UpdateBias;
    procedure UpdateNoBias;
  public
    constructor Create; override;
    procedure Init; override;
  end;

const
  TNNOptimizerClassList : array[ TNNOptimizerType ] of TNNOptimizerClass = (
    TNNSGD, TNNAdam, TNNRMSProp
  );


implementation

{ TNNSGD }

constructor TNNSGD.Create;
begin
  inherited Create( otSGD, 0.1 );
end;

procedure TNNSGD.Init;
begin
  FUpdate := UpdateNoBias;
  FWeightCount := FLayer.WeightsCount;
  FWeightCount1 := FWeightCount - 1;
  if FLayer.UseBiases then begin
    FBiasCount := FLayer.BiasesCount;
    FBiasCount1 := FBiasCount - 1;
    FUpdate := UpdateBias;
  end;
end;

procedure TNNSGD.UpdateBias;
var
  i: int32;
  WeightGrads, Weights, BiasGrads, Biases: PNNFloat;
begin
  WeightGrads := FLayer.WeightGrads;
  Weights := FLayer.Weights;
  BiasGrads := FLayer.BiasGrads;
  Biases := FLayer.Biases;

  for i := 0 to FWeightCount1 do begin
    Weights^ := Weights^ - FLearningRate * WeightGrads^;
    Inc( Weights );
    Inc( WeightGrads );
  end;

  for i := 0 to FBiasCount1 do begin
    Biases^ := Biases^ - FLearningRate * BiasGrads^;
    Inc( Biases );
    Inc( BiasGrads );
  end;
end;

procedure TNNSGD.UpdateNoBias;
var
  i: int32;
  WeightGrads, Weights: PNNFloat;
begin
  WeightGrads := FLayer.WeightGrads;
  Weights := FLayer.Weights;

  for i := 0 to FWeightCount1 do begin
    Weights^ := Weights^ - FLearningRate * WeightGrads^;
    Inc( Weights );
    Inc( WeightGrads );
  end;
end;

{ TNNAdam }

constructor TNNAdam.Create;
begin
  inherited Create( otAdam, 0.001 );
end;

procedure TNNAdam.Init;
begin
  FT := 0;
  FBeta1 := 0.9;
  FBeta2 := 0.999;
  FEpsilon := 1e-8;

  FUpdate := UpdateNoBias;
  FWeightCount := FLayer.WeightsCount;
  FWeightCount1 := FWeightCount - 1;
  SetLength( FWeightsM, FWeightCount );
  SetLength( FWeightsV, FWeightCount );
  FillChar( FWeightsM[ 0 ], FWeightCount * SizeOf(NNFloat), 0 );
  FillChar( FWeightsV[ 0 ], FWeightCount * SizeOf(NNFloat), 0 );

  if FLayer.UseBiases then begin
    FUpdate := UpdateBias;
    FBiasCount := FLayer.BiasesCount;
    FBiasCount1 := FBiasCount - 1;
    SetLength( FBiasesM, FBiasCount );
    SetLength( FBiasesV, FBiasCount );
    FillChar( FBiasesM[ 0 ], FBiasCount * SizeOf(NNFloat), 0 );
    FillChar( FBiasesV[ 0 ], FBiasCount * SizeOf(NNFloat), 0 );
  end;
end;

procedure TNNAdam.UpdateBias;
var
  i: int32;
  m_hat, v_hat: NNFloat;
  beta1_t, beta2_t: NNFloat;
  WeightsM, WeightsV, BiasesM, BiasesV, WeightGrads, Weights, BiasGrads, Biases: PNNFloat;
begin
  Inc(FT); // Увеличиваем счётчик шагов

  // Коррекция смещения для моментов
  beta1_t := Power(FBeta1, FT);
  beta2_t := Power(FBeta2, FT);

  // Копируем указатели для итерации
  WeightsM := @FWeightsM[ 0 ];
  WeightsV := @FWeightsV[ 0 ];
  BiasesM := @FBiasesM[ 0 ];
  BiasesV := @FBiasesV[ 0 ];

  WeightGrads := FLayer.WeightGrads;
  Weights := FLayer.Weights;

  BiasGrads := FLayer.BiasGrads;
  Biases := FLayer.Biases;

  // Обновление весов
  for i := 0 to FWeightCount1 do begin
    // Первый момент: m = beta1 * m + (1 - beta1) * grad
    WeightsM^ := FBeta1 * WeightsM^ + (1 - FBeta1) * WeightGrads^;
    // Второй момент: v = beta2 * v + (1 - beta2) * grad^2
    WeightsV^ := FBeta2 * WeightsV^ + (1 - FBeta2) * Sqr(WeightGrads^);
    // Коррекция смещения
    m_hat := WeightsM^ / (1 - beta1_t);
    v_hat := WeightsV^ / (1 - beta2_t);
    // Обновление веса
    Weights^ := Weights^ - FLearningRate * m_hat / (Sqrt(v_hat) + FEpsilon);
    Inc(Weights);
    Inc(WeightGrads);
    Inc(WeightsM);
    Inc(WeightsV);
  end;

  // Обновление смещений
  for i := 0 to FBiasCount1 do begin
    // Первый момент
    BiasesM^ := FBeta1 * BiasesM^ + (1 - FBeta1) * BiasGrads^;
    // Второй момент
    BiasesV^ := FBeta2 * BiasesV^ + (1 - FBeta2) * Sqr(BiasGrads^);
    // Коррекция смещения
    m_hat := BiasesM^ / (1 - beta1_t);
    v_hat := BiasesV^ / (1 - beta2_t);
    // Обновление смещения
    Biases^ := Biases^ - FLearningRate * m_hat / (Sqr(v_hat) + FEpsilon);
    Inc(Biases);
    Inc(BiasGrads);
    Inc(BiasesM);
    Inc(BiasesV);
  end;
end;

procedure TNNAdam.UpdateNoBias;
begin

end;

{ TNNRMSProp }

constructor TNNRMSProp.Create;
begin
  inherited Create( otRMSProp, 0.001 );
end;

procedure TNNRMSProp.Init;
begin
  FRho := 0.9;
  FEpsilon := 1e-8;
  FWeightCount := 0;
  FBiasCount := 0;

  SetLength( FWeightsV, AWeightCount );
  FillChar (FWeightsV[ 0 ], AWeightCount * SizeOf(NNFloat), 0 );
  FWeightCount := AWeightCount;

  SetLength( FBiasesV, ABiasCount );
  FillChar( FBiasesV[ 0 ], ABiasCount * SizeOf(NNFloat), 0);
  FBiasCount := ABiasCount;
end;

procedure TNNRMSProp.UpdateBias;
var
  i: int32;
  v: NNFloat;
  WeightsV, BiasesV: PNNFloat;
begin
  // Копируем указатели для итерации
  WeightsV := @FWeightsV[ 0 ];
  BiasesV := @FBiasesV[ 0 ];

  // Обновление весов
  for i := 0 to AWeightCount - 1 do begin
    // Среднее квадратов градиентов: v = rho * v + (1 - rho) * grad^2
    WeightsV^ := FRho * WeightsV^ + (1 - FRho) * Sqr(AWeightGrads^);
    // Обновление веса: w = w - learning_rate * grad / (sqrt(v) + epsilon)
    AWeights^ := AWeights^ - FLearningRate * AWeightGrads^ / (Sqrt(WeightsV^) + FEpsilon);
    Inc(AWeights);
    Inc(AWeightGrads);
    Inc(WeightsV);
  end;

  // Обновление смещений
  for i := 0 to ABiasCount - 1 do begin
    // Среднее квадратов градиентов
    BiasesV^ := FRho * BiasesV^ + (1 - FRho) * Sqr(ABiasGrads^);
    // Обновление смещения
    ABiases^ := ABiases^ - FLearningRate * ABiasGrads^ / (Sqrt(BiasesV^) + FEpsilon);
    Inc(ABiases);
    Inc(ABiasGrads);
    Inc(BiasesV);
  end;
end;


procedure TNNRMSProp.UpdateNoBias;
begin

end;

end.
