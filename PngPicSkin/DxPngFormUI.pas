unit DxPngFormUI;

{
  本源码来自DxPngPicSkin项目，版权归不得闲(QQ:75492895)所有。
  (1)使用许可及限制
  您可以自由复制、分发、修改本源码，但您的修改应该反馈给作者，并允许作者在必要时，
  合并到本项目中以供使用，合并后的源码同样遵循DxPngPicSkin版权声明限制。
  您的产品的关于中，应包含以下的版本声明:
  本产品使用的异形UI来自DxPngPicSkin项目中，版权归作者所有。
  (2)、技术支持
  有技术问题，您可以联系作者，暂时没有官方群。。
  (3)、赞助
  您可以自由使用本源码而不需要支付任何费用。如果您觉得本源码对您有帮助，您可以赞
  助本项目（非强制）：
  赞助方式：
  支付宝： 75492895@qq.com 姓名：胡平
  (4)、声明
  本产品中用到了毛泽发前辈的GDIPlus的封装库。感谢毛泽发前辈。
}
{
 本单元主要是提供异形UI引擎,和一些基础控件
 TDxFormPngUIEngine：异形引擎，异形界面上的所有UI都要指定本属性
 TDxPngUIControl：异形界面的基础控件，如果要编写新控件，可以从本控件继承
 TDxPngUIButton等就是一些实现的UI控件了。
}

interface

{$if CompilerVersion < 22}
  {$MESSAGE FATAL '本控件只支持XE及其XE之后的版本.'}
{$ifend}
uses Windows,Classes,Messages,SysUtils, Forms,Controls,Graphics,ExtCtrls,
DxSkinConsts,Gdiplus,pngimage2010,Generics.Collections,Menus;

type
  TDxPngUIControl = class;
  TDxUISkins = class;
  TDxUISkin = class;
  TDxFormPngUIEngine = class(TComponent)
  private
    FForm: TForm;
    LinkPngControls: TList;
    FUpCount: Integer;
    FCanMoveForm: Boolean;
    FBackPng: TDxPngImage;
    OldWndProc: TWndMethod;
    FUsePicSize: Boolean;
    FBackTopCenter: Boolean;
    FUseGDIExStyle: Boolean;
    FActiveControl: TDxPngUIControl;
    LockMsgToTargControl: Boolean;
    FAlphaByte: Byte;
    FUISkins: TDxUISkins;
    procedure SetBackPng(Value: TDxPngImage);
    procedure SetBackTopCenter(const Value: Boolean);
    procedure SetUserGDIExStyle(const Value: Boolean);
    procedure SetAlphaByte(const Value: Byte);
    procedure SetUISkins(const Value: TDxUISkins);
  protected
    procedure DoPicChange(Sender: TObject);
    procedure WndProc(var msg: TMessage);virtual;
    procedure DoPaintBackGround(Cvs: TCanvas;AGraphics: TGpGraphics);virtual;
    procedure DoMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Loaded;override;
    procedure Notification(AComponent: TComponent; Operation: TOperation);override;
  public
    procedure UpdateLayered;
    constructor Create(AOwner: TComponent);override;
    destructor Destroy;override;
    function FindControlAtPoint(p: TPoint): TDxPngUIControl;
    procedure BeginUpdate;
    procedure EndUpdate;
    function  ControlSkin(Control: TDxPngUIControl): TDxUISkin;
  published
    property CanMoveForm: Boolean read FCanMoveForm write FCanMoveForm;
    property BackPng: TDxPngImage read FBackPng write SetBackPng;
    property UsePicSize: Boolean read FUsePicSize write FUsePicSize default True;
    property BackTopCenter: Boolean read FBackTopCenter write SetBackTopCenter default False;
    property UseGDIExStyle: Boolean read FUseGDIExStyle write SetUserGDIExStyle;
    property AlphaByte: Byte read FAlphaByte write SetAlphaByte default 240;

    property UISkins: TDxUISkins read FUISkins write SetUISkins;
  end;

  TDxPngUIControl = class(TControl)
  private
    FPngUIEngine: TDxFormPngUIEngine;
    FCanvas: TCanvas;
    FTabStop: Boolean;
    FOnKeyPress: TKeyPressEvent;
    FOnKeyDown: TKeyEvent;
    FOnKeyUp: TKeyEvent;
    FIngoreAlpha: Boolean;
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
    procedure SetIngoreAlpha(const Value: Boolean);
  protected
    function DoKeyDown(var Message: TWMKey): Boolean;
    function DoKeyPress(var Message: TWMKey): Boolean;
    function DoKeyUp(var Message: TWMKey): Boolean;

    procedure SetPngUIEngine(Value: TDxFormPngUIEngine);virtual;
    procedure KeyDown(var Key: Word; Shift: TShiftState); dynamic;
    procedure KeyUp(var Key: Word; Shift: TShiftState); dynamic;
    procedure KeyPress(var Key: Char); dynamic;
    procedure SetParent(AParent: TWinControl);override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;
      MousePos: TPoint): Boolean;override;

    procedure WMMOUSEWHEEL(var msg: TWMMouseWheel);message WM_MOUSEWHEEL;
    procedure WMSetFocus(var msg: TWMSetFocus);message WM_SETFOCUS;
    procedure WMKillFocus(var msg: TWMKillFocus);message WM_KILLFOCUS;

    procedure HandKeyMsg(var Msg: TMessage);virtual;
    property OnKeyDown: TKeyEvent read FOnKeyDown write FOnKeyDown;
    property OnKeyPress: TKeyPressEvent read FOnKeyPress write FOnKeyPress;
    property OnKeyUp: TKeyEvent read FOnKeyUp write FOnKeyUp;
    property TabStop: Boolean read FTabStop write FTabStop default False;

    procedure PaintUI(ToCanvas: TCanvas;DestRect: TRect);virtual;
    procedure Paint;virtual;
    procedure CMMouseEnter(var msg: TMessage);message CM_MOUSEENTER;
    procedure CMMouseLeave(var msg: TMessage);message CM_MOUSELEAVE;
    procedure Notification(AComponent: TComponent;Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent);override;
    destructor Destroy;override;
    property Canvas: TCanvas read FCanvas;
    function Focused: Boolean;dynamic;

    procedure SendToBack;
    procedure BringToFront;
  published
    property PngUIEngine: TDxFormPngUIEngine read FPngUIEngine write SetPngUIEngine;
    property IngoreAlpha: Boolean read FIngoreAlpha write SetIngoreAlpha default False; //是否忽略控件自身的透明通道
  end;

  TDxUISkins = class(TComponent)
  private
    FUISkins: TDictionary<string,TDxUISkin>;
    FEngines: TList;
    FUpcount:Integer;
  protected
    procedure Change;dynamic;
    procedure Notification(AComponent: TComponent; Operation: TOperation);override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy;override;
    function GetSkin(C: TDxPngUIControl): TDxUISkin;
    procedure BeginUpdate;
    procedure EndUpdate;
  end;

  //UI控件皮肤
  TDxUISkin = class(TComponent)
  protected
    FUIControlClass: string;
    FUISkins: TDxUISkins;
    procedure SetUISkins(const Value: TDxUISkins);
    procedure DoPicChange(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
  published
    property UISkins: TDxUISkins read FUISkins write SetUISkins;
  end;

  TDxButtonSkin = class(TDxUISkin)
  private
    FMouseDownPng: TDxPngImage;
    FMouseMovePng: TDxPngImage;
    FNormalPng: TDxPngImage;
    procedure SetMouseDownPng(const Value: TDxPngImage);
    procedure SetMouseMovePng(const Value: TDxPngImage);
    procedure SetNormalPng(const Value: TDxPngImage);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy;override;
  published
    property NormalPng: TDxPngImage read FNormalPng write SetNormalPng;
    property MouseDownPng: TDxPngImage read FMouseDownPng write SetMouseDownPng;
    property MouseMovePng: TDxPngImage read FMouseMovePng write SetMouseMovePng;
  end;

  TDxPngUIButton = class(TDxPngUIControl)
  private
    FMouseDownPng: TDxPngImage;
    FMouseMovePng: TDxPngImage;
    FNormalPng: TDxPngImage;
    IsMouseIn: Boolean;
    FTextPng: TDxPngImage;
    IsLDown: Boolean;
    FCapShadowColor: TColor;
    FIcon: TIcon;
    FFlatFrameColor: TColor;
    procedure SetMouseDownPng(const Value: TDxPngImage);
    procedure SetMouseMovePng(const Value: TDxPngImage);
    procedure SetNormalPng(const Value: TDxPngImage);
    procedure SetTextPng(const Value: TDxPngImage);
    procedure SetCapShadowColor(const Value: TColor);
    procedure SetIcon(const Value: TIcon);
    procedure SetFlatFrameColor(const Value: TColor);
  protected
    procedure PaintUI(ToCanvas: TCanvas;DestRect: TRect);override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure CMMouseEnter(var msg: TMessage);message CM_MOUSEENTER;
    procedure CMMouseLeave(var msg: TMessage);message CM_MOUSELEAVE;
    procedure DoPicChange(Sender: TObject);
    procedure DrawCaption(ToCanvas: TCanvas;DestRect: TRect);
    procedure DoIconChange(Sender: TObject);
    procedure Paint;override;

  public
    constructor Create(AOwner: TComponent);override;
    procedure Click;override;
    destructor Destroy;override;
  published
    property Font;
    property OnClick;
    property Icon: TIcon read FIcon write SetIcon;
    property CapShadowColor: TColor read FCapShadowColor write SetCapShadowColor;
    property NormalPng: TDxPngImage read FNormalPng write SetNormalPng;
    property MouseDownPng: TDxPngImage read FMouseDownPng write SetMouseDownPng;
    property MouseMovePng: TDxPngImage read FMouseMovePng write SetMouseMovePng;
    property TextPng: TDxPngImage read FTextPng write SetTextPng;
    property Caption;
    property FlatFrameColor: TColor read FFlatFrameColor write SetFlatFrameColor default clGray;
    property Anchors;
  end;

  TDxDropDownButton = class(TDxPngUIButton)
  private
    FDropDownMenu: TPopupMenu;
    procedure SetDropDownMenu(const Value: TPopupMenu);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation);override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
  published
    property DropDownMenu: TPopupMenu read FDropDownMenu write SetDropDownMenu;
  end;

  TDxPngLabel = class(TDxPngUIControl)
  private
    FShadowColor: TColor;
    procedure SetShadowColor(const Value: TColor);
  protected
    procedure PaintUI(ToCanvas: TCanvas;DestRect: TRect);override;
    procedure CmFontChange(var msg: TMessage);message CM_FONTCHANGED;
    procedure CmTextChange(var msg: TMessage);message CM_TEXTCHANGED;
  published
    property Font;
    property Caption;
    property ShadowColor: TColor read FShadowColor write SetShadowColor;
  end;

  TDxPngProgress = class(TDxPngUIControl)
  private
    FMax: Integer;
    FShowPositionCaption: Boolean;
    FMin: Integer;
    FPosition: Single;
    Step: integer;
    procedure SetMax(const Value: Integer);
    procedure SetMin(const Value: Integer);
    procedure SetPosition(Value: Single);
    procedure SetShowPositionCaption(const Value: Boolean);
  protected
    procedure PaintUI(ToCanvas: TCanvas;DestRect: TRect);override;
    procedure Resize;override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Font;
    //最大值
    property Max: Integer read FMax write SetMax default 100;
    //最小值
    property Min: Integer read FMin write SetMin default 0;
    //当前位置
    property Position: Single read FPosition write SetPosition;
    property ShowPositionCaption: Boolean read FShowPositionCaption write SetShowPositionCaption;
  end;


  TDxCustomPngFormControl = class(TDxPngUIControl)
  private
    procedure SetLinkForm(const Value: TForm);
  protected
    FLinkForm: TForm;
    HasShowWindow: Boolean;
    procedure PaintUI(ToCanvas: TCanvas;DestRect: TRect);override;
    procedure Notification(AComponent: TComponent;Operation: TOperation);override;
    property LinkForm: TForm read FLinkForm write SetLinkForm;
  end;

  TDxPngFormControl = class(TDxCustomPngFormControl)
  published
    property LinkForm;
    property Font;
  end;


