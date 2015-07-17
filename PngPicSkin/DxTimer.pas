unit DxTimer;

interface
uses Windows,Classes,Messages,SysUtils;

type
  TDxTimer = class(TComponent)
  private
    FInterval: Integer;
    FEnabled: Boolean;
    FOnTimer: TNotifyEvent;
    procedure SetInterval(const Value: Integer);
    procedure SetEnabled(const Value: Boolean);
  protected
    procedure Timer;virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy;override;
  published
    property Interval: Integer read FInterval write SetInterval default 1000;
    property Enabled: Boolean read FEnabled write SetEnabled default False;
    property OnTimer: TNotifyEvent read FOnTimer write FOnTimer;
  end;

implementation

type
  TDxTimerManager = class
  private
    TimerHWnd: THandle;
    FTimerList: TList; //Timer¡–±Ì
  protected
    procedure WndProc(var Message: TMessage);
  public
    constructor create;
    destructor Destroy;override;
  end;
var
  Manager: TDxTimerManager = nil;

{ TDxTimerManager }

constructor TDxTimerManager.create;
begin
  TimerHWnd := AllocateHWnd(WndProc);
  FTimerList := TList.Create;
end;

destructor TDxTimerManager.Destroy;
begin
  DeallocateHWnd(TimerHWnd);
  FTimerList.Free;
  inherited;
end;

procedure TDxTimerManager.WndProc(var Message: TMessage);
begin
  if Message.Msg = WM_TIMER then
  begin
    TDxTimer(TWMTimer(Message).TimerID).Timer;//¥•∑¢
  end
  else Message.Result := DefWindowProc(TimerHWnd,Message.Msg,Message.WParam,Message.LParam);
end;

{ TDxTimer }

constructor TDxTimer.Create(AOwner: TComponent);
begin
  inherited;
  FInterval := 1000;
  FEnabled := False;
  if Manager = nil then
    Manager := TDxTimerManager.create;
  Manager.FTimerList.Add(Self)
end;

destructor TDxTimer.Destroy;
begin
  Manager.FTimerList.Remove(Self);
  inherited;
end;

procedure TDxTimer.SetEnabled(const Value: Boolean);
begin
  if FEnabled <> Value then
  begin
    FEnabled := Value;
    if not (csDesigning in ComponentState) then
    begin
      if FEnabled then
        SetTimer(Manager.TimerHWnd,Integer(self),FInterval,nil)
      else KillTimer(Manager.TimerHWnd,Integer(Self));
    end;
  end;
end;

procedure TDxTimer.SetInterval(const Value: Integer);
begin
  if FInterval <> Value then
  begin
    FInterval := Value;
    Enabled := False;
  end;
end;

procedure TDxTimer.Timer;
begin
  if Assigned(FOnTimer) then
    FOnTimer(Self);
end;

initialization
finalization
  if Manager <> nil then
    Manager.Free;
end.
