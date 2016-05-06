unit DxSkinConsts;

interface
uses Windows,Messages,Classes,SysUtils,Controls,Graphics,Forms,pngimage2010;
{$R DefaultSkin.res}
{$R Drag.RES}

type
  TDxViewBackStyle = (VS_Fill,VS_Stretch,VS_None);

  TDxCBButton = record //右边按扭
    R: TRect;
    MouseIn: Boolean;
    Down: Boolean;
  end;
  TDxSkinComboboxStyle = (DxcbEditStyle, DxcbFixedStyle);
  TDrawButtonEvent = procedure(Sender: TObject;Button: TDxCBButton) of object;

const
  WM_GetFormBack = WM_USER + 2012;
  crHandCursor = 1;

function GetAsFormRect(C: TControl): TRect;
function RectWidth(r: TRect): Integer;
function RectHeight(r: TRect): Integer;
procedure GetParentImage(Control: TControl; Dest: TCanvas);
function divmod(x,y: Integer;var modvalue: Integer): Integer;
procedure TransparentDraw(DestCanvas,SourceCanvas: TCanvas;DestRect,SourceRect: TRect;TransparentColor: TColor);
procedure MakeBmp(BmpIn: Graphics.TBitmap; var AverageColor: TColorRef);

var
  FormSkinPic,SysBtnBackPic,SysBtnPic: TDxPngImage;
  btnDownPic,BtnInPic,GameBtnDownPic,GameBtnMovePic: TDxPngImage;
  TBtnDownPic,TBtnInPic,DragPic{,SearchPng}: TDxPngImage;
  NewSearch,NewSearchA: TDxPngImage;
  MenuPng: TDxPngImage;
  TpBtnDown,TpBtnMove: TDxPngImage;
  ProgBack,ProgForward,ProgPos: TDxPngImage;
  //SearchBmp: TBitmap;
implementation
{$R NewSkin.RES}

procedure TransparentDraw(DestCanvas,SourceCanvas: TCanvas;DestRect,SourceRect: TRect;TransparentColor: TColor);
begin
  TransparentBlt(DestCanvas.Handle,DestRect.Left,DestRect.Top,RectWidth(DestRect),RectHeight(DestRect),
             SourceCanvas.Handle,SourceRect.Left,SourceRect.Top,RectWidth(SourceRect),RectHeight(SourceRect),
             TransparentColor);
end;

{$IFDEF CPUX64}
function divmod(x,y: Integer;var modvalue: Integer): Integer;
begin
  Result := x div y;
  modvalue := x mod y;
end;
{$ELSE}
function divmod(x,y: Integer;var modvalue: Integer): Integer;
asm
  push ecx
  mov ecx,edx
  xor edx,edx
  div ecx
  pop ecx
  mov [ecx],edx
end;
{$ENDIF}

function RectWidth(r: TRect): Integer;
begin
  Result := r.Right - r.Left;
end;

function RectHeight(r: TRect): Integer;
begin
  Result := r.Bottom - r.Top;
end;

type
  TParentControl = class(TWinControl);

procedure GetParentImage(Control: TControl; Dest: TCanvas);
var
  I, Count, X, Y, SaveIndex: Integer;
  DC: HDC;
  R, SelfR, CtlR: TRect;
