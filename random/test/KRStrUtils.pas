(******************************************************************************)
(*                                                                            *)
(*  Kandiral Ruslan                                                           *)
(*  https://kandiral.ru                                                       *)
(*                                                                            *)
(*  KRStrUtils                                                                *)
(*  Ver.: 04.10.2019                                                          *)
(*                                                                            *)
(*                                                                            *)
(******************************************************************************)
unit KRStrUtils;

interface

{$IFDEF MSWINDOWS}
  //{$IFNDEF CPUX64}
    {$DEFINE KR_USE_ASM}
  //{$ENDIF}
{$ENDIF}

uses
  {$IF CompilerVersion >= 23}
    Winapi.Windows, System.SysUtils, System.StrUtils, System.Classes;
  {$ELSE}
    Windows, SysUtils, StrUtils, Classes;
  {$IFEND}

type
  TKRStrRec = packed record
  {$IF defined(CPU64BITS)}
    _Padding: Integer; // Make 16 byte align for payload..
  {$IFEND}
    codePage: Word;
    elemSize: Word;
    refCnt: Integer;
    length: Integer;
  end;
  PKRStrRec = ^TKRStrRec;

var
  KRDefaultSystemCodePage, KRDefaultUnicodeCodePage: uint32;

const
  TKRStrRec_sz = SizeOf( TKRStrRec );

  KRTwoDigitA : packed array[ 0 .. 99 ] of array[ 1 .. 2 ] of AnsiChar = (
     '00', '01', '02', '03', '04', '05', '06', '07', '08', '09',
     '10', '11', '12', '13', '14', '15', '16', '17', '18', '19',
     '20', '21', '22', '23', '24', '25', '26', '27', '28', '29',
     '30', '31', '32', '33', '34', '35', '36', '37', '38', '39',
     '40', '41', '42', '43', '44', '45', '46', '47', '48', '49',
     '50', '51', '52', '53', '54', '55', '56', '57', '58', '59',
     '60', '61', '62', '63', '64', '65', '66', '67', '68', '69',
     '70', '71', '72', '73', '74', '75', '76', '77', '78', '79',
     '80', '81', '82', '83', '84', '85', '86', '87', '88', '89',
     '90', '91', '92', '93', '94', '95', '96', '97', '98', '99' );

  KRTwoDigit : packed array[ 0 .. 99 ] of array[ 1 .. 2 ] of Char = (
     '00', '01', '02', '03', '04', '05', '06', '07', '08', '09',
     '10', '11', '12', '13', '14', '15', '16', '17', '18', '19',
     '20', '21', '22', '23', '24', '25', '26', '27', '28', '29',
     '30', '31', '32', '33', '34', '35', '36', '37', '38', '39',
     '40', '41', '42', '43', '44', '45', '46', '47', '48', '49',
     '50', '51', '52', '53', '54', '55', '56', '57', '58', '59',
     '60', '61', '62', '63', '64', '65', '66', '67', '68', '69',
     '70', '71', '72', '73', '74', '75', '76', '77', '78', '79',
     '80', '81', '82', '83', '84', '85', '86', '87', '88', '89',
     '90', '91', '92', '93', '94', '95', '96', '97', '98', '99' );

  KRTwoHexAU : packed array[ 0 .. 255 ] of array[ 1 .. 2 ] of AnsiChar = (
     '00', '01', '02', '03', '04', '05', '06', '07', '08', '09', '0A', '0B', '0C', '0D', '0E', '0F',
     '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '1A', '1B', '1C', '1D', '1E', '1F',
     '20', '21', '22', '23', '24', '25', '26', '27', '28', '29', '2A', '2B', '2C', '2D', '2E', '2F',
     '30', '31', '32', '33', '34', '35', '36', '37', '38', '39', '3A', '3B', '3C', '3D', '3E', '3F',
     '40', '41', '42', '43', '44', '45', '46', '47', '48', '49', '4A', '4B', '4C', '4D', '4E', '4F',
     '50', '51', '52', '53', '54', '55', '56', '57', '58', '59', '5A', '5B', '5C', '5D', '5E', '5F',
     '60', '61', '62', '63', '64', '65', '66', '67', '68', '69', '6A', '6B', '6C', '6D', '6E', '6F',
     '70', '71', '72', '73', '74', '75', '76', '77', '78', '79', '7A', '7B', '7C', '7D', '7E', '7F',
     '80', '81', '82', '83', '84', '85', '86', '87', '88', '89', '8A', '8B', '8C', '8D', '8E', '8F',
     '90', '91', '92', '93', '94', '95', '96', '97', '98', '99', '9A', '9B', '9C', '9D', '9E', '9F',
     'A0', 'A1', 'A2', 'A3', 'A4', 'A5', 'A6', 'A7', 'A8', 'A9', 'AA', 'AB', 'AC', 'AD', 'AE', 'AF',
     'B0', 'B1', 'B2', 'B3', 'B4', 'B5', 'B6', 'B7', 'B8', 'B9', 'BA', 'BB', 'BC', 'BD', 'BE', 'BF',
     'C0', 'C1', 'C2', 'C3', 'C4', 'C5', 'C6', 'C7', 'C8', 'C9', 'CA', 'CB', 'CC', 'CD', 'CE', 'CF',
     'D0', 'D1', 'D2', 'D3', 'D4', 'D5', 'D6', 'D7', 'D8', 'D9', 'DA', 'DB', 'DC', 'DD', 'DE', 'DF',
     'E0', 'E1', 'E2', 'E3', 'E4', 'E5', 'E6', 'E7', 'E8', 'E9', 'EA', 'EB', 'EC', 'ED', 'EE', 'EF',
     'F0', 'F1', 'F2', 'F3', 'F4', 'F5', 'F6', 'F7', 'F8', 'F9', 'FA', 'FB', 'FC', 'FD', 'FE', 'FF' );

  KRTwoHexU : packed array[ 0 .. 255 ] of array[ 1 .. 2 ] of Char = (
     '00', '01', '02', '03', '04', '05', '06', '07', '08', '09', '0A', '0B', '0C', '0D', '0E', '0F',
     '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '1A', '1B', '1C', '1D', '1E', '1F',
     '20', '21', '22', '23', '24', '25', '26', '27', '28', '29', '2A', '2B', '2C', '2D', '2E', '2F',
     '30', '31', '32', '33', '34', '35', '36', '37', '38', '39', '3A', '3B', '3C', '3D', '3E', '3F',
     '40', '41', '42', '43', '44', '45', '46', '47', '48', '49', '4A', '4B', '4C', '4D', '4E', '4F',
     '50', '51', '52', '53', '54', '55', '56', '57', '58', '59', '5A', '5B', '5C', '5D', '5E', '5F',
     '60', '61', '62', '63', '64', '65', '66', '67', '68', '69', '6A', '6B', '6C', '6D', '6E', '6F',
     '70', '71', '72', '73', '74', '75', '76', '77', '78', '79', '7A', '7B', '7C', '7D', '7E', '7F',
     '80', '81', '82', '83', '84', '85', '86', '87', '88', '89', '8A', '8B', '8C', '8D', '8E', '8F',
     '90', '91', '92', '93', '94', '95', '96', '97', '98', '99', '9A', '9B', '9C', '9D', '9E', '9F',
     'A0', 'A1', 'A2', 'A3', 'A4', 'A5', 'A6', 'A7', 'A8', 'A9', 'AA', 'AB', 'AC', 'AD', 'AE', 'AF',
     'B0', 'B1', 'B2', 'B3', 'B4', 'B5', 'B6', 'B7', 'B8', 'B9', 'BA', 'BB', 'BC', 'BD', 'BE', 'BF',
     'C0', 'C1', 'C2', 'C3', 'C4', 'C5', 'C6', 'C7', 'C8', 'C9', 'CA', 'CB', 'CC', 'CD', 'CE', 'CF',
     'D0', 'D1', 'D2', 'D3', 'D4', 'D5', 'D6', 'D7', 'D8', 'D9', 'DA', 'DB', 'DC', 'DD', 'DE', 'DF',
     'E0', 'E1', 'E2', 'E3', 'E4', 'E5', 'E6', 'E7', 'E8', 'E9', 'EA', 'EB', 'EC', 'ED', 'EE', 'EF',
     'F0', 'F1', 'F2', 'F3', 'F4', 'F5', 'F6', 'F7', 'F8', 'F9', 'FA', 'FB', 'FC', 'FD', 'FE', 'FF' );

  KRTwoHexAL : packed array[ 0 .. 255 ] of array[ 1 .. 2 ] of AnsiChar = (
     '00', '01', '02', '03', '04', '05', '06', '07', '08', '09', '0a', '0b', '0c', '0d', '0e', '0f',
     '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '1a', '1b', '1c', '1d', '1e', '1f',
     '20', '21', '22', '23', '24', '25', '26', '27', '28', '29', '2a', '2b', '2c', '2d', '2e', '2f',
     '30', '31', '32', '33', '34', '35', '36', '37', '38', '39', '3a', '3b', '3c', '3d', '3e', '3f',
     '40', '41', '42', '43', '44', '45', '46', '47', '48', '49', '4a', '4b', '4c', '4d', '4e', '4f',
     '50', '51', '52', '53', '54', '55', '56', '57', '58', '59', '5a', '5b', '5c', '5d', '5e', '5f',
     '60', '61', '62', '63', '64', '65', '66', '67', '68', '69', '6a', '6b', '6c', '6d', '6e', '6f',
     '70', '71', '72', '73', '74', '75', '76', '77', '78', '79', '7a', '7b', '7c', '7d', '7e', '7f',
     '80', '81', '82', '83', '84', '85', '86', '87', '88', '89', '8a', '8b', '8c', '8d', '8e', '8f',
     '90', '91', '92', '93', '94', '95', '96', '97', '98', '99', '9a', '9b', '9c', '9d', '9e', '9f',
     'a0', 'a1', 'a2', 'a3', 'a4', 'a5', 'a6', 'a7', 'a8', 'a9', 'aa', 'ab', 'ac', 'ad', 'ae', 'af',
     'b0', 'b1', 'b2', 'b3', 'b4', 'b5', 'b6', 'b7', 'b8', 'b9', 'ba', 'bb', 'bc', 'bd', 'be', 'bf',
     'c0', 'c1', 'c2', 'c3', 'c4', 'c5', 'c6', 'c7', 'c8', 'c9', 'ca', 'cb', 'cc', 'cd', 'ce', 'cf',
     'd0', 'd1', 'd2', 'd3', 'd4', 'd5', 'd6', 'd7', 'd8', 'd9', 'da', 'db', 'dc', 'dd', 'de', 'df',
     'e0', 'e1', 'e2', 'e3', 'e4', 'e5', 'e6', 'e7', 'e8', 'e9', 'ea', 'eb', 'ec', 'ed', 'ee', 'ef',
     'f0', 'f1', 'f2', 'f3', 'f4', 'f5', 'f6', 'f7', 'f8', 'f9', 'fa', 'fb', 'fc', 'fd', 'fe', 'ff' );

  KRTwoHexL : packed array[ 0 .. 255 ] of array[ 1 .. 2 ] of Char = (
     '00', '01', '02', '03', '04', '05', '06', '07', '08', '09', '0a', '0b', '0c', '0d', '0e', '0f',
     '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '1a', '1b', '1c', '1d', '1e', '1f',
     '20', '21', '22', '23', '24', '25', '26', '27', '28', '29', '2a', '2b', '2c', '2d', '2e', '2f',
     '30', '31', '32', '33', '34', '35', '36', '37', '38', '39', '3a', '3b', '3c', '3d', '3e', '3f',
     '40', '41', '42', '43', '44', '45', '46', '47', '48', '49', '4a', '4b', '4c', '4d', '4e', '4f',
     '50', '51', '52', '53', '54', '55', '56', '57', '58', '59', '5a', '5b', '5c', '5d', '5e', '5f',
     '60', '61', '62', '63', '64', '65', '66', '67', '68', '69', '6a', '6b', '6c', '6d', '6e', '6f',
     '70', '71', '72', '73', '74', '75', '76', '77', '78', '79', '7a', '7b', '7c', '7d', '7e', '7f',
     '80', '81', '82', '83', '84', '85', '86', '87', '88', '89', '8a', '8b', '8c', '8d', '8e', '8f',
     '90', '91', '92', '93', '94', '95', '96', '97', '98', '99', '9a', '9b', '9c', '9d', '9e', '9f',
     'a0', 'a1', 'a2', 'a3', 'a4', 'a5', 'a6', 'a7', 'a8', 'a9', 'aa', 'ab', 'ac', 'ad', 'ae', 'af',
     'b0', 'b1', 'b2', 'b3', 'b4', 'b5', 'b6', 'b7', 'b8', 'b9', 'ba', 'bb', 'bc', 'bd', 'be', 'bf',
     'c0', 'c1', 'c2', 'c3', 'c4', 'c5', 'c6', 'c7', 'c8', 'c9', 'ca', 'cb', 'cc', 'cd', 'ce', 'cf',
     'd0', 'd1', 'd2', 'd3', 'd4', 'd5', 'd6', 'd7', 'd8', 'd9', 'da', 'db', 'dc', 'dd', 'de', 'df',
     'e0', 'e1', 'e2', 'e3', 'e4', 'e5', 'e6', 'e7', 'e8', 'e9', 'ea', 'eb', 'ec', 'ed', 'ee', 'ef',
     'f0', 'f1', 'f2', 'f3', 'f4', 'f5', 'f6', 'f7', 'f8', 'f9', 'fa', 'fb', 'fc', 'fd', 'fe', 'ff' );

  function KRInt32ToAStr( AValue: int32 ): AnsiString;
  function KRUInt32ToAStr( AValue: uint32 ): AnsiString; overload;
  function KRUInt32ToAStr( AValue: uint32; ALength: uint32 ): AnsiString; overload;
  function KRInt64ToAStr( AValue: int64 ): AnsiString;
  function KRUInt64ToAStr( AValue: uint64 ): AnsiString;

  function KRInt32ToStr( AValue: int32 ): String;
  function KRUInt32ToStr( AValue: uint32 ): String; overload;
  function KRUInt32ToStr( AValue: uint32; ALength: uint32 ): String; overload;
  function KRInt64ToStr( AValue: int64 ): String;
  function KRUInt64ToStr( AValue: uint64 ): String;

  function KRUint8ToAHexU( AValue: uint8 ): AnsiString;
  function KRUint16ToAHexU( AValue: uint16 ): AnsiString;
  function KRUint32ToAHexU( AValue: uint32 ): AnsiString;
  function KRUint64ToAHexU( AValue: uint64 ): AnsiString;

  function KRUint8ToAHexL( AValue: uint8 ): AnsiString;
  function KRUint16ToAHexL( AValue: uint16 ): AnsiString;
  function KRUint32ToAHexL( AValue: uint32 ): AnsiString;
  function KRUint64ToAHexL( AValue: uint64 ): AnsiString;

  function KRExtractFileName( const AFileName: string ): string; inline;
  function KRExtractFilePath( const AFileName: string ): string; inline;
  function KRExtractFileExt( const AFileName: string ): string; inline;
  function KRExtractFileExt2( const AFileName: string ): string; inline;

  procedure KRSortStrings( AStrings: TStrings; ADesc: boolean = false );

  // Old Functions Begin
  function KRDelSpaces(S: String): String;
  function KRIsNum(Ch: Char): boolean;
  function KRStrExist(Str,SubStr: String): boolean;
  function KRStrExistC(Str,SubStr: String): boolean;
  function KRReplStr(AText,ASubStr,AStr: String): String;
  function KRReplStrC(AText,ASubStr,AStr: String): String;
  function KRPosC(ASubStr, AStr: String): integer;
  function KRPosExC(ASubStr, AStr: String; APos: integer): integer;
  function KRBackPos(ASubStr, AStr: String): integer;
  function KRBackPosEx(ASubStr, AStr: String; APos: integer): integer;
  function KRBackPosC(ASubStr, AStr: String): integer;
  function KRBackPosExC(ASubStr, AStr: String; APos: integer): integer;
  function KRRightFrom(AText: String; APos: integer): String;overload;
  function KRRightFrom(AText, AST: String): String;overload;
  function KRRightFromC(AText, AST: String): String;
  function KRLeftTo(AText, AST: String): String;
  function KRLeftToC(AText, AST: String): String;
  function KRCopyFromTo(AText: String;APos0,APos1: Integer): String;overload;
  function KRCopyFromTo(AText, ASTBg: String; APosEd, APos: Integer): String;overload;
  function KRCopyFromTo(AText, ASTBg: String; APosEd: integer): String;overload;
  function KRCopyFromTo(AText: String;APosBg: Integer;ASTEd: String;out OPos: integer): String;overload;
  function KRCopyFromTo(AText: String;APosBg: Integer;ASTEd: String): String;overload;
  function KRCopyFromTo(AText, ASTBg, ASTEd: String; APos: integer;out OPos: integer): string;overload;
  function KRCopyFromTo(AText, ASTBg, ASTEd: String; APos: integer): string;overload;
  function KRCopyFromTo(AText, ASTBg, ASTEd: String): string;overload;
  function KRCopyFromToC(AText, ASTBg: String; APosEd, APos: Integer): String;overload;
  function KRCopyFromToC(AText, ASTBg: String; APosEd: integer): String;overload;
  function KRCopyFromToC(AText: String;APosBg: Integer;ASTEd: String;out OPos: integer): String;overload;
  function KRCopyFromToC(AText: String;APosBg: Integer;ASTEd: String): String;overload;
  function KRCopyFromToC(AText, ASTBg, ASTEd: String; APos: integer;out OPos: integer): string;overload;
  function KRCopyFromToC(AText, ASTBg, ASTEd: String; APos: integer): string;overload;
  function KRCopyFromToC(AText, ASTBg, ASTEd: String): string;overload;
  function KRCutFromTo(AText, ASTBg, ASTEd: String): string;overload;
  function KRCutFromTo(AText, ASTBg, ASTEd: String; out ACutStr: String): string;overload;
  procedure KRSplitStr(AText, ADlm: String; AStrings: TStrings);
  procedure KRSplitStrC(AText, ADlm: String; AStrings: TStrings);
  function KRUTF8ToStr(Value: String): String;
  function KRUTF8ToStrSmart(Value: String): String;
  function KRFastValToHexChar(AVal: UInt8): Char;
  procedure KRFastByteToHex(bt: UInt8; out Res: String);
  procedure KRFastWordToHex(wd: UInt16; out Res: String);
  procedure KRFastDWordToHex(dw: UInt32; out Res: String);
  function KRFastHexCharToVal(ACh: Char): UInt8;
  function KRFastHexToByte( const s: String ): UInt8;
  function KRFastHexToWord( const s: String ): UInt16;
  function KRFastHexToDWord( const s: String ): UInt32;
  function KRIsIPAddress( const Text: String ): Boolean;
  function KRIsNumber( const AText: String; out AValue: Int32): Boolean;
  // Old Functions End


implementation

procedure KRSortStrings( AStrings: TStrings; ADesc: boolean = false );

  procedure QuickSortAsk( L, R: Integer );
  var
    I, J, P: Integer;
  begin
    repeat
      I := L;
      J := R;
      P := (L + R) shr 1;
      repeat
        while CompareText( AStrings[ i ], AStrings[ p ] ) < 0 do Inc(I);
        while CompareText( AStrings[ j ], AStrings[ p ] ) > 0 do Dec(J);
        if I <= J then
        begin
          if I <> J then AStrings.Exchange( I, J );
          if P = I then P := J
          else if P = J then P := I;
          Inc(I);
          Dec(J);
        end;
      until I > J;
      if L < J then QuickSortAsk( L, J );
      L := I;
    until I >= R;
  end;

  procedure QuickSortDesc( L, R: Integer );
  var
    I, J, P: Integer;
  begin
    repeat
      I := L;
      J := R;
      P := (L + R) shr 1;
      repeat
        while CompareText( AStrings[ i ], AStrings[ p ] ) > 0 do Inc(I);
        while CompareText( AStrings[ j ], AStrings[ p ] ) < 0 do Dec(J);
        if I <= J then
        begin
          if I <> J then AStrings.Exchange( I, J );
          if P = I then P := J
          else if P = J then P := I;
          Inc(I);
          Dec(J);
        end;
      until I > J;
      if L < J then QuickSortDesc( L, J );
      L := I;
    until I >= R;
  end;

begin
  if AStrings.Count < 2 then exit;

  if ADesc then QuickSortDesc( 0, AStrings.Count - 1 ) else QuickSortAsk( 0, AStrings.Count - 1 );

end;

function KRExtractFileName( const AFileName: string ): string;
var
  i: integer;
begin
  for I := Length( AFileName ) downto 1 do
    if ( AFileName[ i ] = #$5C ) or ( AFileName[ i ] = #$2F ) or ( AFileName[ i ] = #$3A ) then begin
      Result := Copy( AFileName, i + 1, Length( AFileName ) - i );
      exit;
    end;
  Result := AFileName;
end;

function KRExtractFilePath( const AFileName: string ): string;
var
  i: integer;
begin
  for I := Length( AFileName ) downto 1 do
    if ( AFileName[ i ] = #$5C ) or ( AFileName[ i ] = #$2F ) or ( AFileName[ i ] = #$3A ) then begin
      Result := Copy( AFileName, 1, i - 1 );
      exit;
    end;
  Result := AFileName;
end;

function KRExtractFileExt( const AFileName: string ): string;
var
  i: integer;
  s: String;
begin
  s := KRExtractFileName( AFileName );
  for I := Length( s ) downto 2 do
    if ( s[ i ] = #$2E ) then begin
      Result := Copy( s, i, Length( s ) - i + 1 );
      exit;
    end;
  Result := '';
end;

function KRExtractFileExt2( const AFileName: string ): string;
var
  i: integer;
  s: String;
begin
  s := KRExtractFileName( AFileName );
  for I := Length( s ) downto 2 do
    if ( s[ i ] = #$2E ) then begin
      Result := Copy( s, i + 1, Length( s ) - i );
      exit;
    end;
  Result := '';
end;

function KRUint8ToAHexU( AValue: uint8 ): AnsiString;
{$IFDEF KR_USE_ASM}
  {$IFDEF CPUX64}
    {$I KRStrUtils\x64\KRUint8ToAHexU.asm}
  {$ELSE}
    {$I KRStrUtils\x32\KRUint8ToAHexU.asm}
  {$ENDIF}
{$ELSE}
begin
  SetLength( Result, 2 );
  PWord( @Result[ 1 ] )^ := UInt16( KRTwoHexAU[ AValue ] );
end;
{$ENDIF}

function KRUint8ToAHexL( AValue: uint8 ): AnsiString;
{$IFDEF KR_USE_ASM}
  {$IFDEF CPUX64}
    {$I KRStrUtils\x64\KRUint8ToAHexL.asm}
  {$ELSE}
    {$I KRStrUtils\x32\KRUint8ToAHexL.asm}
  {$ENDIF}
{$ELSE}
begin
  SetLength( Result, 2 );
  PWord( @Result[ 1 ] )^ := UInt16( KRTwoHexAL[ AValue ] );
end;
{$ENDIF}

function KRUint16ToAHexU( AValue: uint16 ): AnsiString;
{$IFDEF KR_USE_ASM}
  {$IFDEF CPUX64}
    {$I KRStrUtils\x64\KRUint16ToAHexU.asm}
  {$ELSE}
    {$I KRStrUtils\x32\KRUint16ToAHexU.asm}
  {$ENDIF}
{$ELSE}
begin
  SetLength( Result, 4 );
  PWord( @Result[ 1 ] )^ := UInt16( KRTwoHexAU[ AValue shr 8 ] );
  PWord( @Result[ 3 ] )^ := UInt16( KRTwoHexAU[ AValue and $ff ] );
end;
{$ENDIF}

function KRUint16ToAHexL( AValue: uint16 ): AnsiString;
{$IFDEF KR_USE_ASM}
  {$IFDEF CPUX64}
    {$I KRStrUtils\x64\KRUint16ToAHexL.asm}
  {$ELSE}
    {$I KRStrUtils\x32\KRUint16ToAHexL.asm}
  {$ENDIF}
{$ELSE}
begin
  SetLength( Result, 4 );
  PWord( @Result[ 1 ] )^ := UInt16( KRTwoHexAL[ AValue shr 8 ] );
  PWord( @Result[ 3 ] )^ := UInt16( KRTwoHexAL[ AValue and $ff ] );
end;
{$ENDIF}

function KRUint32ToAHexU( AValue: uint32 ): AnsiString;
{$IFDEF KR_USE_ASM}
  {$IFDEF CPUX64}
    {$I KRStrUtils\x64\KRUint32ToAHexU.asm}
  {$ELSE}
    {$I KRStrUtils\x32\KRUint32ToAHexU.asm}
  {$ENDIF}
{$ELSE}
begin
  SetLength( Result, 8 );
  PWord( @Result[ 1 ] )^ := UInt16( KRTwoHexAU[ AValue shr 24 ] );
  PWord( @Result[ 3 ] )^ := UInt16( KRTwoHexAU[ ( AValue shr 16 ) and $ff ] );
  PWord( @Result[ 5 ] )^ := UInt16( KRTwoHexAU[ ( AValue shr 8 ) and $ff ] );
  PWord( @Result[ 7 ] )^ := UInt16( KRTwoHexAU[ AValue and $ff ] );
end;
{$ENDIF}

function KRUint32ToAHexL( AValue: uint32 ): AnsiString;
{$IFDEF KR_USE_ASM}
  {$IFDEF CPUX64}
    {$I KRStrUtils\x64\KRUint32ToAHexL.asm}
  {$ELSE}
    {$I KRStrUtils\x32\KRUint32ToAHexL.asm}
  {$ENDIF}
{$ELSE}
begin
  SetLength( Result, 8 );
  PWord( @Result[ 1 ] )^ := UInt16( KRTwoHexAL[ AValue shr 24 ] );
  PWord( @Result[ 3 ] )^ := UInt16( KRTwoHexAL[ ( AValue shr 16 ) and $ff ] );
  PWord( @Result[ 5 ] )^ := UInt16( KRTwoHexAL[ ( AValue shr 8 ) and $ff ] );
  PWord( @Result[ 7 ] )^ := UInt16( KRTwoHexAL[ AValue and $ff ] );
end;
{$ENDIF}

function KRUint64ToAHexU( AValue: uint64 ): AnsiString;
{$IFDEF KR_USE_ASM}
  {$IFDEF CPUX64}
    {$I KRStrUtils\x64\KRUint64ToAHexU.asm}
  {$ELSE}
    {$I KRStrUtils\x32\KRUint64ToAHexU.asm}
  {$ENDIF}
{$ELSE}
begin
  SetLength( Result, 16 );
  PWord( @Result[ 1 ] )^ := UInt16( KRTwoHexAU[ AValue shr 56 ] );
  PWord( @Result[ 3 ] )^ := UInt16( KRTwoHexAU[ ( AValue shr 48 ) and $ff ] );
  PWord( @Result[ 5 ] )^ := UInt16( KRTwoHexAU[ ( AValue shr 40 ) and $ff ] );
  PWord( @Result[ 7 ] )^ := UInt16( KRTwoHexAU[ ( AValue shr 32 ) and $ff ] );
  PWord( @Result[ 9 ] )^ := UInt16( KRTwoHexAU[ ( AValue shr 24 ) and $ff ] );
  PWord( @Result[ 11 ] )^ := UInt16( KRTwoHexAU[ ( AValue shr 16 ) and $ff ] );
  PWord( @Result[ 13 ] )^ := UInt16( KRTwoHexAU[ ( AValue shr 8 ) and $ff ] );
  PWord( @Result[ 15 ] )^ := UInt16( KRTwoHexAU[ AValue and $ff ] );
end;
{$ENDIF}

function KRUint64ToAHexL( AValue: uint64 ): AnsiString;
{$IFDEF KR_USE_ASM}
  {$IFDEF CPUX64}
    {$I KRStrUtils\x64\KRUint64ToAHexL.asm}
  {$ELSE}
    {$I KRStrUtils\x32\KRUint64ToAHexL.asm}
  {$ENDIF}
{$ELSE}
begin
  SetLength( Result, 16 );
  PWord( @Result[ 1 ] )^ := UInt16( KRTwoHexAL[ AValue shr 56 ] );
  PWord( @Result[ 3 ] )^ := UInt16( KRTwoHexAL[ ( AValue shr 48 ) and $ff ] );
  PWord( @Result[ 5 ] )^ := UInt16( KRTwoHexAL[ ( AValue shr 40 ) and $ff ] );
  PWord( @Result[ 7 ] )^ := UInt16( KRTwoHexAL[ ( AValue shr 32 ) and $ff ] );
  PWord( @Result[ 9 ] )^ := UInt16( KRTwoHexAL[ ( AValue shr 24 ) and $ff ] );
  PWord( @Result[ 11 ] )^ := UInt16( KRTwoHexAL[ ( AValue shr 16 ) and $ff ] );
  PWord( @Result[ 13 ] )^ := UInt16( KRTwoHexAL[ ( AValue shr 8 ) and $ff ] );
  PWord( @Result[ 15 ] )^ := UInt16( KRTwoHexAL[ AValue and $ff ] );
end;
{$ENDIF}

function KRInt32ToAStr( AValue: int32 ): AnsiString;
{$IFDEF KR_USE_ASM}
  {$IFDEF CPUX64}
    {$I KRStrUtils\x64\KRInt32ToAStr.asm}
  {$ELSE}
    {$I KRStrUtils\x32\KRInt32ToAStr.asm}
  {$ENDIF}
{$ELSE}
var
  p: NativeInt;
  j, _len, vl: uint32;
  b: boolean;
begin
  if AValue < 0 then begin
    vl := -AValue;
    b := true;
  end else begin
    vl := AValue;
    b := false;
  end;
  if vl >= 10000 then
    if vl >= 1000000 then
      if vl >= 100000000 then _len := 9 + Ord( vl >= 1000000000 )
      else _len := 7 + Ord( vl >= 10000000 )
    else _len := 5 + Ord( vl >= 100000 )
  else if vl >= 100 then _len := 3 + Ord( vl >= 1000 )
  else _len := 1 + Ord( vl >= 10 );
  SetLength( Result, _len + ord( b ) );
  p := NativeInt( @Result[ 1 ] );
  PAnsiChar( P )^ := '-';
  Inc( p, ord( b ) );
  while _len > 2 do begin
    j  := vl mod 100;
    vl := vl div 100;
    dec( _len, 2 );
    PWord( P + _len )^ := UInt16( KRTwoDigitA[ j ] );
  end;
  if _len = 2 then PWord( P )^ := UInt16( KRTwoDigitA[ vl ] )
  else PAnsiChar( P )^ := AnsiChar( vl or ord( '0' ) );
end;
{$ENDIF}

function KRInt32ToStr( AValue: int32 ): String;
{$IFDEF KR_USE_ASM}
  {$IFDEF CPUX64}
    {$I KRStrUtils\x64\KRInt32ToStr.asm}
  {$ELSE}
    {$I KRStrUtils\x32\KRInt32ToStr.asm}
  {$ENDIF}
{$ELSE}
var
  p: NativeInt;
  j, _len, vl: uint32;
  b: boolean;
begin
  if AValue < 0 then begin
    vl := -AValue;
    b := true;
  end else begin
    vl := AValue;
    b := false;
  end;
  if vl >= 10000 then
    if vl >= 1000000 then
      if vl >= 100000000 then _len := 9 + Ord( vl >= 1000000000 )
      else _len := 7 + Ord( vl >= 10000000 )
    else _len := 5 + Ord( vl >= 100000 )
  else if vl >= 100 then _len := 3 + Ord( vl >= 1000 )
  else _len := 1 + Ord( vl >= 10 );
  if b then begin
    SetLength( Result, _len + 1 );
    Result[ 1 ] := '-';
    p := NativeInt( @Result[ 2 ] );
  end else begin
    SetLength( Result, _len );
    p := NativeInt( @Result[ 1 ] );
  end;
  while _len > 2 do begin
    j  := vl mod 100;
    vl := vl div 100;
    dec( _len, 2 );
    PDWORD( P + ( _len shl 1 ) )^ := UInt32( KRTwoDigit[ j ] );
  end;
  if _len = 2 then PDWORD( P )^ := UInt32( KRTwoDigit[ vl ] )
  else PWord( P )^ := Word( vl or ord( '0' ) );
end;
{$ENDIF}

function KRUInt32ToAStr( AValue: uint32 ): AnsiString;
{$IFDEF KR_USE_ASM}
  {$IFDEF CPUX64}
    {$I KRStrUtils\x64\KRUInt32ToAStr.asm}
  {$ELSE}
    {$I KRStrUtils\x32\KRUInt32ToAStr.asm}
  {$ENDIF}
{$ELSE}
var
  j, _len: uint32;
  p: NativeUInt;
begin
  if AValue >= 10000 then
    if AValue >= 1000000 then
      if AValue >= 100000000 then _len := 9 + Ord( AValue >= 1000000000 )
      else _len := 7 + Ord( AValue >= 10000000 )
    else _len := 5 + Ord( AValue >= 100000 )
  else if AValue >= 100 then _len := 3 + Ord( AValue >= 1000 )
  else _len := 1 + Ord( AValue >= 10 );
  SetLength( Result, _len );
  p := NativeInt( @Result[ 1 ] );
  while _len > 2 do begin
    j  := AValue mod 100;
    AValue := AValue div 100;
    dec( _len, 2 );
    PWord( P + _len )^ := UInt16( KRTwoDigitA[ j ] );
  end;
  if _len = 2 then PWord( P )^ := UInt16( KRTwoDigitA[ AValue ] )
  else PAnsiChar( P )^ := AnsiChar( AValue or ord( '0' ) );
end;
{$ENDIF}

function KRUInt32ToStr( AValue: uint32 ): String;
{$IFDEF KR_USE_ASM}
  {$IFDEF CPUX64}
    {$I KRStrUtils\x64\KRUInt32ToStr.asm}
  {$ELSE}
    {$I KRStrUtils\x32\KRUInt32ToStr.asm}
  {$ENDIF}
{$ELSE}
var
  j, _len: uint32;
  p: NativeUInt;
begin
  if AValue >= 10000 then
    if AValue >= 1000000 then
      if AValue >= 100000000 then _len := 9 + Ord( AValue >= 1000000000 )
      else _len := 7 + Ord( AValue >= 10000000 )
    else _len := 5 + Ord( AValue >= 100000 )
  else if AValue >= 100 then _len := 3 + Ord( AValue >= 1000 )
  else _len := 1 + Ord( AValue >= 10 );
  SetLength( Result, _len );
  p := NativeInt( @Result[ 1 ] );
  while _len > 2 do begin
    j  := AValue mod 100;
    AValue := AValue div 100;
    dec( _len, 2 );
    PDWORD( P + ( _len shl 1 ) )^ := UInt32( KRTwoDigit[ j ] );
  end;
  if _len = 2 then PDWORD( P )^ := UInt32( KRTwoDigit[ AValue ] )
  else PWord( P )^ := Word( AValue or ord( '0' ) );
end;
{$ENDIF}

function KRUInt32ToAStr( AValue: uint32; ALength: uint32 ): AnsiString;
{$IFDEF KR_USE_ASM}
  {$IFDEF CPUX64}
    {$I KRStrUtils\x64\KRUInt32ToAStrLen.asm}
  {$ELSE}
    {$I KRStrUtils\x32\KRUInt32ToAStrLen.asm}
  {$ENDIF}
{$ELSE}
var
  j, _len: uint32;
  p: NativeUInt;
begin
  if AValue >= 10000 then
    if AValue >= 1000000 then
      if AValue >= 100000000 then _len := 9 + Ord( AValue >= 1000000000 )
      else _len := 7 + Ord( AValue >= 10000000 )
    else _len := 5 + Ord( AValue >= 100000 )
  else if AValue >= 100 then _len := 3 + Ord( AValue >= 1000 )
  else _len := 1 + Ord( AValue >= 10 );
  if _len < ALength then begin
    SetLength( Result, ALength );
    p := NativeInt( @Result[ 1 ] );
    while _len < ALength do begin
      PByte( P )^ := $30;
      inc( PByte( P ) );
      dec( ALength );
    end;
  end else begin
    SetLength( Result, _len );
    p := NativeInt( @Result[ 1 ] );
  end;
  while _len > 2 do begin
    j  := AValue mod 100;
    AValue := AValue div 100;
    dec( _len, 2 );
    PWord( P + _len )^ := UInt16( KRTwoDigitA[ j ] );
  end;
  if _len = 2 then PWord( P )^ := UInt16( KRTwoDigitA[ AValue ] )
  else PAnsiChar( P )^ := AnsiChar( AValue or ord( '0' ) );
end;
{$ENDIF}

function KRUInt32ToStr( AValue: uint32; ALength: uint32 ): String;
{$IFDEF KR_USE_ASM}
  {$IFDEF CPUX64}
    {$I KRStrUtils\x64\KRUInt32ToStrLen.asm}
  {$ELSE}
    {$I KRStrUtils\x32\KRUInt32ToStrLen.asm}
  {$ENDIF}
{$ELSE}
var
  j, _len: uint32;
  p: NativeUInt;
begin
  if AValue >= 10000 then
    if AValue >= 1000000 then
      if AValue >= 100000000 then _len := 9 + Ord( AValue >= 1000000000 )
      else _len := 7 + Ord( AValue >= 10000000 )
    else _len := 5 + Ord( AValue >= 100000 )
  else if AValue >= 100 then _len := 3 + Ord( AValue >= 1000 )
  else _len := 1 + Ord( AValue >= 10 );
  if _len < ALength then begin
    SetLength( Result, ALength );
    p := NativeInt( @Result[ 1 ] );
    while _len < ALength do begin
      PWord( P )^ := $30;
      inc( PByte( P ), 2 );
      dec( ALength );
    end;
  end else begin
    SetLength( Result, _len );
    p := NativeInt( @Result[ 1 ] );
  end;
  while _len > 2 do begin
    j  := AValue mod 100;
    AValue := AValue div 100;
    dec( _len, 2 );
    PDWORD( P + ( _len shl 1 ) )^ := UInt32( KRTwoDigit[ j ] );
  end;
  if _len = 2 then PDWORD( P )^ := UInt32( KRTwoDigit[ AValue ] )
  else PWord( P )^ := Word( AValue or ord( '0' ) );
end;
{$ENDIF}

function KRInt64ToAStr( AValue: int64 ): AnsiString;
{$IFDEF KR_USE_ASM}
  {$IFDEF CPUX64}
    {$I KRStrUtils\x64\KRInt64ToAStr.asm}
  {$ELSE}
    {$I KRStrUtils\x32\KRInt64ToAStr.asm}
  {$ENDIF}
{$ELSE}
var
  p: NativeUInt;
  vl64: uint64;
  j, _len, vl32: uint32;
  b: boolean;
begin
  if AValue < 0 then begin
    vl64 := -AValue;
    b := true;
  end else begin
    vl64 := AValue;
    b := false;
  end;
  if vl64 < uint64( $100000000 ) then begin
    vl32 := vl64;
    if vl32 >= 10000 then
      if vl32 >= 1000000 then
        if vl32 >= 100000000 then _len := 9 + Ord( vl32 >= 1000000000 )
        else _len := 7 + Ord( vl32 >= 10000000 )
      else _len := 5 + Ord( vl32 >= 100000 )
    else if vl32 >= 100 then _len := 3 + Ord( vl32 >= 1000 ) else _len := 1 + Ord( vl32 >= 10 );
    SetLength( Result, _len + ord( b ) );
    p := NativeInt( @Result[ 1 ] );
    PAnsiChar( P )^ := '-';
    Inc( p, ord( b ) );
    while _len > 2 do begin
      j  := vl32 mod 100;
      vl32 := vl32 div 100;
      dec( _len, 2 );
      PWord( P + _len )^ := UInt16( KRTwoDigitA[ j ] );
    end;
    if _len = 2 then PWord( P )^ := UInt16( KRTwoDigitA[ vl32 ] )
    else PAnsiChar( P )^ := AnsiChar( vl32 or ord( '0' ) );
    exit;
  end else if vl64 >= 100000000000000 then
    if vl64 >= 10000000000000000 then
      if vl64 >= 1000000000000000000 then
        if vl64 >= 10000000000000000000 then _len := 20
        else _len := 19
      else _len := 17 + Ord(vl64 >= 100000000000000000)
    else _len := 15 + Ord(vl64 >= 1000000000000000)
  else if vl64 >= 1000000000000 then _len := 13 + Ord(vl64 >= 10000000000000)
  else if vl64 >= 10000000000 then _len := 11 + Ord(vl64 >= 100000000000) else _len := 10;
  SetLength( Result, _len + ord( b ) );
  p := NativeInt( @Result[ 1 ] );
  PAnsiChar( P )^ := '-';
  Inc( p, ord( b ) );
  while _len > 2 do begin
    j  := vl64 mod 100;
    vl64 := vl64 div 100;
    dec( _len, 2 );
    PWord( P + _len )^ := UInt16( KRTwoDigitA[ j ] );
  end;
  if _len = 2 then PWord( P )^ := UInt16( KRTwoDigitA[ vl64 ] )
  else PAnsiChar( P )^ := AnsiChar( vl64 or ord( '0' ) );
end;
{$ENDIF}

function KRInt64ToStr( AValue: int64 ): String;
{$IFDEF KR_USE_ASM}
  {$IFDEF CPUX64}
    {$I KRStrUtils\x64\KRInt64ToStr.asm}
  {$ELSE}
    {$I KRStrUtils\x32\KRInt64ToStr.asm}
  {$ENDIF}
{$ELSE}
var
  p: NativeUInt;
  vl64: uint64;
  j, _len, vl32: uint32;
  b: boolean;
begin
  if AValue < 0 then begin
    vl64 := -AValue;
    b := true;
  end else begin
    vl64 := AValue;
    b := false;
  end;
  if vl64 < uint64( $100000000 ) then begin
    vl32 := vl64;
    if vl32 >= 10000 then
      if vl32 >= 1000000 then
        if vl32 >= 100000000 then _len := 9 + Ord( vl32 >= 1000000000 )
        else _len := 7 + Ord( vl32 >= 10000000 )
      else _len := 5 + Ord( vl32 >= 100000 )
    else if vl32 >= 100 then _len := 3 + Ord( vl32 >= 1000 ) else _len := 1 + Ord( vl32 >= 10 );
    if b then begin
      SetLength( Result, _len + 1 );
      Result[ 1 ] := '-';
      p := NativeInt( @Result[ 2 ] );
    end else begin
      SetLength( Result, _len );
      p := NativeInt( @Result[ 1 ] );
    end;
    while _len > 2 do begin
      j  := vl32 mod 100;
      vl32 := vl32 div 100;
      dec( _len, 2 );
      PDWORD( P + ( _len shl 1 ) )^ := UInt32( KRTwoDigit[ j ] );
    end;
    if _len = 2 then PDWORD( P )^ := UInt32( KRTwoDigit[ vl32 ] )
    else PWord( P )^ := Word( vl32 or ord( '0' ) );
    exit;
  end else if vl64 >= 100000000000000 then
    if vl64 >= 10000000000000000 then
      if vl64 >= 1000000000000000000 then
        if vl64 >= 10000000000000000000 then _len := 20
        else _len := 19
      else _len := 17 + Ord(vl64 >= 100000000000000000)
    else _len := 15 + Ord(vl64 >= 1000000000000000)
  else if vl64 >= 1000000000000 then _len := 13 + Ord(vl64 >= 10000000000000)
  else if vl64 >= 10000000000 then _len := 11 + Ord(vl64 >= 100000000000) else _len := 10;
  if b then begin
    SetLength( Result, _len + 1 );
    Result[ 1 ] := '-';
    p := NativeInt( @Result[ 2 ] );
  end else begin
    SetLength( Result, _len );
    p := NativeInt( @Result[ 1 ] );
  end;
  while _len > 2 do begin
    j  := vl64 mod 100;
    vl64 := vl64 div 100;
    dec( _len, 2 );
    PDWORD( P + ( _len shl 1 ) )^ := UInt32( KRTwoDigit[ j ] );
  end;
  if _len = 2 then PDWORD( P )^ := UInt32( KRTwoDigit[ vl64 ] )
  else PWord( P )^ := Word( vl64 or ord( '0' ) );
end;
{$ENDIF}

function KRUInt64ToAStr( AValue: uint64 ): AnsiString;
{$IFDEF KR_USE_ASM}
  {$IFDEF CPUX64}
    {$I KRStrUtils\x64\KRUInt64ToAStr.asm}
  {$ELSE}
    {$I KRStrUtils\x32\KRUInt64ToAStr.asm}
  {$ENDIF}
{$ELSE}
var
  j, _len, vl32: uint32;
  p: NativeUInt;
begin
  if AValue < uint64( $100000000 ) then begin
    vl32 := AValue;
    if vl32 >= 10000 then
      if vl32 >= 1000000 then
        if vl32 >= 100000000 then _len := 9 + Ord( vl32 >= 1000000000 )
        else _len := 7 + Ord( vl32 >= 10000000 )
      else _len := 5 + Ord( vl32 >= 100000 )
    else if vl32 >= 100 then _len := 3 + Ord( vl32 >= 1000 ) else _len := 1 + Ord( vl32 >= 10 );
    SetLength( Result, _len );
    p := NativeInt( @Result[ 1 ] );
    while _len > 2 do begin
      j  := vl32 mod 100;
      vl32 := vl32 div 100;
      dec( _len, 2 );
      PWord( P + _len )^ := UInt16( KRTwoDigitA[ j ] );
    end;
    if _len = 2 then PWord( P )^ := UInt16( KRTwoDigitA[ vl32 ] )
    else PAnsiChar( P )^ := AnsiChar( vl32 or ord( '0' ) );
    exit;
  end else if AValue >= 100000000000000 then
    if AValue >= 10000000000000000 then
      if AValue >= 1000000000000000000 then
        if AValue >= 10000000000000000000 then _len := 20
        else _len := 19
      else _len := 17 + Ord(AValue >= 100000000000000000)
    else _len := 15 + Ord(AValue >= 1000000000000000)
  else if AValue >= 1000000000000 then _len := 13 + Ord(AValue >= 10000000000000)
  else if AValue >= 10000000000 then _len := 11 + Ord(AValue >= 100000000000) else _len := 10;
  SetLength( Result, _len );
  p := NativeInt( @Result[ 1 ] );
  while _len > 2 do begin
    j  := AValue mod 100;
    AValue := AValue div 100;
    dec( _len, 2 );
    PWord( P + _len )^ := UInt16( KRTwoDigitA[ j ] );
  end;
  if _len = 2 then PWord( P )^ := UInt16( KRTwoDigitA[ AValue ] )
  else PAnsiChar( P )^ := AnsiChar( AValue or ord( '0' ) );
end;
{$ENDIF}

function KRUInt64ToStr( AValue: uint64 ): String;
{$IFDEF KR_USE_ASM}
  {$IFDEF CPUX64}
    {$I KRStrUtils\x64\KRUInt64ToStr.asm}
  {$ELSE}
    {$I KRStrUtils\x32\KRUInt64ToStr.asm}
  {$ENDIF}
{$ELSE}
var
  j, _len, vl32: uint32;
  p: NativeUInt;
begin
  if AValue < uint64( $100000000 ) then begin
    vl32 := AValue;
    if vl32 >= 10000 then
      if vl32 >= 1000000 then
        if vl32 >= 100000000 then _len := 9 + Ord( vl32 >= 1000000000 )
        else _len := 7 + Ord( vl32 >= 10000000 )
      else _len := 5 + Ord( vl32 >= 100000 )
    else if vl32 >= 100 then _len := 3 + Ord( vl32 >= 1000 ) else _len := 1 + Ord( vl32 >= 10 );
    SetLength( Result, _len );
    p := NativeInt( @Result[ 1 ] );
    while _len > 2 do begin
      j  := vl32 mod 100;
      vl32 := vl32 div 100;
      dec( _len, 2 );
      PDWORD( P + ( _len shl 1 ) )^ := UInt32( KRTwoDigit[ j ] );
    end;
    if _len = 2 then PDWORD( P )^ := UInt32( KRTwoDigit[ vl32 ] )
    else PWord( P )^ := Word( vl32 or ord( '0' ) );
    exit;
  end else if AValue >= 100000000000000 then
    if AValue >= 10000000000000000 then
      if AValue >= 1000000000000000000 then
        if AValue >= 10000000000000000000 then _len := 20
        else _len := 19
      else _len := 17 + Ord(AValue >= 100000000000000000)
    else _len := 15 + Ord(AValue >= 1000000000000000)
  else if AValue >= 1000000000000 then _len := 13 + Ord(AValue >= 10000000000000)
  else if AValue >= 10000000000 then _len := 11 + Ord(AValue >= 100000000000) else _len := 10;
  SetLength( Result, _len );
  p := NativeInt( @Result[ 1 ] );
  while _len > 2 do begin
    j  := AValue mod 100;
    AValue := AValue div 100;
    dec( _len, 2 );
    PDWORD( P + ( _len shl 1 ) )^ := UInt32( KRTwoDigit[ j ] );
  end;
  if _len = 2 then PDWORD( P )^ := UInt32( KRTwoDigit[ AValue ] )
  else PWord( P )^ := Word( AValue or ord( '0' ) );
end;
{$ENDIF}



// Old Functions Begin
function KRIsNumber( const AText: String; out AValue: Int32): Boolean;
var
  e: Int32;
begin
  Val( AText, AValue, e );
  if e=0 then Result := True else Result := False;
end;

function KRIsIPAddress( const Text: String ): Boolean;
var
  sl: TStringList;
  vl,i: Int32;
begin
  Result:=false;
  sl:=TStringList.Create;
  try
    KRSplitStr(Text,'.',sl);
    if sl.Count=4 then begin
      Result:=true;
      for i:=0 to 3 do
        if not KRIsNumber(sl[i],vl) then begin
          result:=false;
          break;
        end else
          if(vl<0)or(vl>255)then begin
            result:=false;
            break;
          end;
    end;
  finally
    sl.free;
  end;
end;

function KRFastValToHexChar(AVal: UInt8): Char;
begin
  if AVal>9 then Result:=Chr(AVal+55) else Result:=Chr(AVal+48)
end;

procedure KRFastByteToHex(bt: UInt8; out Res: String);
begin
  SetLength(Res,2);
  Res[1]:=KRFastValToHexChar(bt shr 4);
  Res[2]:=KRFastValToHexChar(bt and $f);
end;

procedure KRFastWordToHex(wd: UInt16; out Res: String);
begin
  SetLength(Res,4);
  Res[1]:=KRFastValToHexChar(wd shr 12);
  Res[2]:=KRFastValToHexChar((wd shr 8) and $f);
  Res[3]:=KRFastValToHexChar((wd shr 4) and $f);
  Res[4]:=KRFastValToHexChar(wd and $f);
end;

procedure KRFastDWordToHex(dw: UInt32; out Res: String);
begin
  SetLength(Res, 8);
  Res[1]:=KRFastValToHexChar(dw shr 28);
  Res[2]:=KRFastValToHexChar((dw shr 24) and $f);
  Res[3]:=KRFastValToHexChar((dw shr 20) and $f);
  Res[4]:=KRFastValToHexChar((dw shr 16) and $f);
  Res[5]:=KRFastValToHexChar((dw shr 12) and $f);
  Res[6]:=KRFastValToHexChar((dw shr 8) and $f);
  Res[7]:=KRFastValToHexChar((dw shr 4) and $f);
  Res[8]:=KRFastValToHexChar(dw and $f);
end;

function KRFastHexCharToVal(ACh: Char): UInt8;
var bt: byte;
begin
  bt:=Ord(ACh);
  if bt>57 then Result:=bt-55 else Result:=bt-48;
end;

function KRFastHexToByte( const s: String): UInt8;
begin
  Result:=(KRFastHexCharToVal(s[1]) shl 4) or KRFastHexCharToVal(s[2]);
end;

function KRFastHexToWord( const s: String): UInt16;
begin
  Result:=(Word(KRFastHexToByte(copy(s,1,2))) shl 8) or KRFastHexToByte(copy(s,3,2));
end;

function KRFastHexToDWord( const s: String): UInt32;
begin
  result:=(Cardinal(KRFastHexToWord(copy(s,1,4))) shl 16) or KRFastHexToWord(copy(s,5,4));
end;

function KRDelSpaces(S: String): String;
var
  i,j,n: uint32;
begin
  S:=Trim(s);
  n:=Length(s);
  SetLength(Result,n);
  dec(n);
  j:=0;
  for i:=2 to n do begin
   if (S[i]=#9) or (S[i]=#10) or (S[i]=#13) or (S[i]=#32) or (S[i]=#160) then continue;
   Result[j]:=S[i];
   inc(j);
  end;
  SetLength(Result,j);
end;

function KRIsNum( Ch: Char ): boolean;
begin
  Result := ( ch > #47 ) and ( ch < #58 );
end;

function KRStrExist(Str,SubStr: String): boolean;
begin
  Result:=Pos(SubStr,Str)>0;
end;

function KRStrExistC(Str,SubStr: String): boolean;
begin
  Result:=KRPosC(SubStr,Str)>0;
end;

function KRReplStr(AText,ASubStr,AStr: String): String;
var ips: integer;
begin
  ips:=PosEx(PChar(ASubStr),PChar(AText),1);
  if ips>0 then begin
    Result:=LeftStr(AText,ips-1)+AStr+RightStr(AText,Length(AText)-ips-Length(ASubStr)+1);
    Result:=KRReplStr(Result,ASubStr,AStr);
  end else Result:=AText;
end;

function KRReplStrC(AText,ASubStr,AStr: String): String;
var ips: integer;
begin
  ips:=KRPosExC(PChar(ASubStr),PChar(AText),1);
  if ips>0 then begin
    Result:=LeftStr(AText,ips-1)+AStr+RightStr(AText,Length(AText)-ips-Length(ASubStr)+1);
    Result:=KRReplStrC(Result,ASubStr,AStr);
  end else Result:=AText;
end;

function KRPosC(ASubStr, AStr: String): integer;
begin
  Result:=Pos(LowerCase(ASubStr),LowerCase(AStr));
end;

function KRPosExC(ASubStr, AStr: String; APos: integer): integer;
begin
  Result:=PosEx(LowerCase(ASubStr),LowerCase(AStr),APos);
end;

function KRBackPos(ASubStr, AStr: String): integer;
begin
  Result:=KRBackPosEx(ASubStr, AStr, Length(AStr));
end;

function KRBackPosEx(ASubStr, AStr: String; APos: integer): integer;
var _ps,i: integer;
begin
  Result:=0;
  if APos-Length(ASubStr)<0 then exit;
  if Length(ASubStr)>Length(AStr) then exit;
  if APos+Length(ASubStr)-1>Length(AStr)
  then _ps:=Length(AStr)-Length(ASubStr)+1
  else _ps:=APos;
  for i:=_ps downto 1 do
    if Copy(AStr,i,Length(ASubStr))=ASubStr then begin Result:=i;exit;end;
end;

function KRBackPosC(ASubStr, AStr: String): integer;
begin
  Result:=KRBackPosExC(ASubStr, AStr, Length(AStr));
end;

function KRBackPosExC(ASubStr, AStr: String; APos: integer): integer;
var _ps,i: integer;
begin
  Result:=0;
  if APos-Length(ASubStr)<0 then exit;
  if Length(ASubStr)>Length(AStr) then exit;
  if APos+Length(ASubStr)-1>Length(AStr)
  then _ps:=Length(AStr)-Length(ASubStr)+1
  else _ps:=APos;
  for i:=_ps downto 1 do
    if LowerCase(Copy(AStr,i,Length(ASubStr)))=LowerCase(ASubStr) then begin Result:=i;exit;end;
end;

function KRRightFrom(AText: String; APos: integer): String;
begin
  Result:=RightStr(AText,Length(AText)-APos+1);
end;

function KRRightFrom(AText, AST: String): String;
var _ps: integer;
begin
  Result:='';
  _ps:=KRBackPos(AST,AText);
  if _ps=0 then exit;
  Result:=KRRightFrom(AText,_ps+Length(AST));
end;

function KRRightFromC(AText, AST: String): String;
var _ps: integer;
begin
  Result:='';
  _ps:=KRBackPosC(AST,AText);
  if _ps=0 then exit;
  Result:=KRRightFrom(AText,_ps+Length(AST));
end;

function KRLeftTo(AText, AST: String): String;
var _ps: integer;
begin
  Result:='';
  _ps:=Pos(AST,AText);
  if _ps=0 then exit;
  Result:=LeftStr(AText,_ps-1);
end;

function KRLeftToC(AText, AST: String): String;
var _ps: integer;
begin
  Result:='';
  _ps:=KRPosC(AST,AText);
  if _ps=0 then exit;
  Result:=LeftStr(AText,_ps-1);
end;

function KRCopyFromTo(AText: String;APos0,APos1: Integer): String;
begin
  Result:=Copy(AText,APos0,APos1-APos0+1);
end;

function KRCopyFromTo(AText, ASTBg: String; APosEd, APos: Integer): String;
var _ps: integer;
begin
  Result:='';
  _ps:=PosEx(ASTBg,AText,APos);
  if _ps=0 then exit;
  result:=KRCopyFromTo(AText,_ps+Length(ASTBg),APosEd);
end;

function KRCopyFromTo(AText, ASTBg: String; APosEd: integer): String;
begin
  Result:=KRCopyFromTo(AText, ASTBg, APosEd, 1);
end;

function KRCopyFromTo(AText: String;APosBg: Integer;ASTEd: String;out OPos: integer): String;
var _ps: integer;
begin
  Result:='';
  OPos:=APosBg;
  _ps:=PosEx(ASTEd,AText,APosBg)-1;
  if _ps=-1 then _ps:=Length(AText);
  OPos:=_ps;
  Result:=KRCopyFromTo(AText,APosBg,OPos);
  Inc(OPos);
end;

function KRCopyFromTo(AText: String;APosBg: Integer;ASTEd: String): String;
var _ps: integer;
begin
  Result:=KRCopyFromTo(AText,APosBg,ASTEd,_ps);
end;

function KRCopyFromTo(AText, ASTBg, ASTEd: String; APos: integer;out OPos: integer): string;
var _ps0,_ps1: integer;
begin
  Result:='';
  OPos:=APos;
  _ps0:=PosEx(ASTBg,AText,APos);
  if _ps0=0 then exit;
  Inc(_ps0,Length(ASTBg));
  _ps1:=PosEx(ASTEd,AText,_ps0)-1;
  if _ps1=-1 then _ps1:=Length(AText);
  OPos:=_ps1;
  Result:=KRCopyFromTo(AText,_ps0,_ps1);
  Inc(OPos);
end;

function KRCopyFromTo(AText, ASTBg, ASTEd: String; APos: integer): string;
var _ps: integer;
begin
  Result:=KRCopyFromTo(AText,ASTBg,ASTEd,APos,_ps);
end;

function KRCopyFromTo(AText, ASTBg, ASTEd: String): string;
var _ps: integer;
begin
  Result:=KRCopyFromTo(AText, ASTBg, ASTEd, 1,_ps);
end;

function KRCopyFromToC(AText, ASTBg: String; APosEd, APos: Integer): String;
var _ps: integer;
begin
  Result:='';
  _ps:=KRPosExC(ASTBg,AText,APos);
  if _ps=0 then exit;
  result:=KRCopyFromTo(AText,_ps+Length(ASTBg),APosEd);
end;

function KRCopyFromToC(AText, ASTBg: String; APosEd: integer): String;
begin
  result:=KRCopyFromToC(AText, ASTBg, APosEd, 1);
end;

function KRCopyFromToC(AText: String;APosBg: Integer;ASTEd: String;out OPos: integer): String;
var _ps: integer;
begin
  Result:='';
  OPos:=APosBg;
  _ps:=KRPosExC(ASTEd,AText,APosBg)-1;
  if _ps=-1 then _ps:=Length(AText);
  OPos:=_ps;
  Result:=KRCopyFromTo(AText,APosBg,OPos);
  Inc(OPos);
end;

function KRCopyFromToC(AText: String;APosBg: Integer;ASTEd: String): String;
var _ps: integer;
begin
  Result:=KRCopyFromToC(AText,APosBg,ASTEd,_ps);
end;

function KRCopyFromToC(AText, ASTBg, ASTEd: String; APos: integer;out OPos: integer): string;
var _ps0,_ps1: integer;
begin
  Result:='';
  OPos:=APos;
  _ps0:=KRPosExC(ASTBg,AText,APos);
  if _ps0=0 then exit;
  Inc(_ps0,Length(ASTBg));
  _ps1:=KRPosExC(ASTEd,AText,_ps0)-1;
  if _ps1=-1 then _ps1:=Length(AText);
  OPos:=_ps1;
  Result:=KRCopyFromTo(AText,_ps0,_ps1);
  Inc(OPos);
end;

function KRCopyFromToC(AText, ASTBg, ASTEd: String; APos: integer): string;
var _ps: integer;
begin
  Result:=KRCopyFromToC(AText,ASTBg,ASTEd,APos,_ps);
end;

function KRCopyFromToC(AText, ASTBg, ASTEd: String): string;
var _ps: integer;
begin
  Result:=KRCopyFromToC(AText, ASTBg, ASTEd, 1,_ps);
end;

function KRCutFromTo(AText, ASTBg, ASTEd: String): string;
var
  n,n1: integer;
begin
  n:=Pos(ASTBg,AText);
  if n>0 then begin
    n1:=Pos(ASTEd,AText);
    if n1=0 then begin
      result:=LeftStr(AText,n-1);
      exit;
    end;
    result:=LeftStr(AText,n-1)+RightStr(AText,Length(AText)-n1-Length(ASTEd)+1);
    exit;
  end;
  n:=Pos(ASTEd,AText);
  if n=0 then begin
    result:=AText;
    exit;
  end;
  result:=RightStr(AText,Length(AText)-n-Length(ASTEd)+1);
end;

function KRCutFromTo(AText, ASTBg, ASTEd: String; out ACutStr: String): string;
var
  n,n1: integer;
begin
  n:=Pos(ASTBg,AText);
  if n>0 then begin
    n1:=Pos(ASTEd,AText);
    if n1=0 then begin
      ACutStr:=RightStr(AText,Length(AText)-n+1);
      result:=LeftStr(AText,n-1);
      exit;
    end;
    ACutStr:=Copy(AText,n,n1+Length(ASTEd)-n);
    result:=LeftStr(AText,n-1)+RightStr(AText,Length(AText)-n1-Length(ASTEd)+1);
    exit;
  end;
  n:=Pos(ASTEd,AText);
  if n=0 then begin
    ACutStr:='';
    result:=AText;
    exit;
  end;
  ACutStr:=LeftStr(AText,n+Length(ASTEd)-1);
  result:=RightStr(AText,Length(AText)-n-Length(ASTEd)+1);
end;

procedure KRSplitStr(AText, ADlm: String; AStrings: TStrings);
var
  _ps0,_ps1, i: integer;
begin
  AStrings.Clear;
  if ADlm='' then
    for i:=1 to Length(AText) do AStrings.Add(AText[i])
  else begin
    _ps0:=1;
    _ps1:=Pos(ADlm,AText);
    while _ps1>0 do begin
      AStrings.Add(KRCopyFromTo(ATExt,_ps0,_ps1-1));
      _ps0:=_ps1+Length(ADlm);
      _ps1:=PosEx(ADlm,AText,_ps0);
    end;
    AStrings.Add(KRCopyFromTo(ATExt,_ps0,Length(AText)));
  end;
end;

procedure KRSplitStrC(AText, ADlm: String; AStrings: TStrings);
var
  _ps0,_ps1, i: integer;
begin
  AStrings.Clear;
  if ADlm='' then
    for i:=1 to Length(AText) do AStrings.Add(AText[i])
  else begin
    _ps0:=1;
    _ps1:=KRPosC(ADlm,AText);
    while _ps1>0 do begin
      AStrings.Add(KRCopyFromTo(ATExt,_ps0,_ps1-1));
      _ps0:=_ps1+Length(ADlm);
      _ps1:=KRPosExC(ADlm,AText,_ps0);
    end;
    AStrings.Add(KRCopyFromTo(ATExt,_ps0,Length(AText)));
  end;
end;

function KRUTF8ToStr(Value: String): String;
var
  buffer: PWideChar;
  BufLen: LongWord;
begin
  BufLen := Length(Value)*2 + 4;
  GetMem(buffer, BufLen);
  FillChar(buffer^, BufLen, 0);
  MultiByteToWideChar(CP_UTF8, 0, @Value[1], BufLen - 4, buffer, BufLen);
  Result := WideCharToString(buffer);
  FreeMem(buffer, BufLen);
end;

function KRUTF8ToStrSmart(Value: String): String;
var
  Digit: String;
  i: LongWord;
  HByte: Byte;
  Len: Byte;
begin
  Result := '';
  Len := 0;
  if Value = '' then Exit;
  for i := 1 to Length(Value) do
  begin
    if Len > 0 then
    begin
      Digit := Digit + Value[i];
      Dec(Len);
      if Len = 0 then
        Result := Result + KRUTF8ToStr(Digit);
    end else
    begin
      HByte := Ord(Value[i]);
      if HByte in [$00..$7f] then       //Standart ASCII chars
        Result := Result + Value[i]
      else begin
        //Get length of UTF-8 char
        if HByte and $FC = $FC then
          Len := 6
        else if HByte and $F8 = $F8 then
          Len := 5
        else if HByte and $F0 = $F0 then
          Len := 4
        else if HByte and $E0 = $E0 then
          Len := 3
        else if HByte and $C0 = $C0 then
          Len := 2
        else begin
          Result := Result + Value[i];
          Continue;
        end;
        Dec(Len);
        Digit := Value[i];
      end;
    end;
  end;
end;

initialization
  {$IFDEF KR_USE_ASM}
    KRDefaultSystemCodePage := GetACP;
    KRDefaultUnicodeCodePage := 1200;
  {$ENDIF}
end.
