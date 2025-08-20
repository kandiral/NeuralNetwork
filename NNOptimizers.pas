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
    FWeightsM, FWeightsV: TNNDynArray; // ������� ��� �����
    FBiasesM, FBiasesV: TNNDynArray;   // ������� ��� ��������
    FWeightCount, FBiasCount: int32;
    FWeightCount1, FBiasCount1: int32;
    FT: int32;                      // ������� �����
    FBeta1, FBeta2, FEpsilon: NNFloat; // ��������������
    procedure UpdateBias;
    procedure UpdateNoBias;
  public
    constructor Create; override;
    procedure Init; override;
  end;

  TNNRMSProp = class(TNNOptimizer)
  private
    FWeightsV: TNNDynArray; // ������� ��������� ���������� ��� �����
    FBiasesV: TNNDynArray;  // ������� ��������� ���������� ��� ��������
    FWeightCount, FBiasCount: int32;
    FWeightCount1, FBiasCount1: int32;
    FRho, FEpsilon: NNFloat; // ��������������
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
  Inc(FT); // ����������� ������� �����

  // ��������� �������� ��� ��������
  beta1_t := Power(FBeta1, FT);
  beta2_t := Power(FBeta2, FT);

  // �������� ��������� ��� ��������
  WeightsM := @FWeightsM[ 0 ];
  WeightsV := @FWeightsV[ 0 ];
  BiasesM := @FBiasesM[ 0 ];
  BiasesV := @FBiasesV[ 0 ];

  WeightGrads := FLayer.WeightGrads;
  Weights := FLayer.Weights;

  BiasGrads := FLayer.BiasGrads;
  Biases := FLayer.Biases;

  // ���������� �����
  for i := 0 to FWeightCount1 do begin
    // ������ ������: m = beta1 * m + (1 - beta1) * grad
    WeightsM^ := FBeta1 * WeightsM^ + (1 - FBeta1) * WeightGrads^;
    // ������ ������: v = beta2 * v + (1 - beta2) * grad^2
    WeightsV^ := FBeta2 * WeightsV^ + (1 - FBeta2) * Sqr(WeightGrads^);
    // ��������� ��������
    m_hat := WeightsM^ / (1 - beta1_t);
    v_hat := WeightsV^ / (1 - beta2_t);
    // ���������� ����
    Weights^ := Weights^ - FLearningRate * m_hat / (Sqrt(v_hat) + FEpsilon);
    Inc(Weights);
    Inc(WeightGrads);
    Inc(WeightsM);
    Inc(WeightsV);
  end;

  // ���������� ��������
  for i := 0 to FBiasCount1 do begin
    // ������ ������
    BiasesM^ := FBeta1 * BiasesM^ + (1 - FBeta1) * BiasGrads^;
    // ������ ������
    BiasesV^ := FBeta2 * BiasesV^ + (1 - FBeta2) * Sqr(BiasGrads^);
    // ��������� ��������
    m_hat := BiasesM^ / (1 - beta1_t);
    v_hat := BiasesV^ / (1 - beta2_t);
    // ���������� ��������
    Biases^ := Biases^ - FLearningRate * m_hat / (Sqr(v_hat) + FEpsilon);
    Inc(Biases);
    Inc(BiasGrads);
    Inc(BiasesM);
    Inc(BiasesV);
  end;
end;

procedure TNNAdam.UpdateNoBias;
var
  i: int32;
  m_hat, v_hat: NNFloat;
  beta1_t, beta2_t: NNFloat;
  WeightsM, WeightsV, WeightGrads, Weights: PNNFloat;
