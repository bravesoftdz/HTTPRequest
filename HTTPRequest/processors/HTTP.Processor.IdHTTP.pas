unit HTTP.Processor.IdHTTP;

interface

uses HTTP.Classes, HTTP.Types, HTTP.Interfaces, System.Classes, System.SysUtils, IdHTTP, IdMultipartFormData, HTTP.Utils;

type
  THTTPProcessorIdHTTP = class(THTTPProcessor)
  private
    { private declarations }
    FIdHTTP: TIdHTTP;
  protected
    { protected declarations }
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
  LURL: string;
begin
  inherited;

  LURL := '';

  LURL := THTTPUtils.ProtocolToStr(Protocol) + '://' + Host;

  if Port <> 80 then
    LURL := LURL + ':' + Port.ToString;

  LURL := LURL + THTTPUtils.RoutesToStr(Routes);

  TThread.CreateAnonymousThread(
    procedure
    var
      LThreadHeaderKeys: string;
      LThreadParameterKeys: string;
      LThreadFilesKeys: string;
      LThreadResponseStream: TMemoryStream;
      LThreadMultiPartFormDataStream: TIdMultiPartFormDataStream;
      I: Integer;
    begin
      FIdHTTP := TIdHTTP.Create(nil);
      LThreadMultiPartFormDataStream := TIdMultiPartFormDataStream.Create;
      LThreadResponseStream := TMemoryStream.Create;
      if Assigned(BeforeList) then
        for I := 0 to BeforeList.Count - 1 do
          TThread.Synchronize(nil,
            procedure
            begin
              BeforeList[I]();
            end);
      try
        for LThreadHeaderKeys in Headers.Keys do
          FIdHTTP.Request.CustomHeaders.AddValue(LThreadHeaderKeys, Headers.Items[LThreadHeaderKeys]);
        FIdHTTP.Request.CustomHeaders.AddValue('X-Requested-With', 'XMLHttpRequest');
        try
          if Method = smGET then
          begin
            LURL := LURL + THTTPUtils.ParamameterToStr(Parameters);
            FIdHTTP.Get(LURL, LThreadResponseStream);
          end;
          if Method = smPOST then
          begin
            for LThreadParameterKeys in Parameters.Keys do
              LThreadMultiPartFormDataStream.AddFormField(LThreadParameterKeys, Parameters.Items[LThreadParameterKeys]).ContentTransfer := '';
            for LThreadFilesKeys in Files.Keys do
              LThreadMultiPartFormDataStream.AddFile(LThreadFilesKeys, Files.Items[LThreadFilesKeys]);
            FIdHTTP.Post(LURL, LThreadMultiPartFormDataStream, LThreadResponseStream);
          end;
        except
          on E: Exception do
          begin
            if Assigned(RExceptionList) then
              for I := 0 to RExceptionList.Count - 1 do
                TThread.Synchronize(nil,
                  procedure
                  begin
                    RExceptionList[I](E, FIdHTTP.Response.ResponseCode);
                  end);
          end;
        end;
      finally
        if Assigned(AfterList) then
          for I := 0 to AfterList.Count - 1 do
            TThread.Synchronize(nil,
              procedure
              begin
                AfterList[I](LThreadResponseStream, FIdHTTP.Response.ResponseCode)
              end);
        FreeAndNil(LThreadMultiPartFormDataStream);
        FreeAndNil(LThreadResponseStream);
      end;
    end).Start;
end;

constructor THTTPProcessorIdHTTP.Create;
begin
  FIdHTTP := TIdHTTP.Create(nil);
end;


end.
