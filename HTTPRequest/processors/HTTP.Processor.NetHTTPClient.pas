unit HTTP.Processor.NetHTTPClient;

interface

uses
  HTTP.Classes, HTTP.Types, HTTP.Interfaces, System.Classes, System.SysUtils, System.Net.URLClient, System.Net.HttpClient,
  System.Net.HttpClientComponent, System.Net.Mime, HTTP.Utils, System.Generics.Collections;

type

  THTTPProcessorNetHTTPClient = class(THTTPProcessor)
  private
    { private declarations }
    FNetHTTPClient: TNetHTTPClient;
    FNetHTTPRequest: TNetHTTPRequest;
  protected
    { protected declarations }
    procedure DoRequestCompleted(const Sender: TObject; const AResponse: IHTTPResponse);
    procedure DoRequestError(const Sender: TObject; const AError: string);
  public
    { public declarations }
    constructor Create;
    destructor Destroy; override;
    procedure Execute; override;
  published
    { published declarations }
  end;

implementation

{ THTTPProcessorNetHTTPClient }

constructor THTTPProcessorNetHTTPClient.Create;
begin
  FNetHTTPClient := TNetHTTPClient.Create(nil);
  FNetHTTPClient.Asynchronous := True;
  FNetHTTPClient.OnRequestCompleted := DoRequestCompleted;
  FNetHTTPClient.OnRequestError := DoRequestError;

  FNetHTTPRequest := TNetHTTPRequest.Create(nil);
  FNetHTTPRequest.Client := FNetHTTPClient;
  FNetHTTPRequest.Asynchronous := True;
end;

destructor THTTPProcessorNetHTTPClient.Destroy;
begin
  FNetHTTPClient.Free;
  FNetHTTPRequest.Free;
  inherited;
end;

procedure THTTPProcessorNetHTTPClient.DoRequestCompleted(const Sender: TObject; const AResponse: IHTTPResponse);
var
  I: Integer;
begin
  for I := 0 to AfterList.Count - 1 do
    AfterList[I](TMemoryStream(AResponse.ContentStream), AResponse.StatusCode);
end;

procedure THTTPProcessorNetHTTPClient.DoRequestError(const Sender: TObject; const AError: string);
var
  I: Integer;
begin
  for I := 0 to RExceptionList.Count - 1 do
    RExceptionList[I](Exception.Create(AError), 0);
end;

procedure THTTPProcessorNetHTTPClient.Execute;
var
  LMultiPartFormData: TMultiPartFormData;
  LURL: string;
  LHeaderKeys: string;
  LParameterKeys: string;
  LFilesKeys: string;
begin
  inherited;
  LMultiPartFormData := TMultiPartFormData.Create;
  try
    LURL := '';
    LURL := THTTPUtils.ProtocolToStr(Protocol) + '://' + Host;
    if Port <> 80 then
      LURL := LURL + ':' + Port.ToString;
    LURL := LURL + THTTPUtils.RoutesToStr(Routes);
    for LHeaderKeys in Headers.Keys do
      FNetHTTPRequest.CustomHeaders[LHeaderKeys] := Headers.Items[LHeaderKeys];
    FNetHTTPRequest.CustomHeaders['X-Requested-With'] := 'XMLHttpRequest';
    if Method = smGET then
    begin
      LURL := LURL + THTTPUtils.ParamameterToStr(Parameters);
      FNetHTTPRequest.Get(LURL);
    end;
    if Method = smPOST then
    begin
      for LParameterKeys in Parameters.Keys do
        LMultiPartFormData.AddField(LParameterKeys, Parameters.Items[LParameterKeys]);
      for LFilesKeys in Files.Keys do
        LMultiPartFormData.AddFile(LFilesKeys, Files.Items[LFilesKeys]);
      FNetHTTPRequest.Post(LURL,LMultiPartFormData);
    end;
  finally
    LMultiPartFormData.Free;
  end;
end;

end.
