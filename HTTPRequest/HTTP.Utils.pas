unit HTTP.Utils;

interface

uses
  System.Classes, System.SysUtils, HTTP.Types;

type

  THTTPUtils = class
  private
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
    class function RoutesToStr(ARoute: TStringList): string;
    class function ProtocolToStr(AProtocols: THTTPProtocols): string;
    class function ParamameterToStr(AParameters: THTTPStrParameters): string;
  published
    { published declarations }
  end;

implementation

{ THTTPUtils }

class function THTTPUtils.ParamameterToStr(AParameters: THTTPStrParameters): string;
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

class function THTTPUtils.ProtocolToStr(AProtocols: THTTPProtocols): string;
begin
  case AProtocols of
    spHTTP:
      Result := 'http';
    spHTTPS:
      Result := 'https';
  end;
end;

class function THTTPUtils.RoutesToStr(ARoute: TStringList): string;
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