begin
  if (Control = nil) or (Control.Parent = nil) then Exit;
  Count := Control.Parent.ControlCount;
  DC := Dest.Handle;
  with Control.Parent do ControlState := ControlState + [csPaintCopy];
  try
    with Control do begin
      SelfR := Bounds(Left, Top, Width, Height);
      X := -Left; Y := -Top;
    end;
    SaveIndex := SaveDC(DC);
    try
      SetViewportOrgEx(DC, X, Y, nil);
      IntersectClipRect(DC, 0, 0, Control.Parent.ClientWidth,
        Control.Parent.ClientHeight);
       if (Control.Parent is TForm) and
          (TForm(Control.Parent).FormStyle = fsMDIForm)
       then
         begin
           SendMessage(TForm(Control.Parent).ClientHandle, WM_ERASEBKGND, DC, 0);
         end
      else
      with TParentControl(Control.Parent) do
      begin
        Perform(WM_ERASEBKGND, DC, 0);
        //if not (Control.Parent is TForm) then
        PaintWindow(DC);
      end;
    finally
      RestoreDC(DC, SaveIndex);
    end;

    for I := 0 to Count - 1 do
    if Control.Parent.Controls[I] <> Control
    then
    begin
      if (Control.Parent.Controls[I] <> nil) and
         (Control.Parent.Controls[I] is TGraphicControl)
      then
      begin
        with TGraphicControl(Control.Parent.Controls[I]) do begin
          CtlR := Bounds(Left, Top, Width, Height);
          if Bool(IntersectRect(R, SelfR, CtlR)) and Visible then begin
            ControlState := ControlState + [csPaintCopy];
            SaveIndex := SaveDC(DC);
            try
              SaveIndex := SaveDC(DC);
              SetViewportOrgEx(DC, Left + X, Top + Y, nil);
              IntersectClipRect(DC, 0, 0, Width, Height);
              Perform(WM_PAINT, DC, 0);
            finally
              RestoreDC(DC, SaveIndex);
              ControlState := ControlState - [csPaintCopy];
            end;
          end;
        end;
      end
    end
    else
      Break;
  finally
    with Control.Parent do ControlState := ControlState - [csPaintCopy];
  end;
end;

procedure GetParentImageRect(Control: TControl; Rct: TRect; Dest: TCanvas);
var
  I, Count, X, Y, SaveIndex: Integer;
  DC: HDC;
  R, SelfR, CtlR: TRect;
begin
  if (Control = nil) or (Control.Parent = nil) then Exit;
  Count := Control.Parent.ControlCount;
  DC := Dest.Handle;
  with Control.Parent do ControlState := ControlState + [csPaintCopy];
  try
    with Control do begin
      SelfR := Bounds(Left, Top, Width, Height);
      X := -Left - Rct.Left; Y := -Top - Rct.Top;
    end;
    { Copy parent control image }
    SaveIndex := SaveDC(DC);
    try
      SetViewportOrgEx(DC, X, Y, nil);
      IntersectClipRect(DC, 0, 0, Control.Parent.ClientWidth,
        Control.Parent.ClientHeight);
      if (Control.Parent is TForm) and
         (TForm(Control.Parent).FormStyle = fsMDIForm)
       then
         begin
           SendMessage(TForm(Control.Parent).ClientHandle, WM_ERASEBKGND, DC, 0);
         end
      else
      with TParentControl(Control.Parent) do begin
        Perform(WM_ERASEBKGND, DC, 0);
        if not (Control.Parent is TForm) then
          PaintWindow(DC);
      end;
    finally
      RestoreDC(DC, SaveIndex);
    end;

    for I := 0 to Count - 1 do
    if Control.Parent.Controls[I] <> Control
    then
    begin
      if (Control.Parent.Controls[I] <> nil) and
         (Control.Parent.Controls[I] is TGraphicControl)
      then
      begin
        with TGraphicControl(Control.Parent.Controls[I]) do begin
          CtlR := Bounds(Left, Top, Width, Height);
          if Bool(IntersectRect(R, SelfR, CtlR)) and Visible then begin
            ControlState := ControlState + [csPaintCopy];
            SaveIndex := SaveDC(DC);
            try
              SaveIndex := SaveDC(DC);
              SetViewportOrgEx(DC, Left + X, Top + Y, nil);
              IntersectClipRect(DC, 0, 0, Width, Height);
              Perform(WM_PAINT, DC, 0);
            finally
              RestoreDC(DC, SaveIndex);
              ControlState := ControlState - [csPaintCopy];
            end;
          end;
        end;
      end
    end
    else
      Break;
  finally
    with Control.Parent do ControlState := ControlState - [csPaintCopy];
  end;
end;

