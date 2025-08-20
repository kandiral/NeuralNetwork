unit MainUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, mt19937, Vcl.StdCtrls, KRStrUtils;

type
  TMainForm = class(TForm)
    ListBox1: TListBox;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

procedure TMainForm.Button1Click(Sender: TObject);
var
  s: Single;
  d: Double;
  ex: Extended;
  rnd: TMT19937;

  i: int32;
begin
  ex := 1;
  ListBox1.Items.Add( 'Extended: [' + KRUint16ToAHexU( PWord( NativeUInt( @ex ) + 8 )^ ) +
    KRUint64ToAHexU( PUInt64( @ex )^ ) + '] ' + FloatToStr( ex ) );

  rnd := TMT19937.Create;
  rnd.Seed := 5489;
  rnd.Init;

  ListBox1.Items.Add( KRUInt32ToStr( rnd.Next32 ) );
  ListBox1.Items.Add( KRUInt32ToStr( rnd.Next32 ) );
  ListBox1.Items.Add( KRUInt32ToStr( rnd.Next32 ) );
  ListBox1.Items.Add( KRUInt32ToStr( rnd.Next32 ) );
  ListBox1.Items.Add( KRUInt32ToStr( rnd.Next32 ) );

  rnd.Init;
  s := rnd.NextSingle;
  ListBox1.Items.Add( 'Single: [' + KRUint32ToAHexU( PCardinal( @s )^ ) + '] ' + FloatToStr( s ) );
  rnd.Next32;
  s := rnd.NextSingle;
  ListBox1.Items.Add( 'Single: [' + KRUint32ToAHexU( PCardinal( @s )^ ) + '] ' + FloatToStr( s ) );
  rnd.Next32;
  s := rnd.NextSingle;
  ListBox1.Items.Add( 'Single: [' + KRUint32ToAHexU( PCardinal( @s )^ ) + '] ' + FloatToStr( s ) );

  rnd.Init;
  d := rnd.NextDouble;
  ListBox1.Items.Add( 'Double: [' + KRUint64ToAHexU( PUInt64( @d )^ ) + '] ' + FloatToStr( d ) );
  d := rnd.NextDouble;
  ListBox1.Items.Add( 'Double: [' + KRUint64ToAHexU( PUInt64( @d )^ ) + '] ' + FloatToStr( d ) );
  d := rnd.NextDouble;
  ListBox1.Items.Add( 'Double: [' + KRUint64ToAHexU( PUInt64( @d )^ ) + '] ' + FloatToStr( d ) );

  rnd.Init;
  ex := rnd.NextExtended;
  ListBox1.Items.Add( 'Extended: [' + KRUint16ToAHexU( PWord( NativeUInt( @ex ) + 8 )^ ) +
    KRUint64ToAHexU( PUInt64( @ex )^ ) + '] ' + FloatToStr( ex ) );
  ex := rnd.NextExtended;
  ListBox1.Items.Add( 'Extended: [' + KRUint16ToAHexU( PWord( NativeUInt( @ex ) + 8 )^ ) +
    KRUint64ToAHexU( PUInt64( @ex )^ ) + '] ' + FloatToStr( ex ) );
  ex := rnd.NextExtended;
  ListBox1.Items.Add( 'Extended: [' + KRUint16ToAHexU( PWord( NativeUInt( @ex ) + 8 )^ ) +
    KRUint64ToAHexU( PUInt64( @ex )^ ) + '] ' + FloatToStr( ex ) );

  for I := 0 to 1000 do begin
    ListBox1.Items.Add( FloatToStr( rnd.NextExtended ) );
  end;
end;

end.
