unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DxPngFormUI,Unit2;

type
  TForm1 = class(TForm)
    DxFormPngUIEngine1: TDxFormPngUIEngine;
    DxPngFormControl1: TDxPngFormControl;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

end.