function GetAsFormRect(C: TControl): TRect;
var
  AParent: TWinControl;
  r: TRect;
begin
  AParent := C.Parent;
  Result := C.BoundsRect;
  while AParent <> nil do
  begin
    r := AParent.BoundsRect;
    AParent := AParent.Parent;
    if AParent = nil then
      Break;
    Result.Left := Result.Left + r.Left;
    Result.Top := Result.Top + r.Top;
    Result.Right := Result.Right + r.Left;
    Result.Bottom := Result.Bottom + r.Top;
  end;
end;


procedure FillSolidRect(m_hDC: HDC; lpRect: PRect; clr: COLORREF); overload;
begin
  Windows.SetBkColor(m_hDC, clr);
  Windows.ExtTextOut(m_hDC, 0, 0, ETO_OPAQUE, lpRect, nil, 0, nil);
end;

procedure FillSolidRect(m_hDC: HDC; x, y, cx, cy: Integer; clr: COLORREF); overload;
var
  r: TRect;
begin
  Windows.SetBkColor(m_hDC, clr);
  r := Rect(x, y, x + cx, y + cy);
  Windows.ExtTextOut(m_hDC, 0, 0, ETO_OPAQUE, @r, nil, 0, nil);
end;

const
  m_nOverRegio: integer = 100; //过度的大小

procedure DrawBKImageCross(dc, dcTemp: HDC; nWidth, nHeight: integer; clrCustomBK: TColorRef);
var
  blend: TBlendFunction;
  nStartX, nStartY: integer;
  i, j: integer;
  dRadiusTemp2: Double;
begin

  FillChar(blend, sizeof(blend), 0);
  blend.BlendOp := AC_SRC_OVER;
  blend.SourceConstantAlpha := 255;

  nStartX := nWidth - m_nOverRegio;
  nStartY := nHeight - m_nOverRegio;

  FillSolidRect(dc, nStartX, nStartY, m_nOverRegio, m_nOverRegio, clrCustomBK);
  for i := 0 to m_nOverRegio - 1 do
  begin
    for j := 0 to m_nOverRegio - 1 do
    begin
      dRadiusTemp2 := sqrt((i * i + j * j));
      if (dRadiusTemp2 > 99) then
      begin
        dRadiusTemp2 := 99;
      end;
      blend.SourceConstantAlpha := 255 - Round(2.55 * ((dRadiusTemp2 / m_nOverRegio) * 100));
      Windows.AlphaBlend(dc, nStartX + i, nStartY + j, 1, 1, dcTemp, nStartX + i, nStartY + j, 1, 1, blend);
    end;
  end;
end;

function DrawVerticalTransition(dcDes, dcSrc: hdc; const rc: TRect; nBeginTransparent: integer = 0; nEndTransparent: integer = 100): integer;
var
  bIsDownTransition: Boolean;
  nTemp: integer;
  blend: TBlendFunction;
  nStartPosition, nWidth, nHeight, nMinTransition, nMaxTransition: integer;
  dTransition: Double;
  i: integer;
begin
  bIsDownTransition := True;
  if (nEndTransparent <= nBeginTransparent) then
  begin
    bIsDownTransition := FALSE;
    nTemp := nBeginTransparent;
    nBeginTransparent := nEndTransparent;
    nEndTransparent := nTemp;
  end;

  FillChar(blend, sizeof(blend), 0);
  blend.BlendOp := AC_SRC_OVER;
  blend.SourceConstantAlpha := 255;

  nStartPosition := rc.top;
  nWidth := rc.right - rc.left;
  nHeight := rc.bottom - rc.top;

  nMinTransition := 255 - 255 * nBeginTransparent div 100;
  nMaxTransition := 255 * (100 - nEndTransparent) div 100;
  dTransition := (nMinTransition - nMaxTransition) / nHeight;
  if (bIsDownTransition) then
  begin
    for i := 0 to nHeight - 1 do
    begin
      blend.SourceConstantAlpha := nMinTransition - Round(dTransition * i);
      Windows.AlphaBlend(dcDes, rc.left, nStartPosition + i, nWidth, 1,
        dcSrc, rc.left, nStartPosition + i, nWidth, 1, blend);
    end;
  end
  else
  begin
    for i := 0 to nHeight - 1 do
    begin
      blend.SourceConstantAlpha := nMaxTransition + Round(dTransition * i);
      Windows.AlphaBlend(dcDes, rc.left, nStartPosition + i, nWidth, 1,
        dcSrc, rc.left, nStartPosition + i, nWidth, 1, blend);
    end;
  end;
  Result := blend.SourceConstantAlpha;