implementation

type
  TTargetControl = class(TWinControl);

function MakePoint(x, y: Single): TGpPointF;
begin
  Result.X := x;
  Result.Y := y;
end;

procedure TDxFormPngUIEngine.BeginUpdate;
begin
  Inc(FUpCount);
end;

function TDxFormPngUIEngine.ControlSkin(Control: TDxPngUIControl): TDxUISkin;
begin
  if FUISkins <> nil then
    Result := FUISkins.GetSkin(Control)
  else Result := nil;
end;

constructor TDxFormPngUIEngine.create(AOwner: TComponent);
begin
  inherited;
  FAlphaByte := 240;
  Assert(AOwner.InheritsFrom(TForm));
  LockMsgToTargControl := False;
  FBackTopCenter := False;
  FUsePicSize := True;
  FBackPng := TDxPngImage.Create;
  FUpCount := 1;
  FCanMoveForm := true;
  FForm := TForm(AOwner);
  SetWindowLong(FForm.Handle,GWL_STYLE,GetWindowLong(FForm.Handle,GWL_STYLE) and (not WS_CAPTION) and (not WS_THICKFRAME));
  OldWndProc := FForm.WindowProc;
  FForm.WindowProc := WndProc;
  FForm.OnMouseDown := DoMouseDown;
  FBackPng.OnChange := DoPicChange;
  LinkPngControls := TList.Create;
end;

destructor TDxFormPngUIEngine.Destroy;
begin
  inherited;
  FForm.WindowProc := OldWndProc;
  FBackPng.Free;
  LinkPngControls.Free;
end;

procedure TDxFormPngUIEngine.DoMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  ReleaseCapture;
  SendMessage(FForm.Handle,WM_SYSCOMMAND,SC_MOVE+HTCAPTION,0);
end;

procedure TDxFormPngUIEngine.DoPaintBackGround(Cvs: TCanvas; AGraphics: TGpGraphics);
var
  i: Integer;
  C: TDxPngUIControl;
begin
  for i := 0 to LinkPngControls.Count - 1 do
  begin
    C := LinkPngControls.Items[i];
    C.PaintUI(Cvs,C.BoundsRect);
  end;
end;

procedure TDxFormPngUIEngine.DoPicChange(Sender: TObject);
begin
  if csDesigning in ComponentState then
    FForm.Perform(WM_PAINT,0,0)
  else UpdateLayered;
end;

procedure TDxFormPngUIEngine.EndUpdate;
begin
  Dec(FUpCount);
  if FUpCount <= 0 then
  begin
    FUpCount := 0;
    UpdateLayered;
  end;
end;


function TDxFormPngUIEngine.FindControlAtPoint(p: TPoint): TDxPngUIControl;
var
  i: Integer;
  c: TDxPngUIControl;
begin
  for i := LinkPngControls.Count - 1 downto 0 do
  begin
    C := LinkPngControls.Items[i];
    if PtInRect(C.ClientRect,p) then
    begin
      Result := C;
      Exit;
    end;
  end;
  Result := nil;
end;

procedure TDxFormPngUIEngine.Loaded;
begin
  inherited;
  SetWindowLong(FForm.Handle,GWL_STYLE,GetWindowLong(FForm.Handle,GWL_STYLE) and (not WS_CAPTION) and (not WS_THICKFRAME));
end;

procedure TDxFormPngUIEngine.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if Operation = opRemove  then
  begin
    if AComponent.InheritsFrom(TDxUISkins) then
    begin
      FUISkins := nil;
      TDxUISkins(AComponent).FEngines.Remove(self);
    end;
  end;
end;

procedure TDxFormPngUIEngine.SetAlphaByte(const Value: Byte);
begin
  if FAlphaByte <> Value then
  begin
    FAlphaByte := Value;
    if not (csDesigning in ComponentState) then
      UpdateLayered;
  end;
end;

procedure TDxFormPngUIEngine.SetBackPng(Value: TDxPngImage);
begin
  FBackPng.Assign(Value);
end;

procedure TDxFormPngUIEngine.SetBackTopCenter(const Value: Boolean);
begin
  if FBackTopCenter <> Value then
  begin
    FBackTopCenter := Value;
    if csDesigning in ComponentState then
      FForm.Perform(WM_PAINT,0,0)
    else UpdateLayered;
  end;
end;

procedure TDxFormPngUIEngine.SetUISkins(const Value: TDxUISkins);
begin
  if FUISkins <> Value then
  begin
    if FUISkins <> nil then
    begin
      FUISkins.RemoveFreeNotification(self);
      FUISkins.FEngines.Remove(self);
      RemoveFreeNotification(FUISkins);
    end;
    FUISkins := Value;
    if FUISkins <>  nil then
    begin
      FUISkins.FreeNotification(self);
      FreeNotification(FUISkins);
      FUISkins.FEngines.Add(Self);
    end;
  end;
end;

procedure TDxFormPngUIEngine.SetUserGDIExStyle(const Value: Boolean);
begin
  if FUseGDIExStyle <> Value then
  begin
    FUseGDIExStyle := Value;
    if not (csDesigning in ComponentState) then
      UpdateLayered;
  end;
end;

type
  TdxChunkIHDR = class(TChunkIHDR);

