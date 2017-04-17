unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DxPngFormUI, Registry, IniFiles, ShellAPI, ShlObj, StrUtils, TlHelp32,
  IOUtils, Vcl.ExtCtrls;

type
  TForm2 = class(TForm)
    DxFormPngUIEngine1: TDxFormPngUIEngine;
    DxPngUIButton5: TDxPngUIButton;
    DxPngUIButton2: TDxPngUIButton;
    DxPngUIButton1: TDxPngUIButton;
    DxPngUIButton3: TDxPngUIButton;
    DxPngUIButton4: TDxPngUIButton;
    DxPngUIButton6: TDxPngUIButton;
    DxButtonSkin1: TDxButtonSkin;
    DxUISkins1: TDxUISkins;
    DxPngProgress1: TDxPngProgress;
    Timer1: TTimer;
    procedure DxPngUIButton2Click(Sender: TObject);
    procedure DxPngUIButton5Click(Sender: TObject);
    procedure DxPngUIButton1Click(Sender: TObject);
    procedure DxPngUIButton3Click(Sender: TObject);
    procedure DxPngUIButton6Click(Sender: TObject);
    procedure DxPngUIButton4Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
  public
  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}
procedure CutDir(Source,Dest: string);
var
  fo: TSHFILEOPSTRUCT;
begin
  if DirectoryExists(Source) then
  begin
    FillChar(fo, SizeOf(fo), 0);
    with fo do
    begin
      Wnd := 0;
      wFunc := FO_Move;
      pFrom := PChar(source+#0#0);
      pTo := Pchar(Dest+#0#0);
      fFlags := FOF_NOCONFIRMATION + FOF_SILENT;
    end;
    SHFileOperation(fo);
  end;
end;

procedure TForm2.DxPngUIButton1Click(Sender: TObject);
begin
  Showmessage('大脚启动');
  Close;
end;

procedure TForm2.DxPngUIButton2Click(Sender: TObject);
begin
  Showmessage('Open');
  Close;
end;

procedure TForm2.DxPngUIButton3Click(Sender: TObject);
begin
  Showmessage('合资启动');
end;

procedure TForm2.DxPngUIButton4Click(Sender: TObject);
begin
  Showmessage('有爱启动');
end;

procedure TForm2.DxPngUIButton5Click(Sender: TObject);
begin
  Close;
end;

procedure TForm2.DxPngUIButton6Click(Sender: TObject);
begin
  close;
end;


procedure TForm2.Timer1Timer(Sender: TObject);
begin
  DxPngProgress1.Position := DxPngProgress1.Position + 1;
  if DxPngProgress1.Position = 100 then
    DxPngProgress1.Position := 0;
end;

end.