end;

procedure BlendBmp(BmpFrom, BmpTo: TBitmap; var Bmp: TBitmap; BlendValue: Byte);
var
  I, J: Integer;
  P, PFrom, PTo: PByteArray;
begin
  BmpFrom.PixelFormat := pf24bit;
  BmpTo.PixelFormat := pf24bit;
  Bmp.PixelFormat := pf24Bit;
  for J := 0 to Bmp.Height - 1 do
  begin
    P := Bmp.ScanLine[J];
    PFrom := BmpFrom.ScanLine[J];
    PTo := BmpTo.ScanLine[J];
    for I := 0 to Bmp.Width * 3 - 1 do
      P[I] := PFrom[I] * (255 - BlendValue) div 255 + PTo[I] * BlendValue div 255;
  end;
end;

procedure MakeBmp(BmpIn: Graphics.TBitmap; var AverageColor: TColorRef);
var
  BmpOut: Graphics.TBitmap;
  x, y: Integer;
  P: PRGBTriple;
  r, g, b: Integer;
  n: integer;
  nStartPosition: integer;
  i: integer;
  blend: TBlendFunction;
  rcTemp: TRect;
begin
  BmpIn.PixelFormat := pf24bit;
  BmpOut:=TBitmap.Create;

  //计算平均颜色
  r := 0; g := 0; b := 0;
  with BmpIn do
  begin
    for y := 0 to Height - 1 do
    begin
      P := BmpIn.ScanLine[y];
      for x := 0 to Width - 1 do
      begin
        r := r + P^.rgbtRed;
        g := g + P^.rgbtGreen;
        b := b + P^.rgbtBlue;
        Inc(P); //指向下一个像素
      end;
    end;
  end;
  n := BmpIn.Width * BmpIn.Height;
  AverageColor := RGB(r div n, g div n, b div n);

  BmpOut.Width := BmpIn.Width;
  BmpOut.Height := BmpIn.Height;


  //左上
  nStartPosition := BmpIn.Width - m_nOverRegio;
  BitBlt(BmpOut.Canvas.Handle, 0, 0, nStartPosition, BmpIn.Height - m_nOverRegio, BmpIn.Canvas.Handle, 0, 0, SRCCOPY);

  //上中
  FillSolidRect(BmpOut.Canvas.Handle, nStartPosition, 0, m_nOverRegio, BmpIn.Height - m_nOverRegio, AverageColor);

   //下中
  nStartPosition := BmpIn.Height - m_nOverRegio;
  FillSolidRect(BmpOut.Canvas.Handle, 0, nStartPosition, BmpIn.Width - m_nOverRegio, m_nOverRegio, AverageColor);

   //中间
  DrawBKImageCross(BmpOut.Canvas.Handle, BmpIn.Canvas.Handle, BmpIn.Width, BmpIn.Height, AverageColor);

  FillChar(blend, sizeof(blend), 0);
  blend.BlendOp := AC_SRC_OVER;
  blend.SourceConstantAlpha := 255; // 透明度

  //上中
  nStartPosition := BmpIn.Width - m_nOverRegio;
  for i := 0 to m_nOverRegio - 1 do
  begin
    blend.SourceConstantAlpha := 255 - Round(2.55 * i);
    Windows.AlphaBlend(BmpOut.Canvas.Handle, nStartPosition + i, 0, 1, BmpIn.Height - m_nOverRegio,
      BmpIn.Canvas.Handle, nStartPosition + i, 0, 1, BmpIn.Height - m_nOverRegio, blend);
  end;

  //下中
  rcTemp := Rect(0, BmpIn.Height - m_nOverRegio, BmpIn.Width - m_nOverRegio, BmpIn.Height);
  DrawVerticalTransition(BmpOut.Canvas.Handle, BmpIn.Canvas.Handle, rcTemp);
  BmpIn.Assign(BmpOut);
  BmpOut.Free;