procedure TDxFormPngUIEngine.UpdateLayered;
var
  ptDst, ptSrc: TPoint;
  Size: TSize;
  BlendFunction: TBlendFunction;
  bmp : TBitmap;

  i,x,y: Integer;
  C: TDxPngUIControl;
  r: TRect;

  hdcScreen, hdcMem: HDC;
  bitMem, bitOldMem: HBITMAP;
  Graphics: TGpGraphics;
  Img: TGpBitmap;
  stream: TMemoryStream;
  StreamApter: TStreamAdapter;
  tmpcanvas: TCanvas;
  TRNS: TChunkTRNS;
  pb: pByteArray;
begin
  if (FUpCount > 0) or (csDesigning in ComponentState) or (csDestroying in ComponentState) then Exit;
  if not FUseGDIExStyle then
  begin
    bmp := TBitmap.Create;
    if FUsePicSize then
      bmp.SetSize(FBackPng.Width,FBackPng.Height)
    else bmp.SetSize(FForm.Width,FForm.Height);

    if (FBackPng.TransparencyMode = ptmPartial) then
    begin
      bmp.PixelFormat := pf32bit;
      bmp.AlphaFormat := afDefined;
      bmp.Canvas.Brush.Color := 0;
      bmp.Canvas.FillRect(Bounds(0,0,bmp.Width, bmp.Height));
    end
    else
    begin
      bmp.PixelFormat := pf24bit;
      bmp.AlphaFormat := afIgnored;
    end;
    if FBackPng.Palette <> 0 then
      bmp.Palette := CopyPalette(FBackPng.Palette);
    if (FBackPng.TransparencyMode = ptmBit) then
    begin
      TRNS := FBackPng.Chunks.ItemFromClass(TChunkTRNS) as TChunkTRNS;
      bmp.TransparentColor := TRNS.TransparentColor;
      bmp.Transparent := True;
      SetStretchBltMode(bmp.Canvas.Handle, COLORONCOLOR);
      if FBackTopCenter then
      begin
        StretchDiBits(bmp.Canvas.Handle, (FForm.Width - FBackPng.Width) div 2,0,FBackPng.Width, FBackPng.Height, 0, 0,
          FBackPng.Width, FBackPng.Height, TdxChunkIHDR(FBackPng.Header).ImageData,
          pBitmapInfo(@TdxChunkIHDR(FBackPng.Header).BitmapInfo)^, DIB_RGB_COLORS, SRCCOPY)
      end
      else
      begin
        StretchDiBits(bmp.Canvas.Handle, 0, 0, bmp.Width, bmp.Height, 0, 0,
          bmp.Width, bmp.Height, TdxChunkIHDR(FBackPng.Header).ImageData,
          pBitmapInfo(@TdxChunkIHDR(FBackPng.Header).BitmapInfo)^, DIB_RGB_COLORS, SRCCOPY)
      end;
    end
    else if FBackTopCenter then
    begin
      r.Top := 0;
      r.Left := (FForm.Width - FBackPng.Width) div 2;
      r.Right := r.Left + FBackPng.Width;
      r.Bottom := FBackPng.Height;
      FBackPng.DrawToDest(bmp.Canvas,Rect(0,0,FBackPng.Width,FBackPng.Height),r);
    end
    else bmp.Canvas.Draw(0,0,FBackPng);

    for i := 0 to LinkPngControls.Count - 1 do
    begin
      C := LinkPngControls.Items[i];
      r := c.BoundsRect;
      C.PaintUI(bmp.Canvas,r);
      //重置控件的透明通道
      if C.FIngoreAlpha then      
      for y := r.Top to r.Bottom - 1 do
      begin
        pb := bmp.ScanLine[y];
        for x := r.Left to r.Right - 1 do
          Pb^[(x+1)*4-1] := $FF
      end;
    end;
    ptDst := Point(FForm.Left, FForm.Top);
    ptSrc := Point(0, 0);
    if FUsePicSize then
    begin
      Size.cx := FBackPng.Width;
      Size.cy := FBackPng.Height;
    end
    else
    begin
      Size.cx := FForm.Width;
      Size.cy := FForm.Height;
    end;

    BlendFunction.BlendOp := AC_SRC_OVER;
    BlendFunction.BlendFlags := 0;
    BlendFunction.SourceConstantAlpha := FAlphaByte; // 透明度
    BlendFunction.AlphaFormat := AC_SRC_ALPHA;

    SetWindowLong(FForm.Handle, GWL_EXSTYLE, GetWindowLong(FForm.Handle,
        GWL_EXSTYLE) or WS_EX_LAYERED);
    UpdateLayeredWindow(FForm.Handle,
       FForm.Canvas.Handle,
       @ptDst,
       @Size,
       bmp.Canvas.Handle,
       @ptSrc,
       clRed,
       @BlendFunction,
       ULW_ALPHA);
    bmp.Free();
  end
  else //使用GDI+模式处理
  begin
    stream := TMemoryStream.Create;
    FBackPng.SaveToStream(stream);
    StreamApter := TStreamAdapter.Create(stream);
    Img := TGpBitmap.Create(StreamApter);
    stream.Free;
    hdcScreen := GetDC(FForm.Handle);
    hdcMem := CreateCompatibleDC(hdcScreen);
    if FUsePicSize then
      bitMem := CreateCompatibleBitmap(hdcScreen, Img.Width, Img.Height)
    else
      bitMem := CreateCompatibleBitmap(hdcScreen, FForm.Width, FForm.Height);
    try
      bitOldMem := SelectObject(hdcMem, bitMem);
      try
        Graphics := TGPGraphics.Create(hdcMem);
        try
          if FBackTopCenter then
            Graphics.DrawImage(img,(FForm.Width - FBackPng.Width) / 2,0,FBackPng.Width,FBackPng.Height)
          else Graphics.DrawImage(Img,0,0,FBackPng.Width,FBackPng.Height);
          tmpcanvas := TCanvas.Create;
          tmpcanvas.Handle := hdcMem;
          DoPaintBackGround(tmpcanvas, Graphics);
          tmpcanvas.Free;
        finally
          Graphics.Free;
          Img.Free;
        end;

        ptDst := Point(FForm.Left, FForm.Top);
        if FUsePicSize then
        begin
          Size.cx := FBackPng.Width;
          Size.cy := FBackPng.Height;
        end
        else
        begin
          Size.cx := FForm.Width;
          Size.cy := FForm.Height;
        end;
        ptSrc := Point(0, 0);
        BlendFunction.BlendOp := AC_SRC_OVER; //把源图片覆盖到目标之上
        BlendFunction.BlendFlags := 0;
        BlendFunction.AlphaFormat := AC_SRC_ALPHA; //每个像素有各自的alpha通道
        BlendFunction.SourceConstantAlpha := FAlphaByte; //源图片的透明度

        SetWindowLong(FForm.Handle, GWL_EXSTYLE, GetWindowLong(FForm.Handle,
        GWL_EXSTYLE) or WS_EX_LAYERED);
        UpdateLayeredWindow(
          FForm.Handle,
          hdcScreen,
          @ptDst,
          @Size,
          hdcMem,
          @ptSrc,
          0,
          @BlendFunction,
          ULW_ALPHA
          );
      finally
        SelectObject(hdcMem, bitOldMem);
      end;
    finally
      DeleteObject(bitMem);
      DeleteDC(hdcMem);
      ReleaseDC(FForm.Handle, hdcScreen);
    end;
  end;
end;

procedure TDxFormPngUIEngine.WndProc(var msg: TMessage);
var
  Ps: TPaintStruct;
  Dc: HDC;
  i,SaveIndex: integer;
  C: TControl;
  r: TRect;
  p: TPoint;