begin
  Inc(FT); // ����������� ������� �����

  // ��������� �������� ��� ��������
  beta1_t := Power(FBeta1, FT);
  beta2_t := Power(FBeta2, FT);

  // �������� ��������� ��� ��������
  WeightsM := @FWeightsM[ 0 ];
  WeightsV := @FWeightsV[ 0 ];

  WeightGrads := FLayer.WeightGrads;
  Weights := FLayer.Weights;

  // ���������� �����
  for i := 0 to FWeightCount1 do begin
    // ������ ������: m = beta1 * m + (1 - beta1) * grad
    WeightsM^ := FBeta1 * WeightsM^ + (1 - FBeta1) * WeightGrads^;
    // ������ ������: v = beta2 * v + (1 - beta2) * grad^2
    WeightsV^ := FBeta2 * WeightsV^ + (1 - FBeta2) * Sqr(WeightGrads^);
    // ��������� ��������
    m_hat := WeightsM^ / (1 - beta1_t);
    v_hat := WeightsV^ / (1 - beta2_t);
    // ���������� ����
    Weights^ := Weights^ - FLearningRate * m_hat / (Sqrt(v_hat) + FEpsilon);
    Inc(Weights);
    Inc(WeightGrads);
    Inc(WeightsM);
    Inc(WeightsV);
  end;
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

  FUpdate := UpdateNoBias;
  FWeightCount := FLayer.WeightsCount;
  FWeightCount1 := FWeightCount - 1;
  SetLength( FWeightsV, FWeightCount );
  FillChar (FWeightsV[ 0 ], FWeightCount * SizeOf(NNFloat), 0 );

  if FLayer.UseBiases then begin
    FUpdate := UpdateBias;
    FBiasCount := FLayer.BiasesCount;
    FBiasCount1 := FBiasCount - 1;
    SetLength( FBiasesV, FBiasCount );
    FillChar( FBiasesV[ 0 ], FBiasCount * SizeOf(NNFloat), 0);
  end;
end;

procedure TNNRMSProp.UpdateBias;
var
  i: int32;
  v: NNFloat;
  WeightsV, BiasesV, Weights, WeightGrads, Biases, BiasGrads: PNNFloat;
begin
  // �������� ��������� ��� ��������
  WeightsV := @FWeightsV[ 0 ];
  BiasesV := @FBiasesV[ 0 ];

  WeightGrads := FLayer.WeightGrads;
  Weights := FLayer.Weights;

  BiasGrads := FLayer.BiasGrads;
  Biases := FLayer.Biases;

  // ���������� �����
  for i := 0 to FWeightCount1 do begin
    // ������� ��������� ����������: v = rho * v + (1 - rho) * grad^2
    WeightsV^ := FRho * WeightsV^ + (1 - FRho) * Sqr( WeightGrads^ );
    // ���������� ����: w = w - learning_rate * grad / (sqrt(v) + epsilon)
    Weights^ := Weights^ - FLearningRate * WeightGrads^ / (Sqrt(WeightsV^) + FEpsilon);
    Inc( Weights );
    Inc( WeightGrads );
    Inc( WeightsV );
  end;

  // ���������� ��������
  for i := 0 to FBiasCount1 do begin
    // ������� ��������� ����������
    BiasesV^ := FRho * BiasesV^ + (1 - FRho) * Sqr( BiasGrads^ );
    // ���������� ��������
    Biases^ := Biases^ - FLearningRate * BiasGrads^ / (Sqrt(BiasesV^) + FEpsilon);
    Inc( Biases );
    Inc( BiasGrads );
    Inc( BiasesV );
  end;
end;

procedure TNNRMSProp.UpdateNoBias;
var
  i: int32;
  v: NNFloat;
  WeightsV, Weights, WeightGrads: PNNFloat;
begin
  // �������� ��������� ��� ��������
  WeightsV := @FWeightsV[ 0 ];

  WeightGrads := FLayer.WeightGrads;
  Weights := FLayer.Weights;

  // ���������� �����
  for i := 0 to FWeightCount1 do begin
    // ������� ��������� ����������: v = rho * v + (1 - rho) * grad^2
    WeightsV^ := FRho * WeightsV^ + (1 - FRho) * Sqr( WeightGrads^ );
    // ���������� ����: w = w - learning_rate * grad / (sqrt(v) + epsilon)
    Weights^ := Weights^ - FLearningRate * WeightGrads^ / (Sqrt(WeightsV^) + FEpsilon);
    Inc( Weights );
    Inc( WeightGrads );
    Inc( WeightsV );
  end;
end;

end.