end;


var
  CheckDword: DWORD;
  TimerId: UINT;
procedure DoTimer(hWnd: HWND; uMsg: UINT; idEvent: UINT; Time: DWORD);stdcall;
var
  w: DWORD;
begin
  w := 5 * 60 * 1000;
  if GetTickCount - CheckDword > w then
  begin
    KillTimer(hWnd,TimerId);
    Application.Terminate;
  end;
end;

initialization
  FormSkinPic := TDxPngImage.Create;
  FormSkinPic.LoadFromResourceName(Hinstance,'FormSkin');
  SysBtnBackPic := TDxPngImage.Create;
  SysBtnBackPic.LoadFromResourceName(Hinstance,'SysBtnBack');
  SysBtnPic := TDxPngImage.Create;
  SysBtnPic.LoadFromResourceName(Hinstance,'SysBtn');
  btnDownPic := TDxPngImage.Create;
  btnDownPic.LoadFromResourceName(HInstance,'button_mouseclick');
  BtnInPic := TDxPngImage.Create;
  BtnInPic.LoadFromResourceName(HInstance,'button_mousemove');
  TBtnDownPic := TDxPngImage.Create;
  TBtnDownPic.LoadFromResourceName(HInstance,'toolbutton_mouseclick');
  TBtnInPic := TDxPngImage.Create;
  TBtnInPic.LoadFromResourceName(HInstance,'toolbutton_mousemove');
  DragPic := TDxPngImage.Create;
  DragPic.LoadFromResourceName(Hinstance,'Drag');
  MenuPng := TDxPngImage.Create;
  MenuPng.LoadFromResourceName(HInstance,'Menu');

  GameBtnDownPic := TDxPngImage.Create;
  GameBtnDownPic.LoadFromResourceName(HInstance,'GameBtnDown');
  GameBtnMovePic := TDxPngImage.Create;
  GameBtnMovePic.LoadFromResourceName(Hinstance,'GameBtnMove');

  NewSearch := TDxPngImage.Create;
  NewSearch.LoadFromResourceName(HInstance,'Search_N');
  NewSearchA := TDxPngImage.Create;
  NewSearchA.LoadFromResourceName(HInstance,'Search_A');

  TpBtnDown := TDxPngImage.Create;
  TpBtnDown.LoadFromResourceName(HInstance,'TpBtnDown');
  TpBtnMove := TDxPngImage.Create;
  TpBtnMove.LoadFromResourceName(HInstance,'TpBtnMove');

  ProgBack := TDxPngImage.Create;
  ProgBack.LoadFromResourceName(HInstance,'ProgBack');
  ProgForward := TDxPngImage.Create;
  ProgForward.LoadFromResourceName(HInstance,'ProgForward');

  ProgPos := TDxPngImage.Create;
  ProgPos.LoadFromResourceName(HInstance,'ProgPos');

finalization
  FormSkinPic.Free;
  SysBtnBackPic.Free;
  SysBtnPic.Free;
  btnDownPic.Free;
  BtnInPic.Free;
  TBtnDownPic.Free;
  TBtnInPic.Free;
  DragPic.Free;
  MenuPng.Free;
  GameBtnDownPic.Free;
  GameBtnMovePic.Free;
  NewSearch.Free;
  NewSearchA.Free;
  TpBtnDown.Free;
  TpBtnMove.Free;
  ProgForward.Free;
  ProgBack.Free;
  ProgPos.Free;
end.