begin
  if csDesigning in ComponentState then
  begin
    if msg.Msg = WM_PAINT then
    begin
      if not FBackPng.Empty then
      begin
        DC := BeginPaint(FForm.Handle,PS);
        if FBackTopCenter then
        begin
          r.Top := 0;
          r.Left := (FForm.Width - FBackPng.Width) div 2;
          r.Right := r.Left + FBackPng.Width;
          r.Bottom := FBackPng.Height;
          FBackPng.DrawToDC(Dc,r);
        end
        else FBackPng.DrawToDC(Dc,Rect(0,0,FBackPng.Width,FBackPng.Height));
        for i := 0 to FForm.ControlCount - 1 do
        begin
          C := FForm.Controls[i];
          SaveIndex := SaveDC(DC);
          try
            MoveWindowOrg(DC, C.Left, C.Top);
            IntersectClipRect(DC, 0, 0, C.Width, C.Height);
            C.Perform(WM_PAINT,DC,0);
          finally
            RestoreDC(DC, SaveIndex);
          end;
        end;
        EndPaint(FForm.Handle,PS);
      end
      else if Assigned(OldWndProc) then
        OldWndProc(msg);
    end
    else if msg.Msg = WM_ERASEBKGND then
    begin
      if not FBackPng.Empty then
      begin
        Dc := TWMEraseBkgnd(msg).DC;
        if FBackTopCenter then
        begin
          r.Top := 0;
          r.Left := (FForm.Width - FBackPng.Width) div 2;
          r.Right := r.Left + FBackPng.Width;
          r.Bottom := FBackPng.Height;
          FBackPng.DrawToDC(Dc,r);
        end
        else FBackPng.DrawToDC(Dc,Rect(0,0,FBackPng.Width,FBackPng.Height));
        {for i := 0 to FForm.ControlCount - 1 do
        begin
          C := FForm.Controls[i];
          SaveIndex := SaveDC(DC);
          try
            MoveWindowOrg(DC, C.Left, C.Top);
            IntersectClipRect(DC, 0, 0, C.Width, C.Height);
            C.Perform(WM_PAINT,DC,0);
          finally
            RestoreDC(DC, SaveIndex);
          end;
        end;}
      end
      else if Assigned(OldWndProc) then
        OldWndProc(msg);
    end
    else if Assigned(OldWndProc) then
      OldWndProc(msg);
  end
  else
  begin
    if not LockMsgToTargControl then
    case msg.Msg of
    WM_LBUTTONDOWN: FForm.SetFocus;
    CM_WANTSPECIALKEY:
      begin
        if FActiveControl <> nil then
        begin
          FActiveControl.Dispatch(Msg);
          if Msg.Result = 1 then
            Exit;
        end;
      end;
    CM_DIALOGCHAR,CM_DIALOGKEY,WM_KEYDOWN,WM_CHAR,WM_KEYUP:
      begin
        if FForm.Focused and (FActiveControl <> nil) then
        begin
          FActiveControl.HandKeyMsg(Msg);
          Exit;
        end;
      end;
    WM_SETFOCUS:
      begin
        if FActiveControl <> nil then
          FActiveControl.Dispatch(Msg);
      end;
    WM_KILLFOCUS:
      begin
        if FActiveControl <> nil then
          FActiveControl.Dispatch(Msg);
      end;
    WM_MOUSEWHEEL:
      begin
        p := FForm.ScreenToClient(SmallPointToPoint(TWMMouseWheel(Msg).Pos));
        C := FindControlAtPoint(p);
        if C <> nil then
        begin
          TWMMouseWheel(Msg).XPos := p.X;
          TWMMouseWheel(Msg).YPos := p.Y;
          C.Dispatch(Msg);
          Exit;
        end;
      end;
    WM_SHOWWINDOW:
      begin
        //先把绑定到窗体的Show出来
        for i := 0 to LinkPngControls.Count - 1 do
        begin
          C:= LinkPngControls[i];
          if c.InheritsFrom(TDxCustomPngFormControl) and (TDxCustomPngFormControl(C).FLinkForm <> nil) then
          begin
            TDxCustomPngFormControl(C).FLinkForm.BorderStyle := bsNone;
            SetWindowLong(TDxCustomPngFormControl(C).FLinkForm.Handle,GWL_HWNDPARENT,FForm.Handle);
            //指定位置
            TDxCustomPngFormControl(C).FLinkForm.Left := FForm.Left + c.Left;
            TDxCustomPngFormControl(C).FLinkForm.Top := FForm.Top + C.Top;
            TDxCustomPngFormControl(C).FLinkForm.Width := c.Width;
            TDxCustomPngFormControl(C).FLinkForm.Height := C.Height;
            TDxCustomPngFormControl(C).FLinkForm.Show;
            TDxCustomPngFormControl(C).HasShowWindow := True;
          end;
        end;
        if not FBackPng.Empty then
        begin
          FUpCount := 0;
          UpdateLayered;
        end;
      end;
    WM_MOVE,WM_DWMCOMPOSITIONCHANGED: //移动窗体，子窗体也移动
      begin
        for i := 0 to LinkPngControls.Count - 1 do
        begin
          C:= LinkPngControls[i];
          if c.InheritsFrom(TDxCustomPngFormControl) and (TDxCustomPngFormControl(C).FLinkForm <> nil) and
            TDxCustomPngFormControl(C).HasShowWindow then
          begin
            TDxCustomPngFormControl(C).FLinkForm.BorderStyle := bsNone;
            //指定位置
            TDxCustomPngFormControl(C).FLinkForm.Left := FForm.Left + c.Left;
            TDxCustomPngFormControl(C).FLinkForm.Top := FForm.Top + C.Top;
            TDxCustomPngFormControl(C).FLinkForm.Width := c.Width;
            TDxCustomPngFormControl(C).FLinkForm.Height := C.Height;
            TDxCustomPngFormControl(C).FLinkForm.Show;
          end;
        end;
      end;
    CM_VISIBLECHANGED:
      begin
        for i := 0 to LinkPngControls.Count - 1 do
        begin
          C:= LinkPngControls[i];
          if c.InheritsFrom(TDxCustomPngFormControl) and (TDxCustomPngFormControl(C).FLinkForm <> nil) and
           TDxCustomPngFormControl(C).HasShowWindow then
            TDxCustomPngFormControl(C).FLinkForm.Hide;
        end;
      end;
    end;
    if (msg.Msg <> WM_SHOWWINDOW) and  Assigned(OldWndProc) then
      OldWndProc(msg);
  end;
end;

{ TDxPngUIControl }

procedure TDxPngUIControl.BringToFront;
var
  index: Integer;
begin
  inherited;
  //调整到列表的Items.Count
  index := FPngUIEngine.LinkPngControls.IndexOf(Self);
  FPngUIEngine.LinkPngControls.Move(index,FPngUIEngine.LinkPngControls.Count - 1);
end;

procedure TDxPngUIControl.CMMouseEnter(var msg: TMessage);
begin
  inherited;
  if (FPngUIEngine <> nil) and not  (csDesigning in ComponentState) then
    FPngUIEngine.UpdateLayered;
end;

procedure TDxPngUIControl.CMMouseLeave(var msg: TMessage);
begin
  inherited;
  if (FPngUIEngine <> nil) and not  (csDesigning in ComponentState) then
    FPngUIEngine.UpdateLayered;
end;

constructor TDxPngUIControl.create(AOwner: TComponent);
begin
  inherited;
  FTabStop := False;
  FCanvas := TControlCanvas.Create;
  TControlCanvas(FCanvas).Control := Self;
end;

destructor TDxPngUIControl.Destroy;
begin
  if GetCaptureControl = Self then
    SetCaptureControl(nil);
  FCanvas.Free;
  inherited;
end;

function TDxPngUIControl.DoKeyDown(var Message: TWMKey): Boolean;
var
  ShiftState: TShiftState;
  Form, FormParent: TCustomForm;
  LCharCode: Word;
