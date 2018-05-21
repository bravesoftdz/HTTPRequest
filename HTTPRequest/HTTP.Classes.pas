unit HTTP.Classes;

interface

uses HTTP.Interfaces, HTTP.Types, System.Classes, System.SysUtils;

type

  THTTPProcessor = class(TInterfacedObject, IHTTPProcessor)
  private
    FHeaders: THTTPStrHeaders;
    FMethod: THTTPMethods;
    FProtocol: THTTPProtocols;
    FPort: Integer;
    FParameters: THTTPStrParameters;
    FHost: string;
    FRoutes: TStringList;
    FBeforeList: THTTPOnBeforeList;
    FRExceptionList: THTTPOnExceptionList;
    FAfterList: THTTPOnAfterList;
    FFiles: THTTPFiles;
    function GetAfterList: THTTPOnAfterList;
    function GetBeforeList: THTTPOnBeforeList;
    function GetFiles: THTTPFiles;
    function GetHeaders: THTTPStrHeaders;
    function GetHost: string;
    function GetMethod: THTTPMethods;
    function GetParameters: THTTPStrParameters;
    function GetPort: Integer;
    function GetProtocol: THTTPProtocols;
    function GetRExceptionList: THTTPOnExceptionList;
    function GetRoutes: TStringList;
    procedure SetAfterList(const Value: THTTPOnAfterList);
    procedure SetBeforeList(const Value: THTTPOnBeforeList);
    procedure SetFiles(const Value: THTTPFiles);
    procedure SetHeaders(const Value: THTTPStrHeaders);
    procedure SetHost(const Value: string);
    procedure SetMethod(const Value: THTTPMethods);
    procedure SetParameters(const Value: THTTPStrParameters);
    procedure SetPort(const Value: Integer);
    procedure SetProtocol(const Value: THTTPProtocols);
    procedure SetRExceptionList(const Value: THTTPOnExceptionList);
    procedure SetRoutes(const Value: TStringList);
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
    property Method: THTTPMethods read GetMethod write SetMethod;
    property Protocol: THTTPProtocols read GetProtocol write SetProtocol;
    property Host: string read GetHost write SetHost;
    property Port: Integer read GetPort write SetPort;
    property Routes: TStringList read GetRoutes write SetRoutes;
    property Headers: THTTPStrHeaders read GetHeaders write SetHeaders;
    property Parameters: THTTPStrParameters read GetParameters write SetParameters;
    property Files: THTTPFiles read GetFiles write SetFiles;
    property BeforeList: THTTPOnBeforeList read GetBeforeList write SetBeforeList;
    property AfterList: THTTPOnAfterList read GetAfterList write SetAfterList;
    property RExceptionList: THTTPOnExceptionList read GetRExceptionList write SetRExceptionList;
    procedure Execute; virtual;
  published
    { published declarations }
  end;

  THTTPRequest<T: constructor, IHTTPProcessor> = class(TInterfacedObject, IHTTPRequest<T>)
  private
    { private declarations }
    FHTTPProcessor: IHTTPProcessor;
    FHeaders: THTTPStrHeaders;
    FMethod: THTTPMethods;
    FProtocol: THTTPProtocols;
    FPort: Integer;
    FParameters: THTTPStrParameters;
    FHost: string;
    FRoutes: TStringList;
    FBeforeList: THTTPOnBeforeList;
    FRExceptionList: THTTPOnExceptionList;
    FAfterList: THTTPOnAfterList;
    FFiles: THTTPFiles;
  protected
    { protected declarations }
  public
    { public declarations }
    constructor Create; virtual;
    destructor Destroy; override;

    function Method(AMethod: THTTPMethods): IHTTPRequest<T>;
    function Protocol(AProtocol: THTTPProtocols): IHTTPRequest<T>;
    function Host(AHost: string): IHTTPRequest<T>;
    function Port(APort: Integer): IHTTPRequest<T>;
    function Route(ARoute: string): IHTTPRequest<T>;
    function Header(AKey, AValue: string): IHTTPRequest<T>;
    function Parameter(AKey, AValue: string): IHTTPRequest<T>;
    function &File(AKey, AFileName: string): IHTTPRequest<T>;

    function OnAfter(AProcAfterExecute: THTTPProcAfterExecute): IHTTPRequest<T>;
    function OnBefore(AProcBeforeExecute: THTTPProcBeforeExecute): IHTTPRequest<T>;
    function OnException(AProcException: THTTPProcException): IHTTPRequest<T>;

    procedure Execute;
  published
    { published declarations }
  end;

implementation

{ THTTPRequest }

function THTTPRequest<T>.OnAfter(AProcAfterExecute: THTTPProcAfterExecute): IHTTPRequest<T>;
begin
  FAfterList.Add(AProcAfterExecute);
  Result := Self;
end;

function THTTPRequest<T>.OnBefore(AProcBeforeExecute: THTTPProcBeforeExecute): IHTTPRequest<T>;
begin
  FBeforeList.Add(AProcBeforeExecute);
  Result := Self;
end;

function THTTPRequest<T>.OnException(AProcException: THTTPProcException): IHTTPRequest<T>;
begin
  FRExceptionList.Add(AProcException);
  Result := Self;
end;

function THTTPRequest<T>.Parameter(AKey, AValue: string): IHTTPRequest<T>;
begin
  if FParameters.ContainsKey(AKey) then
    FParameters.Items[AKey] := AValue
  else
    FParameters.Add(AKey, AValue);
  Result := Self;
end;

function THTTPRequest<T>.Port(APort: Integer): IHTTPRequest<T>;
begin
  FPort := APort;
  Result := Self;
end;

function THTTPRequest<T>.Protocol(AProtocol: THTTPProtocols): IHTTPRequest<T>;
begin
  FProtocol := AProtocol;
  Result := Self;
