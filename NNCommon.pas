unit NNCommon;

interface

{$I NNConfig.inc}

const
  NN_FILE_FORMAT_VERSION = 1;

type
  {$IFDEF NNFLOAT_SINGLE}
    NNFloat = Single;
  {$ELSE IFDEF NNFLOAT_DOUBLE}
    NNFloat = Double;
  {$ELSE}
    NNFloat = Extended;
  {$ENDIF}
  PNNFloat = ^NNFloat;

  TNNDynArray = array of NNFloat;
  PNNDynArray = ^TNNDynArray;

  TNNProcess = procedure of object;
  TNNForwardProcess = procedure( const AData: PNNFloat ) of object;
  TNNBackwardProcess = procedure( const AGradients: PNNFloat ) of object;

  TNNActivationMethod = (
    amLinear
  );
  TNNActivationMethods = set of TNNActivationMethod;

const
  TNNActivationMethod_str : array[ TNNActivationMethod ] of String = (
    'amLinear'
  );

type

  TNNPRNGenerator = ( prngMT19937 );

  TNNInitMethod = (
    imNone, imZeros, imNormal, imUniform,
    imXavierGlorotNormal, imXavierGlorotUniform
  );

const
  TNNInitMethod_str : array[ TNNInitMethod ] of String = (
    'imNone', 'imZeros', 'imNormal', 'imUniform',
    'imXavierGlorotNormal', 'imXavierGlorotUniform'
  );

type
  TNNInitParams = packed record
    InitMethod: TNNInitMethod;
    Generator: TNNPRNGenerator;
    case Integer of
    0: ( _offset, _range: NNFloat );
    1: ( _mu, _sigma: NNFloat );
  end;

  TNNLayerType = ( ltFullyConnected );

const
  NNFloatSize = SizeOf( NNFloat );

type
  TNNLosses = (
    lfMSE, lfMAE, lfMAPE, lfMSLE, lfCosineSimilarity
  );

const
  TNNLosses_str : array[ TNNLosses ] of String = (
    'MSE', 'MAE', 'MAPE', 'MSLE', 'CosineSimilarity'
  );

type
  TNNOptimizerType = ( otSGD, otAdam, otRMSProp );

const
  TNNOptimizerType_str : array[ TNNOptimizerType ] of String = (
    'SGD', 'Adam', 'RMSProp'
  );


implementation

end.