begin
  Result := True;
  { First give the immediate parent form a try at the Message }
  Form := GetParentForm(Self, False);
  if (Form <> nil) and (Form <> FPngUIEngine.FForm) then
  begin
    if Form.KeyPreview and TTargetControl(Form).DoKeyDown(Message) then
      Exit;
    { If that didn't work, see if that Form has a parent (ie: it is docked) }
    if Form.Parent <> nil then
    begin
      FormParent := GetParentForm(Form);
      if (FormParent <> nil) and (FormParent <> Form) and
      FormParent.KeyPreview and TTargetControl(FormParent).DoKeyDown(Message) then
        Exit;
    end;
  end;
  with Message do
  begin
    ShiftState := KeyDataToShiftState(KeyData);
    if not (csNoStdEvents in ControlStyle) then
    begin
      LCharCode := CharCode;
      KeyDown(LCharCode, ShiftState);
      CharCode := LCharCode;
      if LCharCode = 0 then Exit;
    end;
  end;
  Result := False;
end;

function TDxPngUIControl.DoKeyPress(var Message: TWMKey): Boolean;
var
  Form: TCustomForm;
  Ch: Char;
begin
  Result := True;
  Form := GetParentForm(Self);
  if (Form <> nil) and (Form <> FPngUIEngine.FForm) and Form.KeyPreview and
    TTargetControl(FPngUIEngine.FForm).DoKeyPress(Message) then Exit;
  if not (csNoStdEvents in ControlStyle) then
    with Message do
    begin
      Ch := Char(CharCode);
      KeyPress(Ch);
      CharCode := Word(Ch);
      if Char(CharCode) = #0 then Exit;
    end;
  Result := False;
end;

function TDxPngUIControl.DoKeyUp(var Message: TWMKey): Boolean;
var
  ShiftState: TShiftState;
  Form, FormParent: TCustomForm;
  LCharCode: Word;
begin
  Result := True;
  { First give the immediate parent form a try at the Message }
  Form := GetParentForm(Self, False);
  if (Form <> nil) and (Form <> FPngUIEngine.FForm) then
  begin
    if Form.KeyPreview and TTargetControl(Form).DoKeyUp(Message) then
      Exit;
    { If that didn't work, see if that Form has a parent (ie: it is docked) }
     if Form.Parent <> nil then
     begin
       FormParent := GetParentForm(Form);
       if (FormParent <> nil) and (FormParent <> Form) and
       FormParent.KeyPreview and TTargetControl(FormParent).DoKeyUp(Message) then
         Exit;
     end;
  end;
  with Message do
  begin
    ShiftState := KeyDataToShiftState(KeyData);
    if not (csNoStdEvents in ControlStyle) then
    begin
      LCharCode := CharCode;
      KeyUp(LCharCode, ShiftState);
      CharCode := LCharCode;
      if LCharCode = 0 then Exit;
    end;
  end;
  Result := False;
end;

function TDxPngUIControl.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;
  MousePos: TPoint): Boolean;
begin
  Result := inherited;
end;

function TDxPngUIControl.Focused: Boolean;
begin
  Result := (FPngUIEngine <> nil) and FPngUIEngine.FForm.Focused and (FPngUIEngine.FActiveControl = Self)
end;


procedure TDxPngUIControl.HandKeyMsg(var Msg: TMessage);
var
  index,OldIndex: Integer;
begin
  case msg.Msg of
  CM_DIALOGCHAR:
    begin
      with TCMDialogChar(Msg) do
        if(IsAccel(CharCode, Caption) or (CharCode = VK_SPACE)) and Enabled and Visible and
          (Parent <> nil) and Parent.Showing then
        begin
          Click;
          Result := 1;
        end else Dispatch(Msg);
    end;
  CM_DIALOGKEY:
    begin
      //响应Tab的方式
      with TCMDialogKey(msg) do
      begin
        case CharCode of
        VK_TAB:
          if not FTabStop then
          begin
            //转移到下一个控件
            index := PngUIEngine.LinkPngControls.IndexOf(Self);
            OldIndex := index;
            if index = FPngUIEngine.LinkPngControls.Count - 1 then
              index := 0
            else Inc(index);
            TDxPngUIControl(FPngUIEngine.LinkPngControls.Items[OldIndex]).Perform(WM_KILLFOCUS,FPngUIEngine.FForm.Handle,0);
            TDxPngUIControl(FPngUIEngine.LinkPngControls.Items[index]).Perform(WM_SETFOCUS,FPngUIEngine.FForm.Handle,0);
            FPngUIEngine.FActiveControl := FPngUIEngine.LinkPngControls.Items[index];
          end;
        end;
      end;
    end;
  WM_KEYDOWN:
    begin
      if not DoKeyDown(TWMKeyDown(msg)) then
      begin
        FPngUIEngine.LockMsgToTargControl := True;
        FPngUIEngine.WndProc(Msg);
        FPngUIEngine.LockMsgToTargControl := False;
      end;
      TTargetControl(FPngUIEngine.FForm).UpdateUIState(TWMKeyDown(msg).CharCode);
    end;
  WM_KEYUP:
    begin
      if not DoKeyUp(TWMKeyUp(Msg)) then
      begin
        FPngUIEngine.LockMsgToTargControl := True;
        FPngUIEngine.WndProc(Msg);
        FPngUIEngine.LockMsgToTargControl := False;
      end;
    end;
  WM_Char:
    begin
      if not DoKeyPress(TWMKey(msg)) then
      begin
        FPngUIEngine.LockMsgToTargControl := True;
        FPngUIEngine.WndProc(Msg);
        FPngUIEngine.LockMsgToTargControl := False;
      end;
    end;
  end;
end;

procedure TDxPngUIControl.KeyDown(var Key: Word; Shift: TShiftState);
begin
  if Assigned(FOnKeyDown) then FOnKeyDown(Self, Key, Shift);
end;

procedure TDxPngUIControl.KeyPress(var Key: Char);
begin
  if Assigned(FOnKeyPress) then FOnKeyPress(Self, Key);
end;

procedure TDxPngUIControl.KeyUp(var Key: Word; Shift: TShiftState);
begin
  if Assigned(FOnKeyUp) then FOnKeyUp(Self, Key, Shift);
end;

procedure TDxPngUIControl.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  if (FPngUIEngine = nil) or (FPngUIEngine.FActiveControl = Self) then
    Exit;
  if FPngUIEngine.FActiveControl <> nil then
  begin
    FPngUIEngine.FActiveControl.Perform(WM_KILLFOCUS,FPngUIEngine.FForm.Handle,1)
  end;
  FPngUIEngine.FActiveControl := Self;
  Perform(WM_SETFOCUS,FPngUIEngine.FForm.Handle,1);
  inherited;
end;

procedure TDxPngUIControl.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited;

end;

procedure TDxPngUIControl.MouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  inherited;

end;

procedure TDxPngUIControl.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if AComponent.InheritsFrom(TDxFormPngUIEngine) and (Operation = opRemove) then
    SetPngUIEngine(nil);
end;

procedure TDxPngUIControl.Paint;
begin
  //只在设计状态下有效
  if (csDesigning in ComponentState) or (FPngUIEngine = nil) then
    PaintUI(FCanvas,ClientRect);
end;

procedure TDxPngUIControl.PaintUI(ToCanvas: TCanvas;DestRect: TRect);
begin

end;

procedure TDxPngUIControl.SendToBack;
var
  index: Integer;
begin
  inherited;
  //调整到列表的0
  index := FPngUIEngine.LinkPngControls.IndexOf(Self);
  FPngUIEngine.LinkPngControls.Move(index,0);
end;

procedure TDxPngUIControl.SetIngoreAlpha(const Value: Boolean);
begin
  if FIngoreAlpha <> Value then
  begin
    FIngoreAlpha := Value;    
    Invalidate;
  end;
end;

procedure TDxPngUIControl.SetParent(AParent: TWinControl);
begin
  if (AParent <> nil) and (FPngUIEngine <> nil) and (FPngUIEngine.FForm <> AParent) then
    raise Exception.Create('Control''s Parent must as same as ControlEngine''s TagretControl');
  inherited;
end;

procedure TDxPngUIControl.SetPngUIEngine(Value: TDxFormPngUIEngine);
var
  index: Integer;
begin
  if FPngUIEngine <> value then
  begin
    if FPngUIEngine <> nil then
    begin
      index := FPngUIEngine.LinkPngControls.IndexOf(self);
      if index <> -1 then
        FPngUIEngine.LinkPngControls.Delete(index);
      FPngUIEngine.UpdateLayered;
    end;
    FPngUIEngine := Value;
    if FPngUIEngine <> nil then
    begin
      FPngUIEngine.FreeNotification(Self);
      index := FPngUIEngine.LinkPngControls.IndexOf(Value);
      if index = -1 then
        FPngUIEngine.LinkPngControls.Add(Self);
      FPngUIEngine.UpdateLayered;
    end;
  end;
end;

procedure TDxPngUIControl.WMKillFocus(var msg: TWMKillFocus);
begin
  inherited;
end;

procedure TDxPngUIControl.WMMOUSEWHEEL(var msg: TWMMouseWheel);
begin
  if not Mouse.WheelPresent then
  begin
    PBoolean(@Mouse.WheelPresent)^ := True;
    Mouse.SettingChanged(SPI_GETWHEELSCROLLLINES);
  end;
  TCMMouseWheel(msg).ShiftState := KeysToShiftState(msg.Keys);
  if DoMouseWheel(TCMMouseWheel(msg).ShiftState, msg.WheelDelta, SmallPointToPoint(msg.Pos)) then
    msg.Result := 1;
  if msg.Result = 0 then inherited;
end;

procedure TDxPngUIControl.WMPaint(var Message: TWMPaint);
begin
  if (Message.DC <> 0) and not (csDestroying in ComponentState) then
  begin
    FCanvas.Lock;
    try
      FCanvas.Handle := Message.DC;
      try
        Paint;
      finally
        FCanvas.Handle := 0;
      end;
    finally
      FCanvas.Unlock;
    end;
  end;
end;

procedure TDxPngUIControl.WMSetFocus(var msg: TWMSetFocus);
begin
  inherited;
end;

{ TDxPngUIButton }

procedure TDxPngUIButton.Click;
begin
  inherited;
end;

procedure TDxPngUIButton.CMMouseEnter(var msg: TMessage);
begin
  IsMouseIn := true;
  Invalidate;
  inherited;
end;

procedure TDxPngUIButton.CMMouseLeave(var msg: TMessage);
begin
  IsMouseIn := False;
  Invalidate;
  inherited;
end;

constructor TDxPngUIButton.Create(AOwner: TComponent);
begin
  inherited;
  FFlatFrameColor := clGray;
  FIcon := TIcon.Create;
  FIcon.OnChange := DoIconChange;
  ControlStyle := ControlStyle + [csClickEvents];
  IsLDown := False;
  IsMouseIn := False;
  FTextPng := TDxPngImage.Create;
  FMouseDownPng := TDxPngImage.Create;
  FMouseMovePng := TDxPngImage.Create;
  FNormalPng := TDxPngImage.Create;
  FTextPng.OnChange := DoPicChange;
  FMouseDownPng.OnChange := DoPicChange;
  FMouseMovePng.OnChange := DoPicChange;
  FNormalPng.OnChange := DoPicChange;
end;

destructor TDxPngUIButton.Destroy;
begin
  FMouseDownPng.Free;
  FMouseMovePng.Free;
  FNormalPng.Free;
  FTextPng.Free;
  FIcon.Free;
  inherited;
end;

procedure TDxPngUIButton.DoIconChange(Sender: TObject);
begin
  if (csDesigning in ComponentState) or (FPngUIEngine = nil) then
    Invalidate
  else if FPngUIEngine <> nil then
    FPngUIEngine.UpdateLayered;
end;

procedure TDxPngUIButton.DoPicChange(Sender: TObject);
begin
  if csDesigning in ComponentState then
    Invalidate
  else if FPngUIEngine <> nil then
    FPngUIEngine.UpdateLayered;
end;

procedure TDxPngUIButton.DrawCaption(ToCanvas: TCanvas; DestRect: TRect);
var
  AGraphics: TGpGraphics;
  FontFamily: TGpFontFamily;
  StringFormat: TGpStringFormat;
  Path: TGpGraphicsPath;
  TitleSize: TSize;
  R: TGpRectF;
  tmpr: TRect;
  Pen: TGPPen;
  LinGrBrush: TGPLinearGradientBrush;  //使用线性渐变封装 Brush
begin
  if Caption = '' then
    Exit;
  //使用GDI+绘制文字
  AGraphics := TGpGraphics.Create(ToCanvas.Handle);
  AGraphics.SmoothingMode := smAntiAlias;
  AGraphics.InterpolationMode := imHighQualityBicubic;//指定的高品质，双三次插值

  FontFamily := TGPFontFamily.Create(Font.Name);
  StringFormat := TGPStringFormat.Create();
  Path := TGPGraphicsPath.Create();
  FCanvas.Font.Assign(Font);
  tmpr := DestRect;
  DrawText(FCanvas.Handle,Caption,-1,tmpr,DT_CENTER or DT_VCENTER or DT_CALCRECT or DT_WORDBREAK);
  TitleSize.cx := tmpr.Right - tmpr.Left;
  TitleSize.cy := tmpr.Bottom - tmpr.Top;

  Pen := TGPPen.Create(ARGBFromTColor(62, FCapShadowColor), 2);  //颜色、宽度
  Pen.LineJoin := ljRound; //指定圆形联接。这将在两条线之间产生平滑的圆弧。

  R.X := (Height - TitleSize.cy) / 2;
  if r.X < 0 then
    r.X := 0;
  r.Y := r.X + TitleSize.cy;
  if r.Y > Height then
    r.Y := Height;
  r.X := DestRect.Top + r.X;
  r.Y := DestRect.Top + r.Y;
  LinGrBrush := TGPLinearGradientBrush.Create(
    MakePoint(0, r.X),    //线性渐变起始点
    MakePoint(0, r.Y), //线性渐变终结点
    ARGBFromTColor(255, clWhite), //线性渐变起始色
    ARGBFromTColor(255, Font.Color)); //线性渐变结束色

  R.X := DestRect.Left;
  R.Y := DestRect.Top;
  R.Width := Width;
  R.Height := Height;
  if IsLDown then
  begin
    R.X := R.X + 2;
    R.Y := R.Y + 2;
  end;

  StringFormat.LineAlignment := saCenter;
  StringFormat.Alignment := saCenter;

  Path.AddString(Caption, FontFamily, Font.Style, Font.Size, R, StringFormat);

  //---------------------开始：画字符串阴影--------------------------------------
  AGraphics.DrawPath(Pen, Path);
  AGraphics.FillPath(LinGrBrush, Path);
  Pen.Free;
  LinGrBrush.Free;
  Path.Free;
  FontFamily.free;
  StringFormat.Free;
  AGraphics.Free;
end;

procedure TDxPngUIButton.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  inherited;
  IsLDown := True;
  if (FPngUIEngine <> nil) and not  (csDesigning in ComponentState) then
    FPngUIEngine.UpdateLayered
  else Invalidate;
end;

procedure TDxPngUIButton.MouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  inherited;
  IsLDown := False;
  if (FPngUIEngine <> nil) and not  (csDesigning in ComponentState) then
    FPngUIEngine.UpdateLayered
  else Invalidate;
end;

procedure TDxPngUIButton.Paint;
begin
  PaintUI(Canvas,ClientRect);
end;

procedure TDxPngUIButton.PaintUI(ToCanvas: TCanvas;DestRect: TRect);
var
  r: TRect;
  Skin: TDxUISkin;
  Png: TDxPngImage;
begin
  Png := nil;
  if csDesigning in ComponentState then
  begin
    if not FNormalPng.Empty then
      Png := FNormalPng
    else if (FPngUIEngine <> nil) and (FPngUIEngine.FUISkins <> nil) and (FPngUIEngine.FUISkins.FUISkins.TryGetValue('TDxPngUIButton',SKin)) then
    begin
      if not TDxButtonSkin(Skin).FNormalPng.Empty then
        Png := TDxButtonSkin(Skin).FNormalPng;
    end;
  end
  else if IsMouseIn then
  begin
    if IsLDown then
    begin
      if not FMouseDownPng.Empty then
        Png := FMouseDownPng
      else if (FPngUIEngine <> nil) and (FPngUIEngine.FUISkins <> nil) then
      begin
        Skin := FPngUIEngine.FUISkins.GetSkin(self);
        if (Skin <> nil) and not TDxButtonSkin(Skin).FMouseDownPng.Empty then
          png := TDxButtonSkin(Skin).FMouseDownPng;
      end;
    end
    else if not FMouseMovePng.Empty then
       Png := FMouseMovePng
    else if (FPngUIEngine <> nil) and (FPngUIEngine.FUISkins <>  nil) then
    begin
      Skin := FPngUIEngine.FUISkins.GetSkin(self);
      if (Skin <> nil) and not TDxButtonSkin(Skin).FMouseMovePng.Empty then
        png := TDxButtonSkin(Skin).FMouseMovePng;
    end;
  end
  else if not FNormalPng.Empty then
    Png := FNormalPng
  else if  (FPngUIEngine <> nil) and (FPngUIEngine.FUISkins <> nil) then
  begin
    Skin := FPngUIEngine.FUISkins.GetSkin(self);
    if (Skin <> nil) and not TDxButtonSkin(Skin).FNormalPng.Empty then
      png := TDxButtonSkin(Skin).FNormalPng;
  end;
  if Png <> nil then
    ToCanvas.Draw(DestRect.Left,DestRect.Top,Png)
  else
  begin
    ToCanvas.Brush.Color := FFlatFrameColor;
    ToCanvas.FrameRect(DestRect);
  end;

  //绘制图标
  if not FIcon.Empty then
  begin
    if Width > FIcon.Width then
    begin
      r.Left := DestRect.Left + (Width - FIcon.Width) div 2;
      r.Right := r.Left + FIcon.Width;
    end
    else
    begin
      r.Left := DestRect.Left ;
      r.Right := DestRect.Right;
    end;
    if Height > FIcon.Height then
    begin
      r.Top := DestRect.Top + (Height - FIcon.Height) div 2;
      r.Bottom := r.Top + FIcon.Height;
    end
    else
    begin
      r.Top := DestRect.Top;
      r.Bottom := DestRect.Bottom;
    end;
    ToCanvas.Draw(r.Left,r.Top,FIcon);
  end;

  if not FTextPng.Empty then
  begin
    if FTextPng.Width > Width then
    begin
      r.Left := DestRect.Left;
      r.Right := DestRect.Right;
      if FTextPng.Height > Height then
      begin
        r.Top := DestRect.Top;
        r.Bottom := DestRect.Bottom;
      end
      else
      begin
        r.Top := DestRect.Top + (DestRect.Bottom - DestRect.Top - FTextPng.Height) div 2;
        r.Bottom := r.Top + FTextPng.Height
      end;
    end
    else
    begin
      r.Left := DestRect.Left + (DestRect.Right - DestRect.Left - FTextPng.Width) div 2;
      r.Right := r.Left + FTextPng.Width;
      if FTextPng.Height > Height then
      begin
        r.Top := DestRect.Top;
        r.Bottom := DestRect.Bottom;
      end
      else
      begin
        r.Top := DestRect.Top + (DestRect.Bottom - DestRect.Top - FTextPng.Height) div 2;
        r.Bottom := r.Top + FTextPng.Height
      end;
    end;
    FTextPng.DrawToDest(ToCanvas,Rect(0,0,FTextPng.Width,FTextPng.Height),r)
  end
  else DrawCaption(ToCanvas,DestRect);
end;

procedure TDxPngUIButton.SetCapShadowColor(const Value: TColor);
begin
  FCapShadowColor := Value;
end;

procedure TDxPngUIButton.SetFlatFrameColor(const Value: TColor);
begin
  if FFlatFrameColor <> Value then
  begin
    FFlatFrameColor := Value;
    if (FPngUIEngine = nil) or  (csDesigning in ComponentState) then
      Invalidate;
  end;
end;

procedure TDxPngUIButton.SetIcon(const Value: TIcon);
begin
  FIcon.Assign(Value);
end;

procedure TDxPngUIButton.SetMouseDownPng(const Value: TDxPngImage);
begin
  FMouseDownPng.Assign(Value);
end;

procedure TDxPngUIButton.SetMouseMovePng(const Value: TDxPngImage);
begin
  FMouseMovePng.Assign(Value);
end;

procedure TDxPngUIButton.SetNormalPng(const Value: TDxPngImage);
begin
  FNormalPng.Assign(Value);
end;

procedure TDxPngUIButton.SetTextPng(const Value: TDxPngImage);
begin
  FTextPng.Assign(Value);
end;

{ TDxPngProgress }

constructor TDxPngProgress.Create(AOwner: TComponent);
begin
  inherited;
  Step := 5;
  FMin := 0;
  FMax := 100;
  FPosition := 0;
  Height := 34;
  Width := 50;
end;

procedure TDxPngProgress.PaintUI(ToCanvas: TCanvas; DestRect: TRect);
var
  r,r2: TRect;
  st: string;
begin
  if csDesigning in ComponentState then
  begin
    r.Left := 0;
    r.Right := 20;
    r.Top := 0;
    r.Bottom := ProgBack.Height;
    r2.Left := 0;r2.Right := 20;
    if Height < ProgBack.Height then
    begin
      r2.Top := 0;
      r2.Bottom := Height;
    end
    else
    begin
      r2.Top := (Height - ProgBack.Height) div 2;
      r2.Bottom := r2.Top + ProgBack.Height;
    end;
    ProgBack.DrawToDest(ToCanvas,r,r2);
    r.Left := r.Right;
    r.Right := r.Left + 4;
    r2.Left := r2.Right;
    r2.Right := Width - 20;
    ProgBack.DrawToDest(ToCanvas,r,r2);
    r.Left := ProgBack.Width - 20;
    r.Right := ProgBack.Width;
    r2.Left := r2.Right;
    r2.Right := Width;
    ProgBack.DrawToDest(ToCanvas,r,r2);
  end
  else
  begin
    //绘制滚动条
    //先绘制背景
    r.Left := 0;
    r.Right := 20;
    r.Top := 0;
    r.Bottom := ProgBack.Height;

    r2.Left := DestRect.Left;r2.Right := 20 + DestRect.Left;
    if Height < ProgBack.Height then
    begin
      r2.Top := DestRect.Top;
      r2.Bottom := Height + DestRect.Top;
    end
    else
    begin
      r2.Top := DestRect.Top + (Height - ProgBack.Height) div 2;
      r2.Bottom := r2.Top + ProgBack.Height;
    end;
    ProgBack.DrawToDest(ToCanvas,r,r2);
    r.Left := r.Right;
    r.Right := r.Left + 4;
    r2.Left := r2.Right;
    r2.Right := DestRect.Left + Width - 20;
    ProgBack.DrawToDest(ToCanvas,r,r2);
    r.Left := ProgBack.Width - 20;
    r.Right := ProgBack.Width;
    r2.Left := r2.Right;
    r2.Right := DestRect.Left +Width;
    ProgBack.DrawToDest(ToCanvas,r,r2);

    //绘制区域
    r.Top := 0;
    r.Bottom := ProgPos.Height;
    r2.Top := DestRect.Top;
    r2.Bottom := Height + R2.Top;
    if (step < 9) or (FPosition = 0) then
    begin

    end
    else if Step <= ProgPos.Width then
    begin
      r.Left := ProgPos.Width - Step;
      r.Right := ProgPos.Width;
      r2.Left := DestRect.Left + 9;
      r2.Right := r2.Left + Step;
      ProgPos.DrawToDest(ToCanvas,r,r2);
    end
    else if Step < width then
    begin
      //先绘制前面的进度
      r.Left := 0;
      r.Right := ProgForward.Width;
      r.Bottom := ProgForward.Height;
      r2.Left := 9;
      r2.Right := Step - ProgPos.Width + 25;
      r2.Top := DestRect.Top + (Height - ProgForward.Height) div 2;
      r2.Bottom := r2.Top + ProgForward.Height;
      ProgForward.DrawToDest(ToCanvas,r,r2);

      r.Bottom := ProgPos.Height;
      r.Left := 0;
      r.Right := ProgPos.Width;
      r2.Left := Step - ProgPos.Width + 9;
      r2.Right := Step + 9;
      r2.Top := DestRect.Top;
      r2.Bottom := Height + R2.Top;
      ProgPos.DrawToDest(ToCanvas,r,r2);
    end;
    //绘制文字
    if FShowPositionCaption then
    begin
      r := DestRect;
      st := FormatFloat('#.##',(100 * FPosition) / Max) + '%';
      ToCanvas.Brush.Style := bsClear;
      DrawText(ToCanvas.Handle,PChar(st),-1,r,DT_VCENTER or DT_CENTER or DT_SINGLELINE);
    end;
  end;
end;

procedure TDxPngProgress.Resize;
begin
  inherited;
  Step := Round((Width * (FPosition - FMin)) / (FMax - FMin));
  if csDesigning in ComponentState then
  begin
    if Parent <> nil then
      Invalidate;
  end;
end;

procedure TDxPngProgress.SetMax(const Value: Integer);
begin
  if (FMax <> Value) and (Value > FMin) then
  begin
    FMax := Value;
    if FMax < FPosition then
      FPosition := FMax;
    Step := Round((Width * (FPosition - FMin)) / (FMax - FMin));
    if Parent <> nil then
      Invalidate;
  end;
end;

procedure TDxPngProgress.SetMin(const Value: Integer);
begin
  if (FMin <> Value) and (Value < FMax) then
  begin
    FMin := Value;
    if FMin > FPosition then
       FPosition := FMin;
    Step := Round((Width * (FPosition - FMin)) / (FMax - FMin));//计算每个进度的步长
    if Parent <> nil then
      Invalidate;
  end;
end;

procedure TDxPngProgress.SetPosition(Value: Single);
begin
  if Value < FMin then
     Value := FMin
  else if Value > FMax then
     Value := FMax;
  if FPosition <> Value then
  begin
    FPosition := Value;
    Step := Round((Width * (FPosition - FMin)) / (FMax - FMin));

    if (FPngUIEngine <> nil) and not (csDesigning in ComponentState) then
      FPngUIEngine.UpdateLayered;
    {if Parent <> nil then
    begin
      if CSkin <> nil then
      begin
        r := ClientRect;
        InflateRect(r,CSkin.PropAsInteger['ProgressStartH'],CSkin.PropAsInteger['ProgressStartV']);
        OffsetRect(r,Left,top);
        InvalidateRect(Parent.Handle,@r,False);
      end
      else Invalidate;
    end;}
  end;
end;

procedure TDxPngProgress.SetShowPositionCaption(const Value: Boolean);
begin
  if FShowPositionCaption <> Value then
  begin
    FShowPositionCaption := Value;
    if Parent <> nil then
      Invalidate;
  end;
end;
{ TDxPngLabel }

procedure TDxPngLabel.CmFontChange(var msg: TMessage);
begin
  inherited;
  if (csDesigning in ComponentState) or (FPngUIEngine = nil) then
    Invalidate
  else if FPngUIEngine <> nil then
    FPngUIEngine.UpdateLayered;
end;

procedure TDxPngLabel.CmTextChange(var msg: TMessage);
begin
  inherited;
  if (csDesigning in ComponentState) or (FPngUIEngine = nil) then
    Invalidate
  else if FPngUIEngine <> nil then
    FPngUIEngine.UpdateLayered;
end;

procedure TDxPngLabel.PaintUI(ToCanvas: TCanvas; DestRect: TRect);
var
  AGraphics: TGpGraphics;
  FontFamily: TGpFontFamily;
  StringFormat: TGpStringFormat;
  Path: TGpGraphicsPath;
  TitleSize: TSize;
  R: TGpRectF;
  tmpr: TRect;
  Pen: TGPPen;
  LinGrBrush: TGPLinearGradientBrush;  //使用线性渐变封装 Brush
begin
  if Caption = '' then
    Exit;
  //使用GDI+绘制文字
  AGraphics := TGpGraphics.Create(ToCanvas.Handle);
  AGraphics.SmoothingMode := smAntiAlias;
  AGraphics.InterpolationMode := imHighQualityBicubic;//指定的高品质，双三次插值

  FontFamily := TGPFontFamily.Create(Font.Name);
  StringFormat := TGPStringFormat.Create();
  Path := TGPGraphicsPath.Create();
  FCanvas.Font.Assign(Font);
  tmpr := DestRect;
  DrawText(FCanvas.Handle,Caption,-1,tmpr,DT_CENTER or DT_VCENTER or DT_CALCRECT or DT_WORDBREAK);
  TitleSize.cx := tmpr.Right - tmpr.Left;
  TitleSize.cy := tmpr.Bottom - tmpr.Top;

  Pen := TGPPen.Create(ARGBFromTColor(62, FShadowColor), 2);  //颜色、宽度
  Pen.LineJoin := ljRound; //指定圆形联接。这将在两条线之间产生平滑的圆弧。

  R.X := (Height - TitleSize.cy) / 2;
  if r.X < 0 then
    r.X := 0;
  r.Y := r.X + TitleSize.cy;
  if r.Y > Height then
    r.Y := Height;
  r.X := DestRect.Top + r.X;
  r.Y := DestRect.Top + r.Y;
  LinGrBrush := TGPLinearGradientBrush.Create(
    MakePoint(0, r.X),    //线性渐变起始点
    MakePoint(0, r.Y), //线性渐变终结点
    ARGBFromTColor(255, clWhite), //线性渐变起始色
    ARGBFromTColor(255, Font.Color)); //线性渐变结束色

  R.X := DestRect.Left;
  R.Y := DestRect.Top;
  R.Width := Width;
  R.Height := Height;

  StringFormat.LineAlignment := saCenter;
  StringFormat.Alignment := saCenter;

  Path.AddString(Caption, FontFamily, Font.Style, Font.Size, R, StringFormat);

  //---------------------开始：画字符串阴影--------------------------------------
  AGraphics.DrawPath(Pen, Path);
  AGraphics.FillPath(LinGrBrush, Path);
  Pen.Free;
  LinGrBrush.Free;
  Path.Free;
  FontFamily.free;
  StringFormat.Free;
  AGraphics.Free;
end;

procedure TDxPngLabel.SetShadowColor(const Value: TColor);
begin
  if FShadowColor <> Value then
  begin
    FShadowColor := Value;
    if (csDesigning in ComponentState) or (FPngUIEngine = nil) then
      Invalidate
    else if FPngUIEngine <> nil then
      FPngUIEngine.UpdateLayered;
  end;
end;

{ TDxCustomPngFormControl }

procedure TDxCustomPngFormControl.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (AComponent = FLinkForm) then
    FLinkForm := nil;
end;

procedure TDxCustomPngFormControl.PaintUI(ToCanvas: TCanvas; DestRect: TRect);
begin
  if csDesigning in ComponentState then
  begin
    ToCanvas.Brush.Color := clBlue;
    ToCanvas.FrameRect(DestRect);

    ToCanvas.Font.Assign(Font);
    ToCanvas.Brush.Style := bsClear;
    DrawText(ToCanvas.Handle,'窗体内嵌控件',-1,DestRect,DT_Center or DT_VCenter or DT_SingleLine)
  end
  else
  begin
    ToCanvas.Brush.Color := clBlack;
    ToCanvas.FillRect(DestRect);
  end;
end;

procedure TDxCustomPngFormControl.SetLinkForm(const Value: TForm);
begin
  if FLinkForm <> Value then
  begin
    FLinkForm := Value;
    FLinkForm.FreeNotification(Self);
  end;
end;

{ TDxUISkin }

constructor TDxUISkin.Create(AOwner: TComponent);
begin
  inherited;

end;


procedure TDxUISkin.DoPicChange(Sender: TObject);
begin
  if FUISkins <> nil then
    FUISkins.Change;
end;

procedure TDxUISkin.SetUISkins(const Value: TDxUISkins);
var
  Skin: TDxUISkin;
begin
  if FUISkins <> Value then
  begin
    if FUISkins <> nil  then
    begin
      if FUISkins.FUISkins.ContainsKey(FUIControlClass) then
        FUISkins.FUISkins.Remove(FUIControlClass);
      RemoveFreeNotification(FUISkins);
    end;
    FUISkins := Value;
    if FUISkins <> nil then
    begin
      if FUISkins.FUISkins.TryGetValue(FUIControlClass,Skin) then
      begin
         Skin.RemoveFreeNotification(FUISkins);
         Skin.FUISkins := nil;
      end;
      FUISkins.FUISkins.AddOrSetValue(FUIControlClass,Self);
      FreeNotification(FUISkins);
    end;
  end;
end;

{ TDxUISkins }

procedure TDxUISkins.BeginUpdate;
begin
  inc(FUpCount);
end;

procedure TDxUISkins.Change;
var
  Engine: TDxFormPngUIEngine;
  i: Integer;
begin
  if not (csDesigning in ComponentState) then
  for i := 0 to FEngines.Count - 1 do
  begin
    Engine := FEngines[i];
    Engine.UpdateLayered;
  end;    
end;

constructor TDxUISkins.Create(AOwner: TComponent);
begin
  inherited;
  FUISkins := TDictionary<string,TDxUISkin>.Create;
  FEngines := TList.Create;
end;

destructor TDxUISkins.Destroy;
var
  Pair: TPair<String,TDxUISkin>;
begin
  while FEngines.Count > 0 do  
    TDxFormPngUIEngine(FEngines[FEngines.Count - 1]).UISkins := nil;
  for Pair in FUISkins do
    Pair.Value.UISkins := nil;
  FEngines.Free;
  FUISkins.Free;
  inherited;
end;

procedure TDxUISkins.EndUpdate;
begin
  Dec(FupCount);
  if FUpcount <= 0 then
  begin
    FUpcount := 0;
    Change;
  end;
end;

function TDxUISkins.GetSkin(C: TDxPngUIControl): TDxUISkin;
begin
  FUISkins.TryGetValue(C.ClassName,Result)
end;

procedure TDxUISkins.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if Operation = opRemove then
  begin
    if AComponent.InheritsFrom(TDxFormPngUIEngine) then
      FEngines.Remove(AComponent)
    else if AComponent.InheritsFrom(TDxUISkin) then
    begin
      FUISkins.Remove(TDxUISkin(AComponent).FUIControlClass);
      Change;
    end;
  end;
end;

{ TDxButtonSkin }

constructor TDxButtonSkin.Create(AOwner: TComponent);
begin
  inherited;
  FUIControlClass := 'TDxPngUIButton';
  FMouseDownPng := TDxPngImage.Create;
  FMouseMovePng := TDxPngImage.Create;
  FNormalPng := TDxPngImage.Create;

  FNormalPng.OnChange := DoPicChange;
  FMouseMovePng.OnChange := DoPicChange;
  FMouseDownPng.OnChange := DoPicChange;
end;

destructor TDxButtonSkin.Destroy;
begin
  FMouseDownPng.Free;
  FMouseMovePng.Free;
  FNormalPng.Free;
  inherited;
end;

procedure TDxButtonSkin.SetMouseDownPng(const Value: TDxPngImage);
begin
  FMouseDownPng.Assign(Value);
end;

procedure TDxButtonSkin.SetMouseMovePng(const Value: TDxPngImage);
begin
  FMouseMovePng.Assign(Value);
end;

procedure TDxButtonSkin.SetNormalPng(const Value: TDxPngImage);
begin
  FNormalPng.Assign(Value);
end;


{ TDxDropDownButton }

procedure TDxDropDownButton.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  p: TPoint;
begin
  inherited;
  if FDropDownMenu <> nil then
  begin
    p.X := Left;p.Y := top + Height;
    p := Parent.ClientToScreen(p);
    FDropDownMenu.Popup(p.X,p.Y);
  end;
end;

procedure TDxDropDownButton.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if Operation = opRemove then
  begin
    if AComponent = FDropDownMenu then
      FDropDownMenu := nil
  end;
end;

procedure TDxDropDownButton.SetDropDownMenu(const Value: TPopupMenu);
begin
  if FDropDownMenu <> Value then
  begin
     FDropDownMenu := Value;
     if FDropDownMenu <> nil then
     begin
       FDropDownMenu.ParentBiDiModeChanged(Self);
       FDropDownMenu.FreeNotification(Self);
     end;
  end;
end;

end.