end;

function THTTPRequest<T>.Route(ARoute: string): IHTTPRequest<T>;
begin
  FRoutes.Add(ARoute);
  Result := Self;
end;

destructor THTTPRequest<T>.Destroy;
begin
  FBeforeList.Clear;
  FreeAndNil(FBeforeList);

  FAfterList.Clear;
  FreeAndNil(FAfterList);

  FRExceptionList.Clear;
  FreeAndNil(FRExceptionList);

  FHeaders.Clear;
  FreeAndNil(FHeaders);

  FParameters.Clear;
  FreeAndNil(FParameters);

  FRoutes.Clear;
  FreeAndNil(FRoutes);

  FFiles.Clear;
  FreeAndNil(FFiles);
  inherited;
end;

procedure THTTPRequest<T>.Execute;
begin
  FHTTPProcessor.Method := FMethod;
  FHTTPProcessor.Protocol := FProtocol;
  FHTTPProcessor.Host := FHost;
  FHTTPProcessor.Port := FPort;
  FHTTPProcessor.Routes := FRoutes;
  FHTTPProcessor.Headers := FHeaders;
  FHTTPProcessor.Parameters := FParameters;
  FHTTPProcessor.Files := FFiles;
  FHTTPProcessor.BeforeList := FBeforeList;
  FHTTPProcessor.AfterList := FAfterList;
  FHTTPProcessor.RExceptionList := FRExceptionList;
  FHTTPProcessor.Execute;
end;


function THTTPRequest<T>.&File(AKey, AFileName: string): IHTTPRequest<T>;
begin
  if FMethod <> THTTPMethods.smPOST then
    raise Exception.Create('This method does not allow file upload');

  if FFiles.ContainsKey(AKey) then
    FFiles.Items[AKey] := AFileName
  else
    FFiles.Add(AKey, AFileName);
  Result := Self;
end;

function THTTPRequest<T>.Header(AKey, AValue: string): IHTTPRequest<T>;
begin
  if FHeaders.ContainsKey(AKey) then
    FHeaders.Items[AKey] := AValue
  else
    FHeaders.Add(AKey, AValue);

  Result := Self;
end;

function THTTPRequest<T>.Host(AHost: string): IHTTPRequest<T>;
begin
  FHost := AHost;
  Result := Self;
end;

function THTTPRequest<T>.Method(AMethod: THTTPMethods): IHTTPRequest<T>;
begin
  FMethod := AMethod;
  Result := Self;
end;

constructor THTTPRequest<T>.Create;
begin
  FHTTPProcessor := T.Create;
  FHeaders := THTTPStrHeaders.Create;
  FMethod := THTTPMethods.smGET;
  FProtocol := THTTPProtocols.spHTTP;
  FPort := 80;
  FParameters := THTTPStrParameters.Create;
  FHost := '127.0.0.1';
  FRoutes := TStringList.Create;
  FBeforeList := THTTPOnBeforeList.Create;
  FRExceptionList := THTTPOnExceptionList.Create;
  FAfterList := THTTPOnAfterList.Create;
  FFiles := THTTPFiles.Create;
end;

{ THTTPProcessor }

procedure THTTPProcessor.Execute;
begin

end;

function THTTPProcessor.GetAfterList: THTTPOnAfterList;
begin
  Result := FAfterList;
end;

function THTTPProcessor.GetBeforeList: THTTPOnBeforeList;
begin
  Result := FBeforeList;
end;

function THTTPProcessor.GetFiles: THTTPFiles;
begin
  Result := FFiles;
end;

function THTTPProcessor.GetHeaders: THTTPStrHeaders;
begin
  Result := FHeaders;
end;

function THTTPProcessor.GetHost: string;
begin
  Result := FHost;
end;

function THTTPProcessor.GetMethod: THTTPMethods;
begin
  Result := FMethod;
end;

function THTTPProcessor.GetParameters: THTTPStrParameters;
begin
  Result := FParameters;
end;

function THTTPProcessor.GetPort: Integer;
begin
  Result := FPort;
end;

function THTTPProcessor.GetProtocol: THTTPProtocols;
begin
  Result := FProtocol;
end;

function THTTPProcessor.GetRExceptionList: THTTPOnExceptionList;
begin
  Result := FRExceptionList;
end;

function THTTPProcessor.GetRoutes: TStringList;
begin
  Result := FRoutes;
end;

procedure THTTPProcessor.SetAfterList(const Value: THTTPOnAfterList);
begin
  FAfterList := Value;
end;

procedure THTTPProcessor.SetBeforeList(const Value: THTTPOnBeforeList);
begin
  FBeforeList := Value;
end;

procedure THTTPProcessor.SetFiles(const Value: THTTPFiles);
begin
  FFiles := Value;
end;

procedure THTTPProcessor.SetHeaders(const Value: THTTPStrHeaders);
begin
  FHeaders := Value;
end;

procedure THTTPProcessor.SetHost(const Value: string);
begin
  FHost := Value;
end;

procedure THTTPProcessor.SetMethod(const Value: THTTPMethods);
begin
  FMethod := Value;
end;

procedure THTTPProcessor.SetParameters(const Value: THTTPStrParameters);
begin
  FParameters := Value;
end;

procedure THTTPProcessor.SetPort(const Value: Integer);
begin
  FPort := Value;
end;

procedure THTTPProcessor.SetProtocol(const Value: THTTPProtocols);
begin
  FProtocol := Value;
end;

procedure THTTPProcessor.SetRExceptionList(const Value: THTTPOnExceptionList);
begin
  FRExceptionList := Value;
end;

procedure THTTPProcessor.SetRoutes(const Value: TStringList);
begin
  FRoutes := Value;
end;

end.
