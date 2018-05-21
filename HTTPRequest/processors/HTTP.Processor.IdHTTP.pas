unit HTTP.Processor.IdHTTP;

interface

uses HTTP.Classes, HTTP.Types, HTTP.Interfaces, System.Classes, System.SysUtils, IdHTTP, IdMultipartFormData;

type
  THTTPProcessorIdHTTP = class(THTTPProcessor)
  private
    { private declarations }
    FIdHTTP: TIdHTTP;
  protected
    { protected declarations }
    function RoutesToStr(ARoute: TStringList): string;
    function ProtocolToStr(AProtocols: THTTPProtocols): string;
    function ParamameterToStr(AParameters: THTTPStrParameters): string;
  public
    { public declarations }
    constructor Create;
    destructor Destroy; override;
    procedure Execute; override;
  published
    { published declarations }
  end;

implementation

{ THTTPRequest }

destructor THTTPProcessorIdHTTP.Destroy;
begin
  FreeAndNil(FIdHTTP);
  inherited;
end;

procedure THTTPProcessorIdHTTP.Execute;
var
  LMultiPartFormDataStream: TIdMultiPartFormDataStream;
  LURL: string;
begin
  inherited;

  LURL := '';

  LURL := ProtocolToStr(Protocol) + '://' + Host;

  if Port <> 80 then
    LURL := LURL + ':' + Port.ToString;

  LURL := LURL + RoutesToStr(Routes);

  TThread.CreateAnonymousThread(
    procedure
    var
      LHttp: TIdHTTP;
      LHeaderKeys: string;
      LThreadParameterKeys: string;
      LThreadFilesKeys: string;
      LThreadResponseStream: TMemoryStream;
      I: Integer;
    begin
      LHttp := TIdHTTP.Create(nil);
      LMultiPartFormDataStream := TIdMultiPartFormDataStream.Create;
      LThreadResponseStream := TMemoryStream.Create;
      if Assigned(BeforeList) then
        for I := 0 to BeforeList.Count - 1 do
          TThread.Synchronize(nil,
            procedure
            begin
              BeforeList[I]();
            end);
      try
        for LHeaderKeys in Headers.Keys do
          LHttp.Request.CustomHeaders.AddValue(LHeaderKeys, Headers.Items[LHeaderKeys]);
        LHttp.Request.CustomHeaders.AddValue('X-Requested-With', 'XMLHttpRequest');
        try
          if Method = smGET then
          begin
            LURL := LURL + ParamameterToStr(Parameters);
            LHttp.Get(LURL, LThreadResponseStream);
          end;
          if Method = smPOST then
          begin
            for LThreadParameterKeys in Parameters.Keys do
              LMultiPartFormDataStream.AddFormField(LThreadParameterKeys, Parameters.Items[LThreadParameterKeys]).ContentTransfer := '';
            for LThreadFilesKeys in Files.Keys do
              LMultiPartFormDataStream.AddFile(LThreadFilesKeys, Files.Items[LThreadFilesKeys]);
            LHttp.Post(LURL, LMultiPartFormDataStream, LThreadResponseStream);
          end;
        except
          on E: Exception do
          begin
            if Assigned(RExceptionList) then
              for I := 0 to RExceptionList.Count - 1 do
                TThread.Synchronize(nil,
                  procedure
                  begin
                    RExceptionList[I](E, LHttp.Response.ResponseCode);
                  end);
          end;
        end;
      finally
        if Assigned(AfterList) then
          for I := 0 to AfterList.Count - 1 do
            TThread.Synchronize(nil,
              procedure
              begin
                AfterList[I](LThreadResponseStream, LHttp.Response.ResponseCode)
              end);

        FreeAndNil(LHttp);
        FreeAndNil(LMultiPartFormDataStream);
        FreeAndNil(LThreadResponseStream);
      end;
    end).Start;
end;

constructor THTTPProcessorIdHTTP.Create;
begin
  FIdHTTP := TIdHTTP.Create(nil);
end;

function THTTPProcessorIdHTTP.ParamameterToStr(AParameters: THTTPStrParameters): string;
var
  LParamameterKeys: string;
begin
  Result := '';
  for LParamameterKeys in AParameters.Keys do
  begin
    if Result.Trim.IsEmpty then
      Result := '?';
    if AParameters.Keys.ToArray[AParameters.Keys.Count - 1] = LParamameterKeys then
      Result := Result + LParamameterKeys + '=' + AParameters.Items[LParamameterKeys]
    else
      Result := Result + LParamameterKeys + '=' + AParameters.Items[LParamameterKeys] + '&'
  end;
end;

function THTTPProcessorIdHTTP.ProtocolToStr(AProtocols: THTTPProtocols): string;
begin
  case AProtocols of
    spHTTP:
      Result := 'http';
    spHTTPS:
      Result := 'https';
  end;
end;

function THTTPProcessorIdHTTP.RoutesToStr(ARoute: TStringList): string;
var
  I: Integer;
begin
  Result := '';
  if ARoute.Count > 1 then
  begin
    for I := 0 to ARoute.Count - 1 do
      Result := Result + ARoute.Strings[I]
  end
  else if ARoute.Count = 1 then
    Result := ARoute.Strings[0];
end;

end.
